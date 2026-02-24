// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

import "./ERC20.sol";

contract CrowdFund{
    struct Campaign{
        address creator;
        uint goal;
        uint pledged;
        uint startAt;
        uint32 endAt;
        bool claimed;
    }

    ERC20 public immutable token;
    uint public count;
    mapping (uint=>Campaign) public campaigns;
    mapping (uint =>mapping(address=>uint)) public pledgeAmount;

    constructor(address _token){
        token = ERC20(_token);
    }

    event CampaignLaunched(uint id,address indexed creator,uint goal,uint startAt, uint32 endAt);
    event Cancel(uint _id); 
    event Pledge(uint _id,address indexed sender,uint _amount);
    event Unpledge(uint _id, address sender , uint _amount);
    event Claim(uint _id);
    event Refund(uint _id,address sender, uint _amount);
    function launch(uint _goal,uint _startAt,uint32 _endAt) external{
        require(_startAt>=block.timestamp, "Start at <now");
        require(_endAt>_startAt, "End at <= start at");
        require(_endAt<block.timestamp+90 days , "End at> max duration");
        count += 1;
        campaigns[count] = Campaign({
            creator:msg.sender,
            goal : _goal,
            pledged:0,
            startAt: _startAt,
            endAt:_endAt,
            claimed:false
        });

        emit CampaignLaunched(count,msg.sender,_goal,_startAt,_endAt);
    }

    function cancel(uint _id) external{
        Campaign memory campaign = campaigns[_id];
        require(msg.sender==campaign.creator,"not creator");
        require(block.timestamp<campaign.startAt,"Campaign has started");
        delete campaigns[_id];
        emit Cancel(_id);
    }

    function pledge(uint _id,uint _amount) external{
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp>=campaign.startAt , "Campaign has not started yet");
        require(block.timestamp<=campaign.endAt , "Campaign has already ended");
        campaign.pledged += _amount;
        pledgeAmount[_id][msg.sender]+= _amount;
        token.TransferFrom(msg.sender, address(this), _amount);
        emit Pledge(_id,msg.sender,_amount);
    }

    function unPledge(uint _id,uint _amount) external{
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp>=campaign.startAt , "Campaign has not started yet");
        require(block.timestamp<=campaign.endAt , "Campaign has already ended");
        campaign.pledged -= _amount;
        pledgeAmount[_id][msg.sender]-=_amount;
        token.transfer(msg.sender, _amount);
        emit Unpledge(_id, msg.sender, _amount);
    }   

    function claim(uint _id) external{
        Campaign storage campaign = campaigns[_id];
        require(msg.sender==campaign.creator,"Not the creator");
        require(block.timestamp>=campaign.endAt,"Campaign not ended yet");
        require(campaign.pledged > campaign.goal,"Goal not achieved");
        require(!campaign.claimed,"Already claimed");
        campaign.claimed = true;
        token.transfer(msg.sender, campaign.pledged);
        emit Claim(_id);
    }

    function refund(uint _id) external{
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp>=campaign.endAt,"Not ended yet");
        require(campaign.pledged<campaign.goal,"Goal achieved");
        
        uint bal = pledgeAmount[_id][msg.sender];
        pledgeAmount[_id][msg.sender] = 0;
        token.transfer(msg.sender,bal);
        emit Refund(_id,msg.sender,bal);
    }
}