// SPDX-License-Identifier: None
pragma solidity ^0.8.17;

struct MarketplaceEscrowItem {
    uint256 itemId;
    uint256 tokenId;
    uint256 listedAt;
    uint256 soldAt;
    address tokenContract;
    address seller;
    address buyer;
    bool isSold;
    bool isClaimed;
}
