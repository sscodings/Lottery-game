// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

contract Lottery{
    address payable owner;
    constructor(){
        owner = payable(msg.sender);
    }

    address[] public players;

    function enter() public payable{
        require(msg.value==0.01 ether,"Minimum fee is 0.01 ether");
        players.push(msg.sender);
    }

    function getbalance() public view returns(uint){
        return address(this).balance;
    }

    function winner() public{
        require(msg.sender==owner,"Only owner can declre the winner");

        uint randomIndex = uint(keccak256(abi.encodePacked(block.timestamp,block.prevrandao,players.length)))%players.length;

        address Winner = players[randomIndex];

        payable(Winner).call{value:address(this).balance}("");
    }
}