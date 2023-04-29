// SPDX-License-Identifier: None
pragma solidity ^0.8.19;

import {Address} from "openzeppelin-contracts/contracts/utils/Address.sol";
import {IERC721} from "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import {IERC721Enumerable} from "openzeppelin-contracts/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

import {IClancyERC721, ClancyERC721} from "clancy/ERC/ERC721/ClancyERC721.sol";
import {ClancyMarketplaceERC721} from "clancy/marketplace/ClancyMarketplaceERC721.sol";

import {IEscrowERC721} from "./IEscrowERC721.sol";

contract EscrowERC721 is IEscrowERC721, ClancyMarketplaceERC721 {
    using Address for address;

    uint32 public constant MAX_ITEMS = 1_000;
    uint32 public _activeListings;
    mapping(address => mapping(uint32 => EscrowItem)) public items;

    /**
     * @dev Creates a new EscrowItem and places it in escrow.
     * @param contractAddress The address of the token contract.
     * @param tokenId The unique identifier of the token.
     * @return Returns the unique identifier of the created EscrowItem as a uint32.
     *
     * Emits a {EscrowItemCreated} event indicating a new item has been created.
     * Emits a {Transfer} event indicating the transfer of the token to the escrow contract.
     */
    function createItem(
        address contractAddress,
        uint32 tokenId
    ) public whenNotPaused nonReentrant returns (uint32) {
        if (_activeListings >= MAX_ITEMS) {
            revert EscrowFull();
        }
        if (!vendors[contractAddress]) {
            revert InputContractInvalid();
        }
        if (IERC721(contractAddress).ownerOf(tokenId) != _msgSender()) {
            revert NotTokenOwner();
        }
        if (items[contractAddress][tokenId].buyer != address(0)) {
            revert EscrowItemAlreadyForSale();
        }

        IERC721(contractAddress).safeTransferFrom(
            _msgSender(),
            address(this),
            tokenId
        );

        ++_activeListings;
        ++itemIdCounter;

        items[contractAddress][tokenId] = EscrowItem({
            itemId: itemIdCounter,
            seller: _msgSender(),
            buyer: address(0)
        });

        emit EscrowItemCreated({
            contractAddress: contractAddress,
            tokenId: tokenId,
            seller: _msgSender(),
            itemId: itemIdCounter
        });

        return itemIdCounter;
    }

    /**
     * @dev Cancels a EscrowItem and transfers the token back to the seller.
     * @param contractAddress The address of the ERC721 contract for the token being cancelled.
     * @param tokenId The ID of the token being cancelled.
     * Requirements:
     * - The contract calling this function must be an allowed contract.
     * - The item must exist.
     * - The caller must be the seller of the item.
     * - The item must not have been sold.
     */
    function cancelItem(
        address contractAddress,
        uint32 tokenId
    ) public whenNotPaused nonReentrant {
        if (!vendors[contractAddress]) {
            revert InputContractInvalid();
        }
        EscrowItem storage item = items[contractAddress][tokenId];

        if (item.itemId == 0) {
            revert EscrowItemDoesNotExist();
        }
        /**
         * The token is not approved for transfer by the marketplace during the createItem function.
         * We use the item.seller instead of an approved caller or owner.
         * This prevents the item from being cancelled without clearing the mapping.
         */
        if (item.seller != _msgSender()) {
            revert NotTokenSeller();
        }
        if (item.buyer != address(0)) {
            revert EscrowItemIsSold();
        }
        emit EscrowItemCancelled({
            itemId: item.itemId,
            contractAddress: contractAddress,
            tokenId: tokenId
        });

        delete items[contractAddress][tokenId];

        --_activeListings;

        IERC721(contractAddress).safeTransferFrom(
            address(this),
            _msgSender(),
            tokenId
        );
    }

    /**
     * @dev Creates a EscrowItem purchase by updating the buyer and soldAt timestamp.
     * @param contractAddress The address of the ERC721 contract for the token being purchased.
     * @param tokenId The ID of the token being purchased.
     * @param buyer The address of the buyer making the purchase.
     * Requirements:
     * - The contract calling this function must be the owner.
     * - The contract calling this function must be an allowed contract.
     * - The item must exist and not have been sold.
     * - The buyer must not be the seller or the zero address.
     */
    function createPurchase(
        address contractAddress,
        uint32 tokenId,
        address buyer
    ) public onlyOwner {
        if (!vendors[contractAddress]) {
            revert InputContractInvalid();
        }
        EscrowItem storage item = items[contractAddress][tokenId];

        if (item.buyer != address(0)) {
            revert EscrowItemIsSold();
        }
        if (item.seller == address(0)) {
            revert EscrowItemSellerCannotBeZeroAddress();
        }
        if (item.seller == buyer) {
            revert EscrowItemBuyerCannotBeSeller();
        }
        item.buyer = buyer;

        emit EscrowItemPurchaseCreated({
            itemId: item.itemId,
            contractAddress: contractAddress,
            tokenId: tokenId,
            seller: item.seller,
            buyer: buyer
        });
    }

    /**
     * @dev Claims a purchased EscrowItem and transfers ownership to the buyer.
     * @param contractAddress The address of the ERC721 contract for the token being claimed.
     * @param tokenId The ID of the token being claimed.
     * Requirements:
     * - The contract calling this function must be an allowed contract.
     * - The item must exist and have been sold.
     * - The caller must be the buyer of the item.
     */
    function claimItem(
        address contractAddress,
        uint32 tokenId
    ) public whenNotPaused nonReentrant {
        if (!vendors[contractAddress]) {
            revert InputContractInvalid();
        }

        EscrowItem storage item = items[contractAddress][tokenId];

        if (item.itemId == 0) {
            revert EscrowItemDoesNotExist();
        }
        if (item.buyer == address(0)) {
            revert EscrowItemIsNotSold();
        }
        if (item.buyer != _msgSender()) {
            revert NotTokenBuyer();
        }
        emit EscrowItemClaimed({
            itemId: item.itemId,
            contractAddress: contractAddress,
            tokenId: tokenId
        });

        delete items[contractAddress][tokenId];

        --_activeListings;

        IERC721(contractAddress).safeTransferFrom(
            address(this),
            _msgSender(),
            tokenId
        );
    }

    /**
     * @dev Retrieves the EscrowItem object associated with a given token and token contract.
     * @param tokenContract The address of the token contract.
     * @param tokenId The unique identifier of the token.
     * @return Returns a EscrowItem struct containing the details of the specified token's escrow status.
     */
    function getItem(
        address tokenContract,
        uint32 tokenId
    ) public view returns (EscrowItem memory) {
        return items[tokenContract][tokenId];
    }
}
