// SPDX-License-Identifier: None
pragma solidity ^0.8.19;

interface IMarketplaceERC721Escrow_v1 {
    error InputContractInvalid();
    error NotTokenOwner();
    error NotTokenSeller();
    error NotTokenBuyer();
    error MarketplaceFull();
    error ItemIsSold();
    error ItemIsNotSold();
    error ItemDoesNotExist();
    error ItemBuyerCannotBeSeller();
    error ItemAlreadyForSale();
    error ItemSellerCannotBeZeroAddress();

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

    function getItem(
        address tokenContract,
        uint256 itemId
    ) external view returns (MarketplaceItem memory);
}
