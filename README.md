
# 📘 Documentación del Contrato `Tpm2Bid`

Este contrato inteligente implementa una subasta en la blockchain de Ethereum. Está desarrollado en Solidity y permite gestionar pujas, extender automáticamente el tiempo de la subasta, reembolsar parcialmente a los oferentes perdedores y determinar un ganador.

---

## ⚙️ Variables

- `address public beneficiary`  
  Dirección del beneficiario de la subasta (quien la inicia).

- `address public highestBidder`  
  Dirección del ofertante con la oferta más alta.

- `uint public highestBid`  
  Valor de la oferta más alta actual.

- `uint public constant COMMISSION = 2`  
  Comisión fija del 2% aplicada a ciertos reembolsos.

- `uint256 public startTime`  
  Marca de tiempo de inicio de la subasta.

- `uint256 public endTime`  
  Marca de tiempo del final de la subasta.

- `Bid[] public bids`  
  Lista de todas las ofertadas registradas (estructura `Bid` con `bidder` y `amount`).

- `mapping (address => uint) public pendingReturns`  
  Registro de reembolsos pendientes para cada dirección ofertante.

- `bool startedBid`  
  Indica si se ha hecho la primera oferta.

- `bool endedBid`  
  Indica si la subasta ha finalizado.

---

## 🧩 Estructuras

- `struct Bid`  
  ```solidity
  struct Bid {
      address bidder;
      uint amount;
  }
  ```
  Representa una oferta con dirección del ofertante y el monto ofertado.

---

## 🛠️ Funciones

- `constructor(uint _biddingTime)`  
  Inicializa la subasta con un tiempo específico (en minutos).

- `function bid() external payable isActive`  
  Permite hacer una oferta, siempre que supere la anterior en al menos un 5%. Extiende la subasta si quedan menos de 10 minutos.

- `function partialRefund() external isActive`  
  Devuelve parcialmente las ofertas no ganadoras al solicitante durante la subasta.

- `function winner() public view returns (address, uint)`  
  Devuelve el ganador y el monto de la oferta ganadora (solo si la subasta ha terminado).

- `function endAuction() public onlyOwner`  
  Finaliza la subasta. Devuelve fondos a oferentes perdedores con deducción de comisión.

---

## 🔒 Modificadores

- `modifier isActive`  
  Restringe la ejecución a funciones que deben ejecutarse antes de finalizar la subasta.

- `modifier onlyOwner`  
  Restringe la ejecución al beneficiario de la subasta.

---

## 📢 Eventos

- `event HighestBidIncreased(address indexed bidder, uint amount)`  
  Se emite cuando se hace una nueva oferta más alta.

- `event Auctionfinished(address winner, uint amount)`  
  Se emite al finalizar la subasta, con el ganador y el monto final.
