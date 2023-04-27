// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IClancyERC20 {
    error PublicMintDisabled();
    error BurnDisabled();
    error Cap_Reached();

    event BurnEnabledChanged(bool indexed);

    function mint(uint256 amount) external;

    function mintTo(address to, uint256 amount) external;
}
