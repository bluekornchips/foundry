// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

contract ClancyERC20TestHelpers {
    string public constant NAME = "ClancyERC20";
    string public constant SYMBOL = "CERC20";
    uint256 public constant INITIAL_SUPPLY = 1_000_000 * 10 ** 18;
    uint256 public constant CAP = 1_000_000_000 * 10 ** 18;

    receive() external payable {}
}
