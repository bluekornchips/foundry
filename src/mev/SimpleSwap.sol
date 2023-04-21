// SPDX-License-Identifier: None
pragma solidity ^0.8.0;

import {ISwapRouter} from "uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import {TransferHelper} from "uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";

contract SimpleSwap {
    ISwapRouter public immutable swapRouter;
    uint24 public constant feeTier = 3000;

    constructor(ISwapRouter _swapRouter) {
        swapRouter = _swapRouter;
    }

    function swapInput(
        address swapFrom,
        address swapTo,
        uint256 amountIn,
        uint24 poolFee
    ) external returns (uint256 amountOut) {
        // TransferHelper.safeTransferFrom(
        //     swapFrom,
        //     msg.sender,
        //     address(this),
        //     amountIn
        // );
        TransferHelper.safeApprove(swapFrom, address(swapRouter), amountIn);

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
        amountOut = swapRouter.exactInputSingle(params);
    }

    // function swapOutput(
    //     address swapFrom,
    //     address swapTo,
    //     uint256 amountOut,
    //     uint256 amountInMaximum,
    //     uint24 poolFee
    // ) external returns (uint256 amountIn) {
    //     TransferHelper.safeTransferFrom(
    //         swapFrom,
    //         msg.sender,
    //         address(this),
    //         amountInMaximum
    //     );

    //     TransferHelper.safeApprove(
    //         swapFrom,
    //         address(swapRouter),
    //         amountInMaximum
    //     );

    //     ISwapRouter.ExactOutputSingleParams memory params = ISwapRouter
    //         .ExactOutputSingleParams({
    //             tokenIn: swapFrom,
    //             tokenOut: swapTo,
    //             fee: poolFee,
    //             recipient: msg.sender,
    //             deadline: block.timestamp,
    //             amountOut: amountOut,
    //             amountInMaximum: amountInMaximum,
    //             sqrtPriceLimitX96: 0
    //         });

    //     amountIn = swapRouter.exactOutputSingle(params);

    //     if (amountIn < amountInMaximum) {
    //         TransferHelper.safeApprove(swapFrom, address(swapRouter), 0);
    //         TransferHelper.safeTransfer(
    //             swapFrom,
    //             msg.sender,
    //             amountInMaximum - amountIn
    //         );
    //     }
    // }
}
