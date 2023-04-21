// SPDX-License-Identifier: None
pragma solidity ^0.8.19;

import {Titan} from "test-helpers/Titan/Titan.sol";
import {ClancyERC721TestHelpers} from "test-helpers//ClancyERC721TestHelpers.sol";

abstract contract IEscrowERC721_v1_Test is
    ClancyERC721TestHelpers,
    Titan
{
    event EscrowItemCreated(
        uint256 indexed itemId,
        address indexed tokenContract,
        uint256 indexed tokenId,
        address seller
    );

    event EscrowItemPurchaseCreated(
        uint256 indexed itemId,
        address indexed tokenContract,
        uint256 indexed tokenId,
        address seller,
        address buyer
    );

    event EscrowItemCancelled(
        uint256 indexed itemId,
        address indexed tokenContract,
        uint256 indexed tokenId
    );

    event EscrowItemClaimed(
        uint256 indexed itemId,
        address indexed tokenContract,
        uint256 indexed tokenId
    );

    struct EscrowItem {
        uint256 itemId;
        address seller;
        address buyer;
    }
}
