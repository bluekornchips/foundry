// SPDX-License-Identifier: None
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "clancy-test/helpers/ClancyERC721TestHelpers.sol";
import "clancy/marketplace/escrow/MarketplaceERC721Escrow_v1.sol";

contract IMarketplaceERC721Escrow_v1_Test is Test, ClancyERC721TestHelpers {
    event MarketplaceItemCreated(
        uint256 indexed itemId,
        address indexed tokenContract,
        uint256 indexed tokenId,
        address seller
    );

    event MarketplaceItemPurchaseCreated(
        uint256 indexed itemId,
        address indexed tokenContract,
        uint256 indexed tokenId,
        address seller,
        address buyer
    );

    event MarketplaceItemCancelled(
        uint256 indexed itemId,
        address indexed tokenContract,
        uint256 indexed tokenId
    );

    event MarketplaceItemClaimed(
        uint256 indexed itemId,
        address indexed tokenContract,
        uint256 indexed tokenId
    );

    struct MarketplaceItem {
        uint256 itemId;
        address seller;
        address buyer;
    }
}
