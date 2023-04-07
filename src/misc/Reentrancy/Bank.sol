// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

contract Bank {
    mapping(address => uint256) private balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdrawVulnerable(uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient funds.");
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed.");
        if (balances[msg.sender] > 0) {
            balances[msg.sender] -= amount;
        }
        // balances[msg.sender] -= amount;
    }

    function getBalance() public view returns (uint256) {
        return balances[msg.sender];
    }
}
