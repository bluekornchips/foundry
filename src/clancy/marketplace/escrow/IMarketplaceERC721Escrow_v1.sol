// SPDX-License-Identifier: None
pragma solidity ^0.8.17;

interface IMarketplaceERC721Escrow_v1 {
    error MarketplaceERC721Escrow_v1_InputContractInvalid();
    error MarketplaceERC721Escrow_v1_NotTokenOwner();
    error MarketplaceERC721Escrow_v1_NotTokenSeller();
    error MarketplaceERC721Escrow_v1_NotTokenBuyer();
    error MarketplaceERC721Escrow_v1_MarketplaceFull();
    error MarketplaceERC721Escrow_v1_ItemIsSold();
    error MarketplaceERC721Escrow_v1_ItemIsNotSold();
    error MarketplaceERC721Escrow_v1_ItemDoesNotExist();
    error MarketplaceERC721Escrow_v1_ItemBuyerCannotBeSeller();
    error MarketplaceERC721Escrow_v1_ItemAlreadyForSale();
    error MarketplaceERC721Escrow_v1_ItemSellerCannotBeZeroAddress();

    event MarketplaceItemCreated(
        address indexed tokenContract,
        uint256 indexed tokenId,
        uint256 listedAt,
        address seller,
        uint256 itemId
    );

    event MarketplaceItemPurchaseCreated(
        uint256 itemId,
        address indexed tokenContract,
        uint256 indexed tokenId,
        uint256 soldAt,
        address seller,
        address buyer
    );

    event MarketplaceItemCancelled(
        uint256 itemId,
        address indexed tokenContract,
        uint256 indexed tokenId,
        uint256 cancelledAt
    );

    event MarketplaceItemClaimed(
        uint256 itemId,
        address indexed tokenContract,
        uint256 indexed tokenId,
        uint256 claimedAt
    );
}
