// SPDX-License-Identifier: None
pragma solidity ^0.8.0;

import {ClancyPayable} from "clancy/utils/ClancyPayable.sol";

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

import {ISwapRouter} from "uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

import {Uniswapper} from "mev/Uniswapper.sol";

// Flash Loan
import {FlashLoanSimpleReceiverBase} from "aave-v3-core/contracts/flashloan/base/FlashLoanSimpleReceiverBase.sol";
import {IPoolAddressesProvider} from "aave-v3-core/contracts/interfaces/IPoolAddressesProvider.sol";
import {IPriceOracle} from "aave-v3-core/contracts/interfaces/IPriceOracle.sol";

contract FlashDance is FlashLoanSimpleReceiverBase, Uniswapper, ClancyPayable {
    constructor(
        ISwapRouter _uniswapper,
        address _aaveAddressProvider
    )
        Uniswapper(_uniswapper)
        FlashLoanSimpleReceiverBase(
            IPoolAddressesProvider(_aaveAddressProvider)
        )
    {}

    //#region Flash Loan

    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator_,
        bytes calldata params_
    ) public override returns (bool) {
        uint256 amountOwed = amount + premium;
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

    function getPriceOracle() public view returns (address) {
        return ADDRESSES_PROVIDER.getPriceOracle();
    }

    function FLASHLOAN_PREMIUM_TO_PROTOCOL() public view returns (uint128) {
        return POOL.FLASHLOAN_PREMIUM_TO_PROTOCOL();
    }

    //#endregion Flash Loan

    function getBalance(address tokenAddress) public view returns (uint256) {
        return IERC20(tokenAddress).balanceOf(address(this));
    }

    function withdraw(address _tokenAddress) public onlyOwner {
        IERC20(_tokenAddress).transfer(owner(), getBalance(_tokenAddress));
    }
}
