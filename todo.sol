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

contract Todo is Ownable(){
    struct Task{
        string todo;
        bool completed;
    }
    uint public rewardPerTask = 10;
    mapping(address=>Task[]) public tasks;
    mapping (address=>uint) public rewaredPoints;

    event TaskCreated(address user, string content);
    event TaskCompleted(address user,uint index);
    event RewardUpdate(uint newReward);

    function Createtask(string memory _content) public{
        tasks[msg.sender].push(Task(_content,false));
        emit TaskCreated(msg.sender,_content);
    }

    function Completedtask(uint index) public{
        Task storage task = tasks[msg.sender][index];
        require(task.completed == false,"Task already completed");
        task.completed = true;
        rewaredPoints[msg.sender] += rewardPerTask;
        emit TaskCompleted(msg.sender,index);
    }

    function UpdateReward(uint _index) public onlyOwner{
        rewardPerTask = _index;
        emit RewardUpdate(_index);
    }
    
    function getTasks() public view returns(Task[] memory){
        return tasks[msg.sender];
    }

    function DeleteTask(uint _index) public{
        require(_index<tasks[msg.sender].length,"Invlaid index");
        uint last = tasks[msg.sender].length-1;
        if(_index!=last){
            tasks[msg.sender][_index]= tasks[msg.sender][last];
        }
        tasks[msg.sender].pop();
    } 


}