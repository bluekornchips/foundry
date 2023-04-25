// SPDX-License-Identifier: None
pragma solidity ^0.8.19;

import {Titan} from "test-helpers/Titan/Titan.sol";
import {ClancyERC721TestHelpers} from "test-helpers//ClancyERC721TestHelpers.sol";

abstract contract IEscrowERC721_v1_Test is ClancyERC721TestHelpers, Titan {
    event EscrowItemCreated(
        uint32 indexed itemId,
        uint32 indexed tokenId,
        address indexed tokenContract,
        address seller
    );

    event EscrowItemPurchaseCreated(
        uint32 indexed itemId,
        uint32 indexed tokenId,
        address indexed tokenContract,
        address seller,
        address buyer
    );

    event EscrowItemCancelled(
        uint32 indexed itemId,
        uint32 indexed tokenId,
        address indexed tokenContract
    );

    event EscrowItemClaimed(
        uint32 indexed itemId,
        uint32 indexed tokenId,
        address indexed tokenContract
    );

    struct EscrowItem {
        uint32 itemId;
        address seller;
        address buyer;
    }
}
