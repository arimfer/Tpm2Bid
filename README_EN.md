# 📘 `Tpm2Bid` Contract Documentation

This smart contract implements an auction on the Ethereum blockchain. It is developed in Solidity and allows managing bids, automatically extending the auction time, partially refunding losing bidders, and determining a winner.

---

## ⚙️ Variables

- `address public beneficiary`  
  Address of the auction beneficiary (the one who initiates it).

- `address public highestBidder`  
  Address of the bidder with the highest bid.

- `uint public highestBid`  
  Current highest bid amount.

- `uint public constant COMMISSION = 2`  
  Fixed 2% commission applied to certain refunds.

- `uint256 public startTime`  
  Timestamp marking the start of the auction.

- `uint256 public endTime`  
  Timestamp marking the end of the auction.

- `Bid[] public bids`  
  List of all registered bids (structure `Bid` with `bidder` and `amount`).

- `mapping (address => uint) public pendingReturns`  
  Record of pending refunds for each bidding address.

- `bool startedBid`  
  Indicates whether the first bid has been placed.

- `bool endedBid`  
  Indicates whether the auction has ended.

---

## 🧩 Structures

- `struct Bid`  
  ```solidity
  struct Bid {
      address bidder;
      uint amount;
  }
  ```
  Represents a bid with the bidder's address and the bid amount.

---

## 🛠️ Functions

- `constructor(uint _biddingTime)`  
  Initializes the auction with a specific duration (in minutes).

- `function bid() external payable isActive`  
  Allows placing a bid, as long as it exceeds the previous one by at least 5%. Extends the auction if there are less than 10 minutes left.

- `function partialRefund() external isActive`  
  Partially refunds non-winning bids to the requester during the auction.

- `function winner() public view returns (address, uint)`  
  Returns the winner and the winning bid amount (only if the auction has ended).

- `function endAuction() public onlyOwner`  
  Ends the auction. Refunds losing bidders with a deduction for commission.

---

## 🔒 Modifiers

- `modifier isActive`  
  Restricts execution to functions that must be run before the auction ends.

- `modifier onlyOwner`  
  Restricts execution to the auction's beneficiary.

---

## 📢 Events

- `event HighestBidIncreased(address indexed bidder, uint amount)`  
  Emitted when a new highest bid is placed.

- `event Auctionfinished(address winner, uint amount)`  
  Emitted when the auction ends, showing the winner and final bid amount.