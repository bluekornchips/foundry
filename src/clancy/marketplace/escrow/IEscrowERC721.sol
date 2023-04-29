// SPDX-License-Identifier: None
pragma solidity ^0.8.19;

interface IEscrowERC721 {
    /// @notice Thrown when the caller is not the token seller.
    error NotTokenSeller();

    /// @notice Thrown when the caller is not the token buyer.
    error NotTokenBuyer();

    /// @notice Thrown when the escrow is full.
    error EscrowFull();

    /// @notice Thrown when the escrow item is already sold.
    error EscrowItemIsSold();

    /// @notice Thrown when the escrow item is not sold.
    error EscrowItemIsNotSold();

    /// @notice Thrown when the escrow item does not exist.
    error EscrowItemDoesNotExist();

    /// @notice Thrown when the escrow item buyer is the same as the seller.
    error EscrowItemBuyerCannotBeSeller();

    /// @notice Thrown when the escrow item is already for sale.
    error EscrowItemAlreadyForSale();

    /// @notice Thrown when the escrow item seller's address is the zero address.
    error EscrowItemSellerCannotBeZeroAddress();

    /// @notice Emitted when a new escrow item is created.
    /// @param itemId The ID of the escrow item.
    /// @param tokenId The ID of the token, on the token contract.
    /// @param contractAddress The address of the token contract.
    /// @param seller The address of the seller.
    event EscrowItemCreated(
        uint32 indexed itemId,
        uint32 indexed tokenId,
        address indexed contractAddress,
        address seller
    );

    /// @notice Emitted when a new escrow item purchase is created.
    /// @param itemId The ID of the escrow item.
    /// @param tokenId The ID of the token, on the token contract.
    /// @param contractAddress The address of the token contract.
    /// @param seller The address of the seller.
    /// @param buyer The address of the buyer.
    event EscrowItemPurchaseCreated(
        uint32 indexed itemId,
        uint32 indexed tokenId,
        address indexed contractAddress,
        address seller,
        address buyer
    );

    /// @notice Emitted when an escrow item is cancelled.
    /// @param itemId The ID of the cancelled escrow item.
    /// @param tokenId The ID of the token, on the token contract.
    /// @param contractAddress The address of the token contract.
    event EscrowItemCancelled(
        uint32 indexed itemId,
        uint32 indexed tokenId,
        address indexed contractAddress
    );

    /// @notice Emitted when an escrow item is claimed.
    /// @param itemId The ID of the claimed escrow item.
    /// @param tokenId The ID of the token, on the token contract.
    /// @param contractAddress The address of the token contract.
    event EscrowItemClaimed(
        uint32 indexed itemId,
        uint32 indexed tokenId,
        address indexed contractAddress
    );

    /// @notice An escrow item.
    struct EscrowItem {
        uint32 itemId;
        address seller;
        address buyer;
    }
}
