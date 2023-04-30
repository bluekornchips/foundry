// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

interface IClancyERC20Airdrop {
    /// @notice Input array is outside permitted bounds, as defined by MAX_DROPS.
    error AirdropLengthInvalid();

    /// @notice Transfer failed.
    error TransferFailed();

    /// @notice Zero balance transfer. To prevent zero balance attacks.
    error ZeroBalanceTransfer();

    /**
     * @dev  Easy struct management for airdrop delivery.
     *       More efficient than passing two arrays in testing.
     * @param recipient The address to receive the airdrop.
     * @param value The amount of tokens to send.
     */
    struct ERC20Package {
        address recipient;
        uint256 value;
    }
}
