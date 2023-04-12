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

    function getItem(
        address tokenContract,
        uint256 itemId
    ) external view returns (EscrowItem memory);
}
