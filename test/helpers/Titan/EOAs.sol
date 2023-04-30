// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract EOAS {
    // Test Addresses
    address public constant w_main = 0x62643f6CAC3E8e8bA332A3D753A0Ce751e1E3C93;
    address public constant w_one = 0x4e560a86f02489117033009B6289200c02A2E70B;

    // Real Addresses
    address public constant w_real = 0x9EE14b0b99BE5a02BbF2dE0138159A9638F9F57C;

    address[] public addrs = [w_main, w_one, w_real];
}
