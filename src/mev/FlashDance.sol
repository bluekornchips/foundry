// SPDX-License-Identifier: None
pragma solidity ^0.8.0;

import {FlashLoan} from "mev/FlashLoan.sol";
import {SimpleSwap} from "mev/SimpleSwap.sol";

import {ISwapRouter} from "uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

contract FlashDance is FlashLoan, SimpleSwap {
    constructor(
        ISwapRouter _swapRouter,
        address _addressProvider
    ) FlashLoan(_addressProvider) SimpleSwap(_swapRouter) {}
}
