// SPDX-License-Identifier: None
pragma solidity ^0.8.0;

import {FlashLoanSimpleReceiverBase} from "aave-v3-core/contracts/flashloan/base/FlashLoanSimpleReceiverBase.sol";
import {IPoolAddressesProvider} from "aave-v3-core/contracts/interfaces/IPoolAddressesProvider.sol";
import {IPriceOracle} from "aave-v3-core/contracts/interfaces/IPriceOracle.sol";

import {Address} from "openzeppelin-contracts/contracts/utils/Address.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

import {ClancyPayable} from "clancy/utils/ClancyPayable.sol";

contract FlashLoan is FlashLoanSimpleReceiverBase, ClancyPayable {
    constructor(
        address _addressProvider
    ) FlashLoanSimpleReceiverBase(IPoolAddressesProvider(_addressProvider)) {}

    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator_,
        bytes calldata params_
    ) public override returns (bool) {
        uint256 amountOwed = amount + premium;
        address initiator = initiator_;

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

    function getBalance(address tokenAddress) public view returns (uint256) {
        return IERC20(tokenAddress).balanceOf(address(this));
    }

    function withdraw(address _tokenAddress) public onlyOwner {
        IERC20(_tokenAddress).transfer(owner(), getBalance(_tokenAddress));
    }

    function getPriceOracle() public view returns (address) {
        return ADDRESSES_PROVIDER.getPriceOracle();
    }

    function getMaxFlashLoanAmount(
        address _token
    ) public view returns (uint256) {
        return POOL.FLASHLOAN_PREMIUM_TO_PROTOCOL();
    }
}
