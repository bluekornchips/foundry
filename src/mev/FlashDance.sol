// SPDX-License-Identifier: None
pragma solidity ^0.8.0;

import {ClancyPayable} from "clancy/utils/ClancyPayable.sol";

// Flash Loan
import {FlashLoanSimpleReceiverBase} from "aave-v3-core/contracts/flashloan/base/FlashLoanSimpleReceiverBase.sol";
import {IPoolAddressesProvider} from "aave-v3-core/contracts/interfaces/IPoolAddressesProvider.sol";
import {IPriceOracle} from "aave-v3-core/contracts/interfaces/IPriceOracle.sol";

import {Address} from "openzeppelin-contracts/contracts/utils/Address.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

// Swap
import {ISwapRouter} from "uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import {TransferHelper} from "uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";

contract FlashDance is FlashLoanSimpleReceiverBase, ClancyPayable {
    // Flash Loan
    address private from;
    address private to;
    uint24 private swapFee_;

    // Swap
    ISwapRouter private immutable aave_swapRouter_;
    uint24 public constant feeTier = 3000;

    constructor(
        ISwapRouter _swapRouter,
        address _addressProvider
    ) FlashLoanSimpleReceiverBase(IPoolAddressesProvider(_addressProvider)) {
        aave_swapRouter_ = _swapRouter;
    }

    //#region FlashLoan
    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator_,
        bytes calldata params_
    ) public override returns (bool) {
        uint256 amountOwed = amount + premium;
        uint256 spendable = amount - premium;

        // Perform Swap
        uint256 balanceHolder = getBalance(to);
        swapInput(from, to, spendable, swapFee_);
        balanceHolder = getBalance(to);

        // End Steps
        IERC20(asset).approve(address(POOL), amountOwed);
        return true;
    }

    function requestFlashLoan(address _token, uint256 _amount) public {
        address receiverAddress = address(this);
        address asset = _token;
        uint256 amount = _amount;
        bytes memory params = "";
        uint16 referralCode = 0;
        POOL.flashLoanSimple(
            receiverAddress,
            asset,
            amount,
            params,
            referralCode
        );
    }

    //#endregion

    //#region Swap
    function setupSwap(address _from, address _to, uint24 _swapFee) public {
        from = _from;
        to = _to;
        swapFee_ = _swapFee;
    }

    function swapInput(
        address swapFrom,
        address swapTo,
        uint256 amountIn,
        uint24 poolFee
    ) internal returns (uint256 amountOut) {
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

    function getBalance(address tokenAddress) public view returns (uint256) {
        return IERC20(tokenAddress).balanceOf(address(this));
    }

    function withdraw(address _tokenAddress) public onlyOwner {
        IERC20(_tokenAddress).transfer(owner(), getBalance(_tokenAddress));
    }

    function getPriceOracle() public view returns (address) {
        return ADDRESSES_PROVIDER.getPriceOracle();
    }

    function FLASHLOAN_PREMIUM_TO_PROTOCOL() public view returns (uint128) {
        return POOL.FLASHLOAN_PREMIUM_TO_PROTOCOL();
    }
    //#endregion Swap
}
