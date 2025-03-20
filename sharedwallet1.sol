// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SecretSanta {
    address public owner;
    address[] public participants;
    mapping(address => address) public assignedGifts;
    bool public exchangeStarted;
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
    function joinExchange() external {
        require(!exchangeStarted, "Exchange already started");
        participants.push(msg.sender);
    }
    
    function startExchange() external onlyOwner {
        require(participants.length > 1, "Not enough participants");
        exchangeStarted = true;
        shuffleAndAssign();
    }
    
    function shuffleAndAssign() private {
        uint256 len = participants.length;
        address[] memory shuffled = participants;
        for (uint256 i = 0; i < len; i++) {
            uint256 j = i + uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, i))) % (len - i);
            (shuffled[i], shuffled[j]) = (shuffled[j], shuffled[i]);
        }
        
        for (uint256 i = 0; i < len; i++) {
            assignedGifts[shuffled[i]] = shuffled[(i + 1) % len];
        }
    }
    
    function getAssignedRecipient() external view returns (address) {
        require(exchangeStarted, "Exchange not started");
        return assignedGifts[msg.sender];
    }
}
