// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

// Title Bid - Trabajo proactico Modulo 2 Subasta
contract Tpm2Bid {

    /* Variables - beneficiary - Auction beneficiary - Beneficiario de la Subasta
                 - highestBidder - The Bidder with the highest bet - El apostador con la apuesta mas alta
                 - highestBid - The highest bet - La apuesta mas alta
                 - COMMISSION - Commision - Comision de 2%
                 - startTime - Date and time of the start of the auction - Fecha y hora de comienzo de la subasta
                 - endTime - Date and time of the auction end- Fecha y hora de finalizacion de la subasta */
    
    address public beneficiary;
    address public highestBidder;
    uint public highestBid;
    uint public constant COMMISSION = 2;
    uint256 public startTime;
    uint256 public endTime;

    // Structure of an offer - Estructura de la oferta
    struct Bid{
        address bidder;
        uint amount;
    }

    // // Array to store all the offers - Estructura de datos para almacenar las ofertas
    Bid[] public bids;
       
    mapping (address => uint) public pendingReturns;

    // Flags - Boolean variables - Variables booleanas
    bool startedBid = true;
    bool endedBid;

    // Event of new offers - Evento emitido cuando hay un nueva oferta
    event HighestBidIncreased(address indexed bidder, uint amount);
    
    // Event of auction finished - Evento que indica que la subasta finalizo
    event Auctionfinished(address winner, uint amount);
    
    constructor (uint _biddingTime){
        beneficiary =msg.sender;
        startTime =  block.timestamp;
        endTime = startTime + (_biddingTime * 1 minutes);             
    }

    /* Modifiers - Allows a function to be executed when the auction is active - 
                   Permite que se ejecute una funcion cunado la subasta esta activa */
    modifier isActive() {
        require(block.timestamp < endTime, "the auction ended");
        _;
    }

    // Modifiers - Allows a function to be executed only by the auction beneficiary - Permite que se ejecute una funcion solo por el dueño de la subasta 
    modifier onlyOwner(){
        require (msg.sender == beneficiary, "Only the owner can execute this"); 
        _;
    }

    // Allows you to make an offer if it exceeds the previous one by 5% more - Permite realizar una oferta si supera a la anterior por un 5% mas
    function bid () external payable isActive{
        if (startedBid){
            highestBid = msg.value;
            startedBid = false;
        } else{
            require(msg.value >= highestBid * 105 / 100, "The auction value offered must exceed the current value by 5%");
        }
                
        pendingReturns[msg.sender] = msg.value;
        
        highestBidder = msg.sender;
        highestBid = msg.value;

        bids.push(Bid(msg.sender, msg.value));
        emit HighestBidIncreased(msg.sender, msg.value);

        if (endTime - block.timestamp < 10 minutes){
            endTime += 10 minutes;
        }
    }

    /* Partial Refund - Returns unsuccessful bids to bidders who request them - 
       Reenbolso parcial - Devuelve las ofertas no ganadoras a los oferentes que lo solicitan */
    function partialRefund() external isActive {
        require(pendingReturns[msg.sender] > 0, "There are not funds to reimburse" );
        
        uint lenEnd = bids.length;
        for (uint i = 0; i < lenEnd; i++){
            address bidderEnd = bids[i].bidder;
            uint amountEnd = bids[i].amount;
        
            if (bidderEnd == msg.sender && i < lenEnd -1 && amountEnd > 0){
                address bidderRefund = bids[i].bidder;
                uint amountRefund = bids[i].amount;
                pendingReturns[bidderRefund] = 0;
                payable(bidderRefund).transfer(amountRefund);
            }
        }
    }

    // Indicates who the winner was and the amount of the winning bid - Indica quien fue el ganador y el monto de la oferta ganadora
    function winner() public view returns (address, uint) {
        require(endedBid, "The auction has not ended yet");
        return (highestBidder, highestBid);
    }

    /* Refund the deposits of bidders who did not complete the withdrawal during the auction, and a fee is charged - 
       Devuelve los depositos de los oferentes que no realizaron el retiro duarante la subasta y se le cobra una comision */
    function endAuction() public onlyOwner{
        require(block.timestamp >= endTime, "The auction is still active");
        require(!endedBid, "The auction has already ended");
        endedBid = true;

        uint len = bids.length;
        for (uint i = 0; i < len; i++){
            address bidder = bids[i].bidder;
            uint amount = bids[i].amount;
        
            if (bidder != highestBidder && amount > 0){
                pendingReturns[bidder] = 0;
                uint commisionRefund = amount * COMMISSION / 100;
                uint refund = amount - commisionRefund;
                payable(bidder).transfer(refund);                  
            }
        }
        emit Auctionfinished(highestBidder, highestBid);
    }
}
