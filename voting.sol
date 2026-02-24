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

contract Votes is Ownable {

    struct Candidate {
        string name;
        uint votes;
    }

    Candidate[] public candidates;

    mapping(address => bool) public voters;

    event AddedCandidate(string name);
    event Voted(address voter, uint candidateIndex);

    function addCandidate(string memory _name) public onlyOwner {
        candidates.push(Candidate(_name, 0));
        emit AddedCandidate(_name);
    }

    function vote(uint _index) public {
        require(!voters[msg.sender], "Already voted");
        require(_index < candidates.length, "Invalid candidate");

        voters[msg.sender] = true;
        candidates[_index].votes += 1;

        emit Voted(msg.sender, _index);
    }

    function getWinner() public view returns (string memory) {
        uint maxVote = 0;
        string memory winner;

        for (uint i = 0; i < candidates.length; i++) {
            if (candidates[i].votes > maxVote) {
                maxVote = candidates[i].votes;
                winner = candidates[i].name;
            }
        }

        return winner;
    }
}