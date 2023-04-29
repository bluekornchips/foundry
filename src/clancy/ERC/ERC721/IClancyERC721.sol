// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IClancyERC721 {
    /**
     * Errors
     */
    /// @notice Thrown when the burn functionality is disabled.
    error BurnDisabled();

    /// @notice Thrown when the max supply is invalid.
    error MaxSupply_Invalid();

    /// @notice Thrown when the max supply has been reached.
    error MaxSupply_Reached();

    /// @notice Thrown when the caller is not approved or the owner.
    error NotApprovedOrOwner();

    /// @notice Thrown when public minting is disabled.
    error PublicMintDisabled();

    /**
     * Events
     */
    /// @notice Emitted when the base URI has been changed.
    /// @param newBaseURI The new base URI.
    event BaseURIChanged(string indexed newBaseURI);

    /// @notice Emitted when the burn enabled status is changed.
    /// @param newStatus The new status of burn enabled.
    event BurnEnabledChanged(bool indexed newStatus);

    /// @notice Emitted when the public mint enabled status is changed.
    /// @param newStatus The new status of public mint enabled.
    event PublicMintEnabledChanged(bool indexed newStatus);

    /// @notice Emitted when the max supply is changed.
    /// @param newMaxSupply The new max supply.
    event MaxSupplyChanged(uint32 indexed newMaxSupply);

    // Functions
    function mint() external returns (uint32);
}
