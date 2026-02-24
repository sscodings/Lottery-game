// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

contract MultiSigWallet{
    event Deposit(address indexed sender, uint amount);
    event Submit(uint indexed txID);
    event Approve(address indexed owner , uint indexed txId);
    event Revoke(address indexed owner , uint indexed txID);
    event Execute(uint indexed txID);

    struct Transaction{
        address to;
        uint value;
        bytes data;
        bool executed;
    }

    address[] public owners;
    mapping(address=>bool) public isOwner;
    uint public required;
    Transaction[] public transactions;
    mapping(uint=>mapping(address=>bool)) public approve;

    modifier onlyOwner(){
        require(isOwner[msg.sender],"Sender is not the owner") ;
        _;
    }

    modifier txExists(uint _txId){
        require(_txId<transactions.length,"Transaction does not exist");
        _;
    }
    modifier notApproved(uint _txId){
        require(!approve[_txId][msg.sender],"Id is already approved");
        _;
    }
    modifier notExecuted(uint _txId){
        require(!transactions[_txId].executed,"tx already executed");
        _;
    }

    constructor(address[] memory _owners , uint _require ){
        require(_owners.length>0,"Owner required");
        require(_require>0 && _require<=_owners.length,"invalid required number of owners");
        for(uint i=0;i<_owners.length;i++){
            address owner = _owners[i];
            require(owner!=address(0),"Invalid owner");
            require(!isOwner[owner],"Owner is not unique");
            isOwner[owner]=true;
            owners.push(owner);
            required = _require;
        }
    }

    receive() external payable{
        emit Deposit(msg.sender,msg.value);
    }

    function submit(address _to, uint _value, bytes calldata _data) external onlyOwner{
        transactions.push(Transaction({
            to:_to,
            value:_value,
            data:_data,
            executed:false
        }));
        emit Submit(transactions.length-1);
    }

    function approved(uint txId)
    external
    onlyOwner
    txExists(txId)
    notApproved(txId)
    notExecuted(txId)
    {
        approve[txId][msg.sender] = true;
        emit Approve(msg.sender, txId);
    }

    function _getApprovalCount(uint _txId) private view returns(uint count){
        for(uint i=0;i<owners.length;i++){
            if(approve[_txId][owners[i]]){
                count += 1;
            }
        }
    }

    function execute(uint _txId) external txExists(_txId) notExecuted(_txId){
        require(_getApprovalCount(_txId)>required,"Approval are not enough");
        Transaction storage transaction = transactions[_txId];

        transaction.executed = true;

        (bool success,) = transaction.to.call{value:transaction.value}(transaction.data);
        require(success,"Transaction failed");

        emit Execute(_txId); 
    }

    function revoke(uint _txId) external onlyOwner notExecuted(_txId) txExists(_txId){
        require(approve[_txId][msg.sender],"Tx not approved");
        approve[_txId][msg.sender] = false;
        emit Revoke(msg.sender, _txId);
    }
}