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

        /*
         * https://ethereum.stackexchange.com/questions/142029/reentrancy-attack-fail
         */
        // Option 1
        if (balances[msg.sender] > 0) {
            balances[msg.sender] -= amount;
        }
        // // Option 2
        // unchecked {
        //     balances[msg.sender] -= amount;
        // }

        // // Option 3
        // Will not work because of underflow.
        // balances[msg.sender] -= amount;
    }

    function getBalance() public view returns (uint256) {
        return balances[msg.sender];
    }
}
