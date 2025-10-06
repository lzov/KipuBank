# KipuBank

## Descripción

KipuBank es un smart contract en Solidity que permite a los usuarios:

- Depositar ETH en una bóveda personal.
- Retirar ETH hasta un límite máximo por transacción.
- Consultar el saldo de su bóveda.
- Respetar un límite global de fondos (bankCap) para seguridad.

El contrato sigue buenas prácticas de desarrollo: errores personalizados, patrón checks-effects-interactions, funciones "private" reutilizables, eventos y documentación NatSpec.

---

## Despliegue

### Requisitos

- [Remix IDE](https://remix.ethereum.org/)
- MetaMask (para testnets como Sepolia/Goerli)

### Pasos para desplegar

1. Abrir "KipuBank.sol" en Remix.
2. Seleccionar la versión "0.8.30" del compilador.
3. Compilar el contrato.
4. Ir a la pestaña **Deploy & Run Transactions**.
5. Seleccionar **Environment**:
   - "Remix VM" para pruebas locales, o
   - "Injected Provider - MetaMask" para testnet.
6. Ingresar los parámetros del constructor:
   - "_withdrawLimit" → límite de retiro por transacción (ej: "1 ether").
   - "_bankCap" → límite total de ETH en el contrato (ej: "10 ether").
7. Click en **Deploy** y confirmar la transacción.
8. Guardar la **dirección del contrato desplegado**.

---

## Interacción con el contrato

### Funciones principales

| Función | Tipo | Descripción |
|---------|------|-------------|
| "deposit()" | external payable | Deposita ETH en la bóveda personal. |
| "withdraw(uint256 amount)" | external | Retira ETH hasta el límite permitido. |
| "getVaultBalance(address user)" | external view | Devuelve el saldo del usuario. |

### Eventos

| Evento | Descripción |
|--------|------------|
| "Deposit(address user, uint256 amount)" | Se emite en depósitos exitosos. |
| "Withdraw(address user, uint256 amount)" | Se emite en retiros exitosos. |

### Errores personalizados

| Error | Significado |
|-------|------------|
| "BankCapExceeded" | Se excedió la capacidad total del banco. |
| "WithdrawLimitExceeded" | El retiro supera el límite por transacción. |
| "InsufficientBalance" | Intento de retiro mayor al saldo del usuario. |

---

## Dirección del contrato desplegado

- Testnet Sepolia: `0xc44dd81cc6786290ed3fb3aa797c8755e9632815`
- Block explorer: [Ver contrato](https://sepolia.etherscan.io/address/0xc44dd81cc6786290ed3fb3aa797c8755e9632815)


---

## Notas

- Este contrato es educativo. **No usar en producción**.  
- Sigue patrones de seguridad y buenas prácticas profesionales.
