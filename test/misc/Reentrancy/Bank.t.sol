// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";

import {Bank} from "misc/Reentrancy/Bank.sol";
import {BankAttacker} from "misc/Reentrancy/BankAttacker.sol";

import {Titan} from "test-helpers/Titan/Titan.sol";

contract Bank_Test is Test, Titan {
    Bank bank;
    BankAttacker bankAttacker;

    uint256 public initialBalance = 100 ether;

    function setUp() public {
        bank = new Bank();
        bankAttacker = new BankAttacker();
    }

    function test_deposit() public {
        bank.deposit{value: initialBalance}();
        assertEq(bank.getBalance(), initialBalance);
    }

    function test_attack() public {
        bank.deposit{value: initialBalance}();
        assertEq(bank.getBalance(), initialBalance);

        uint256 withdrawAmount = 10 ether;

        console.log("Balance of Bank before: %s", address(bank).balance);
        bankAttacker.setBank(address(bank));
        bankAttacker.attack{value: withdrawAmount}();
        console.log("Balance of Bank after: %s", address(bank).balance);
    }
}
