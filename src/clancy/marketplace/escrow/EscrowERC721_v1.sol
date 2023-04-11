// SPDX-License-Identifier: None
pragma solidity ^0.8.19;

import {Address} from "openzeppelin-contracts/contracts/utils/Address.sol";
import {Counters} from "openzeppelin-contracts/contracts/utils/Counters.sol";

import {IERC721} from "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import {IERC721Enumerable} from "openzeppelin-contracts/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

import {IClancyERC721, ClancyERC721} from "clancy/ERC/ClancyERC721.sol";
import {ClancyMarketplaceERC721_v1} from "clancy/marketplace/ClancyMarketplaceERC721_v1.sol";

import {IEscrowERC721_v1} from "./IEscrowERC721_v1.sol";

contract EscrowERC721_v1 is IEscrowERC721_v1, ClancyMarketplaceERC721_v1 {
    using Counters for Counters.Counter;
    using Address for address;

    uint32 public constant MAX_ITEMS = 1_000;
    Counters.Counter private _activeListings;
    mapping(address => mapping(uint256 => EscrowItem)) private _items;
    Counters.Counter private _itemIdCounter;

    /**
     * @dev Creates a new EscrowItem and places it in escrow.
     * @param tokenContract The address of the token contract.
     * @param tokenId The unique identifier of the token.
     * @return Returns the unique identifier of the created EscrowItem as a uint256.
     *
     * Emits a {EscrowItemCreated} event indicating a new item has been created.
     * Emits a {Transfer} event indicating the transfer of the token to the escrow contract.
     */
    function createItem(
        address tokenContract,
        uint256 tokenId
    ) public whenNotPaused nonReentrant returns (uint256) {
        if (_activeListings.current() >= MAX_ITEMS) revert EscrowFull();
        if (!getAllowedContract(tokenContract)) revert InputContractInvalid();
        if (IERC721(tokenContract).ownerOf(tokenId) != _msgSender())
            revert NotTokenOwner();
        if (_items[tokenContract][tokenId].buyer != address(0))
            revert EscrowItemAlreadyForSale();

        IERC721(tokenContract).safeTransferFrom(
            _msgSender(),
            address(this),
            tokenId
        );

        _activeListings.increment();
        _itemIdCounter.increment();

        uint256 itemId = _itemIdCounter.current();

        _items[tokenContract][tokenId] = EscrowItem({
            itemId: itemId,
            seller: _msgSender(),
            buyer: address(0)
        });

        emit EscrowItemCreated({
            tokenContract: tokenContract,
            tokenId: tokenId,
            seller: _msgSender(),
            itemId: itemId
        });

        return itemId;
    }

    /**
     * @dev Cancels a EscrowItem and transfers the token back to the seller.
     * @param tokenContract The address of the ERC721 contract for the token being cancelled.
     * @param tokenId The ID of the token being cancelled.
     * Requirements:
     * - The contract calling this function must be an allowed contract.
     * - The item must exist.
     * - The caller must be the seller of the item.
     * - The item must not have been sold.
     */
    function cancelItem(
        address tokenContract,
        uint256 tokenId
    ) public whenNotPaused nonReentrant {
        if (!getAllowedContract(tokenContract)) revert InputContractInvalid();

        EscrowItem storage item = _items[tokenContract][tokenId];

        if (item.itemId == 0) revert EscrowItemDoesNotExist();
        /**
         * The token is not approved for transfer by the marketplace during the createItem function.
         * We use the item.seller instead of an approved caller or owner.
         * This prevents the item from being cancelled without clearing the mapping.
         */
        if (item.seller != _msgSender()) revert NotTokenSeller();
        if (item.buyer != address(0)) revert EscrowItemIsSold();

        emit EscrowItemCancelled({
            itemId: item.itemId,
            tokenContract: tokenContract,
            tokenId: tokenId
        });

        delete _items[tokenContract][tokenId];

        _activeListings.decrement();

        IERC721(tokenContract).safeTransferFrom(
            address(this),
            _msgSender(),
            tokenId
        );
    }

    /**
     * @dev Creates a EscrowItem purchase by updating the buyer and soldAt timestamp.
     * @param tokenContract The address of the ERC721 contract for the token being purchased.
     * @param tokenId The ID of the token being purchased.
     * @param buyer The address of the buyer making the purchase.
     * Requirements:
     * - The contract calling this function must be the owner.
     * - The contract calling this function must be an allowed contract.
     * - The item must exist and not have been sold.
     * - The buyer must not be the seller or the zero address.
     */
    function createPurchase(
        address tokenContract,
        uint256 tokenId,
        address buyer
    ) public onlyOwner {
        if (!getAllowedContract(tokenContract)) revert InputContractInvalid();

        EscrowItem storage item = _items[tokenContract][tokenId];

        if (item.buyer != address(0)) revert EscrowItemIsSold();
        if (item.seller == address(0))
            revert EscrowItemSellerCannotBeZeroAddress();
        if (item.seller == buyer) revert EscrowItemBuyerCannotBeSeller();

        item.buyer = buyer;

        emit EscrowItemPurchaseCreated({
            itemId: item.itemId,
            tokenContract: tokenContract,
            tokenId: tokenId,
            seller: item.seller,
            buyer: buyer
        });
    }

    /**
     * @dev Claims a purchased EscrowItem and transfers ownership to the buyer.
     * @param tokenContract The address of the ERC721 contract for the token being claimed.
     * @param tokenId The ID of the token being claimed.
     * Requirements:
     * - The contract calling this function must be an allowed contract.
     * - The item must exist and have been sold.
     * - The caller must be the buyer of the item.
     */
    function claimItem(
        address tokenContract,
        uint256 tokenId
    ) public whenNotPaused nonReentrant {
        if (!getAllowedContract(tokenContract)) revert InputContractInvalid();

        EscrowItem storage item = _items[tokenContract][tokenId];

        if (item.itemId == 0) revert EscrowItemDoesNotExist();
        if (item.buyer == address(0)) revert EscrowItemIsNotSold();
        if (item.buyer != _msgSender()) revert NotTokenBuyer();

        emit EscrowItemClaimed({
            itemId: item.itemId,
            tokenContract: tokenContract,
            tokenId: tokenId
        });

        delete _items[tokenContract][tokenId];

        _activeListings.decrement();

        IERC721(tokenContract).safeTransferFrom(
            address(this),
            _msgSender(),
            tokenId
        );
    }

    /**
     * @dev Retrieves the current value of the item ID counter.
     * @return Returns the current value of the item ID counter as a uint256.
     */
    function getItemIdCounter() public view returns (uint256) {
        return _itemIdCounter.current();
    }

    /**
     * @dev Retrieves the EscrowItem object associated with a given token and token contract.
     * @param tokenContract The address of the token contract.
     * @param tokenId The unique identifier of the token.
     * @return Returns a EscrowItem struct containing the details of the specified token's escrow status.
     */
    function getItem(
        address tokenContract,
        uint256 tokenId
    ) public view override returns (EscrowItem memory) {
        return _items[tokenContract][tokenId];
    }
}
