// SPDX-License-Identifier: None
pragma solidity ^0.8.17;

import {TEST_CONSTANTS} from "clancy-test/helpers/TEST_CONSTANTS.sol";
import {ClancyERC721TestHelpers} from "clancy-test/helpers/ClancyERC721TestHelpers.sol";

abstract contract IMarketplaceERC721Escrow_v1_Test is
    ClancyERC721TestHelpers,
    TEST_CONSTANTS
{
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
