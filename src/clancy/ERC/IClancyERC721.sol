// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IClancyERC721 {
    function mint() external returns (uint96);

    // function mintTo(address to_) external returns (uint256);
}
