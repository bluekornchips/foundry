// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IClancyERC20 {
    /**
     * Errors
     */
    /// @notice Thrown when public minting is disabled.
    error PublicMintDisabled();

    /// @notice Thrown when the burn functionality is disabled.
    error BurnDisabled();

    /// @notice Thrown when the cap has been reached.
    error Cap_Reached();

    /**
     * Events
     */
    /// @notice Emitted when the burn enabled status is changed.
    /// @param newStatus The new status of burn enabled.
    event BurnEnabledChanged(bool indexed newStatus);

    /**
     * Functions
     */
    /// @notice Mints the specified amount of tokens to the caller's address.
    /// @param amount The number of tokens to mint.
    function mint(uint256 amount) external;

    /// @notice Mints the specified amount of tokens to the provided address.
    /// @param to The address to receive the minted tokens.
    /// @param amount The number of tokens to mint.
    function mintTo(address to, uint256 amount) external;
}
