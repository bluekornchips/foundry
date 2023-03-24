// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IClancyERC721 {
    error PublicMintDisabled();
    error BurnDisabled();
    error NotApprovedOrOwner();
    error MaxSupply_AboveCeiling();
    error MaxSupply_CannotBeDecreased();
    error MaxSupply_LowerThanCurrentSupply();
    error MaxSupply_LTEZero();
    error MaxSupply_Reached();

    event MaxSupplyChanged(uint256 indexed);
    event BaseURIChanged(string indexed, string indexed);
    event BurnStatusChanged(bool indexed);

    function mint() external returns (uint256);

    // function mintTo(address to_) external returns (uint256);
}
