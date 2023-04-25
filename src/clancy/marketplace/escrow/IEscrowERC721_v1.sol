// SPDX-License-Identifier: None
pragma solidity ^0.8.19;

interface IEscrowERC721_v1 {
    error NotTokenSeller();
    error NotTokenBuyer();
    error EscrowFull();
    error EscrowItemIsSold();
    error EscrowItemIsNotSold();
    error EscrowItemDoesNotExist();
    error EscrowItemBuyerCannotBeSeller();
    error EscrowItemAlreadyForSale();
    error EscrowItemSellerCannotBeZeroAddress();

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

    function getItem(
        address tokenContract,
        uint32 itemId
    ) external view returns (EscrowItem memory);
}
