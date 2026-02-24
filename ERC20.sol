// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

interface IERC20{
    function totalSupply() external view returns(uint);

    function balanceof(address account) external view returns (uint);

    function transfer(address recepient,uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns(uint);

    function approve(address spender,uint amount) external returns (bool);

    function TransferFrom(address sender,address recepient,uint amount) external returns(bool);
    
    event Transfer(address indexed from, address indexed to , uint amount);

    event Approval(address indexed owner, address indexed spender, uint amount);
}

contract ERC20 is IERC20{
    uint public totalSupply;
    mapping(address=>uint) public balanceof;
    mapping (address=>mapping(address=>uint))public allowance;
    string public name = "Test";
    string public symbol = "TEST";
    uint8 public decimals = 18;

    function transfer(address recepient, uint amount) external returns(bool){
        balanceof[msg.sender] -= amount;
        balanceof[recepient] += amount;
        emit Transfer(msg.sender,recepient,amount);
        return true;
    }

    function approve(address spender, uint amount) external returns(bool){
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function TransferFrom(address sender,address recepient,uint amount) external returns(bool){
        allowance[sender][msg.sender] -= amount;
        balanceof[sender]-=amount;
        balanceof[recepient]+=amount;
        emit Transfer(sender,recepient,amount);
        return true;
    }

    function mint(uint amount) external{
        balanceof[msg.sender] += amount;
        totalSupply += amount;
        emit Transfer(address(0),msg.sender,amount);
    }

    function burn(uint amount) external{
        balanceof[msg.sender]-= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender,address(0),amount);
    }

} 