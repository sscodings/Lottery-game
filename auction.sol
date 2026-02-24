// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

contract Ownable {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }
}
contract Auction is Ownable{
    address payable public highestBidder;
    uint public BidPrice;
    uint public endAuction;
    bool ended;

    constructor(uint _duration) {
        endAuction = block.timestamp + _duration;
        ended = false;
    }

    function addBid() external payable {

        require(block.timestamp < endAuction, "Auction ended");
        require(msg.value > BidPrice, "Bid too low");
        if (highestBidder != address(0)) {
            (bool sent, ) = highestBidder.call{value: BidPrice}("");
            require(sent, "Refund failed");
        }

        highestBidder = payable(msg.sender);
        BidPrice = msg.value;
    }

    function EndAuction() onlyOwner external{
        require(block.timestamp > endAuction, "Auction not ended");
        require(!ended,"Auction already ended");
        ended = true;
        (bool sent, ) = owner.call{value: address(this).balance}("");
        require(sent, "Transfer failed");
    }     
}