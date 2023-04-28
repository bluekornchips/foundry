// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {Address} from "openzeppelin-contracts/contracts/utils/Address.sol";

contract ClancyWrappedSent is ERC20 {
    using Address for address payable;

    constructor(
        string memory name_,
        string memory symbol_
    ) ERC20(name_, symbol_) {}

    /// @notice Deposits the specified amount of tokens and mints them to the caller's address.
    /// @param amount The number of tokens to deposit and mint.
    function deposit(uint256 amount) external payable {
        _mint(msg.sender, amount);
    }

    /// @notice Withdraws the specified amount of tokens, burning them and sending the value to the caller's address.
    /// @param amount The number of tokens to withdraw and burn.
    function withdraw(uint256 amount) external {
        _burn(msg.sender, amount);
        payable(msg.sender).sendValue(amount);
    }

    /// @notice Receive fallback function that deposits and mints tokens equal to the sent value.
    receive() external payable {
        _mint(msg.sender, msg.value);
    }
}
