// SPDX-License-Identifier: None
pragma solidity ^0.8.0;

import {Address} from "openzeppelin-contracts/contracts/utils/Address.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";

import {ISwapRouter} from "uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import {TransferHelper} from "uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";

contract Uniswapper is Ownable {
    address private from;
    address private to;
    uint24 private swapFee_;

    ISwapRouter private immutable aave_swapRouter_;
    uint24 public constant feeTier = 3000;

    constructor(ISwapRouter _swapRouter) {
        aave_swapRouter_ = _swapRouter;
    }

    function swapInput(
        address swapFrom,
        address swapTo,
        uint256 amountIn,
        uint24 poolFee
    ) public returns (uint256 amountOut) {
        TransferHelper.safeApprove(
            swapFrom,
            address(aave_swapRouter_),
            amountIn
        );

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: swapFrom,
                tokenOut: swapTo,
                fee: poolFee,
                recipient: address(this),
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });
        // The call to `exactInputSingle` executes the swap.
        amountOut = aave_swapRouter_.exactInputSingle(params);
    }
}
