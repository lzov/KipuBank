// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

/**
 * @title KipuBank
 * @notice Contrato que demuestra operaciones de depósito y retiro de ETH
 * @dev Contrato desarrollado para ETH Kipu (Talento Tech) - Consorte Mañana
 * @author Gabriel Liz Ovelar - @lzov
 * @custom:security No usar en producción!
 */
contract KipuBank {
    /*//////////////////////////////////////////////////////////////
                                VARIABLES
    //////////////////////////////////////////////////////////////*/

    /// @notice Límite máximo que puede retirarse por cada transacción.
    uint256 public immutable i_withdrawLimit;

    /// @notice Límite máximo total de fondos que puede contener el contrato.
    uint256 public immutable i_bankCap;

    /// @notice Mapea cada usuario con el balance depositado en su bóveda personal.
    mapping(address => uint256) private s_balances;

    /// @notice Contador global de depósitos realizados.
    uint256 public s_totalDepositsCount;

    /// @notice Contador global de retiros realizados.
    uint256 public s_totalWithdrawalsCount;

    /*//////////////////////////////////////////////////////////////
                                EVENTOS
    //////////////////////////////////////////////////////////////*/

    /// @notice Se emite cuando un usuario realiza un depósito exitoso.
    /// @param user Dirección del usuario que deposita.
    /// @param amount Monto depositado en wei.
    event Deposit(address indexed user, uint256 amount);

    /// @notice Se emite cuando un usuario realiza un retiro exitoso.
    /// @param user Dirección del usuario que retira.
    /// @param amount Monto retirado en wei.
    event Withdraw(address indexed user, uint256 amount);

    /*//////////////////////////////////////////////////////////////
                                ERRORES
    //////////////////////////////////////////////////////////////*/

    error BankCapExceeded(uint256 currentBalance, uint256 attemptedDeposit, uint256 bankCap);
    error WithdrawLimitExceeded(uint256 requested, uint256 maxAllowed);
    error InsufficientBalance(uint256 available, uint256 requested);

    /*//////////////////////////////////////////////////////////////
                                CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Inicializa los parámetros inmutables del contrato.
     * @param _withdrawLimit Monto máximo permitido por retiro.
     * @param _bankCap Límite total de ETH que puede almacenar el contrato.
     */
    constructor(uint256 _withdrawLimit, uint256 _bankCap) {
        require(_withdrawLimit > 0, "Withdraw limit must be > 0");
        require(_bankCap > 0, "Bank cap must be > 0");

        i_withdrawLimit = _withdrawLimit;
        i_bankCap = _bankCap;
    }

    /*//////////////////////////////////////////////////////////////
                                FUNCIONES
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Permite a los usuarios depositar ETH en su bóveda personal.
     * @dev Usa el patrón checks-effects-interactions y función private para validación.
     * @dev Emite un evento "Deposit" en depósitos exitosos.
     */
    function deposit() external payable {
        // ---------- CHECKS ----------
        if (msg.value == 0) revert("Deposit amount must be greater than 0");

        _checkBankCap(msg.value);

        // ---------- EFFECTS ----------
        s_balances[msg.sender] += msg.value;
        s_totalDepositsCount++;

        // ---------- INTERACTIONS ----------
        emit Deposit(msg.sender, msg.value);
    }

    /**
     * @notice Permite a los usuarios retirar ETH de su bóveda, hasta el límite permitido.
     * @param amount Cantidad de ETH a retirar (en wei).
     * @dev Usa el patrón checks-effects-interactions y función private para transferencias seguras.
     * @dev Emite un evento "Withdraw" en retiros exitosos.
     */
    function withdraw(uint256 amount) external {
        // ---------- CHECKS ----------
        if (amount > i_withdrawLimit) revert WithdrawLimitExceeded(amount, i_withdrawLimit);

        uint256 userBalance = s_balances[msg.sender];
        if (amount > userBalance) revert InsufficientBalance(userBalance, amount);

        // ---------- EFFECTS ----------
        s_balances[msg.sender] -= amount;
        s_totalWithdrawalsCount++;

        // ---------- INTERACTIONS ----------
        _safeSendETH(msg.sender, amount);

        emit Withdraw(msg.sender, amount);
    }

    /**
     * @notice Devuelve el saldo de ETH depositado por un usuario.
     * @param user Dirección del usuario a consultar.
     * @return balance Saldo en wei del usuario.
     */
    function getVaultBalance(address user) external view returns (uint256 balance) {
        return s_balances[user];
    }

    /*//////////////////////////////////////////////////////////////
                                FUNCIONES PRIVATE
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Verifica que un depósito no supere el límite total del contrato.
     * @param depositAmount Cantidad de ETH que se quiere depositar.
     * @dev Función privada reutilizable por deposit() u otras funciones internas.
     */
    function _checkBankCap(uint256 depositAmount) private view {
        uint256 contractBalance = address(this).balance;
        if (contractBalance + depositAmount > i_bankCap) {
            revert BankCapExceeded(contractBalance, depositAmount, i_bankCap);
        }
    }

    /**
     * @notice Envía ETH de forma segura a una dirección.
     * @param recipient Dirección que recibirá los fondos.
     * @param amount Cantidad de ETH a enviar.
     * @dev Lanza un error si la transferencia falla.
     */
    function _safeSendETH(address recipient, uint256 amount) private {
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "ETH transfer failed");
    }
}
