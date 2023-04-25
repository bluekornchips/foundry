// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IClancyERC721 {
    // Errors
    error BurnDisabled();
    error MaxSupply_AboveCeiling();
    error MaxSupply_CannotBeDecreased();
    error MaxSupply_LowerThanCurrentSupply();
    error MaxSupply_LTEZero();
    error MaxSupply_Reached();
    error NotApprovedOrOwner();
    error PublicMintDisabled();

    // Events
    event BaseURIChanged(string indexed, string indexed);
    event BurnStatusChanged(bool indexed);
    event MaxSupplyChanged(uint32 indexed);

    // Functions
    function mint() external returns (uint32);
}
