// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IClancyERC20 {
    /**
     * Errors
     */

    /// @notice Thrown when the burn functionality is disabled.
    error BurnDisabled();

    /// @notice Thrown when the cap has been reached.
    error Cap_Reached();

    /// @notice Thrown when public minting is disabled.
    error PublicMintDisabled();

    error InitialSupplyExceedsCap();
    error CapCannotBeZero();

    /**
     * Events
     */
    /// @notice Emitted when the burn enabled status is changed.
    /// @param newStatus The new status of burn enabled.
    event BurnEnabledChanged(bool indexed newStatus);
}
