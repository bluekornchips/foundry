// SPDX-License-Identifier: None
pragma solidity ^0.8.17;

struct MarketplaceEscrowItem {
    uint256 itemId;
    uint256 listedAt;
    address seller;
    address buyer;
    uint256 soldAt;
}

//TODO: REDUCE VARIABLE SIZES
