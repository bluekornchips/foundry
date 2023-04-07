// SPDX-License-Identifier: None
pragma solidity ^0.8.19;

import {Address} from "openzeppelin-contracts/contracts/utils/Address.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {Counters} from "openzeppelin-contracts/contracts/utils/Counters.sol";
import {Pausable} from "openzeppelin-contracts/contracts/security/Pausable.sol";
import {IERC721} from "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import {ReentrancyGuard} from "openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";
import {IERC721Receiver} from "openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";
import {ERC165Checker} from "openzeppelin-contracts/contracts/utils/introspection/ERC165Checker.sol";
import {IERC721Enumerable} from "openzeppelin-contracts/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

import {IClancyERC721, ClancyERC721} from "clancy/ERC/ClancyERC721.sol";

import {IMarketplaceERC721Escrow_v1} from "./IMarketplaceERC721Escrow_v1.sol";

contract MarketplaceERC721Escrow_v1 is
    IMarketplaceERC721Escrow_v1,
    IERC721Receiver,
    Ownable,
    Pausable,
    ReentrancyGuard
{
    using Counters for Counters.Counter;
    using Address for address;

    uint32 public constant MAX_ITEMS = 1_000;
    Counters.Counter private _activeListings;
    mapping(address => bool) private _contracts;
    mapping(address => mapping(uint256 => MarketplaceItem)) private _items;
    Counters.Counter private _itemIdCounter;

    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual returns (bytes4) {
        return this.onERC721Received.selector;
    }

    /**
     * @dev Creates a new MarketplaceItem and places it in escrow.
     * @param tokenContract The address of the token contract.
     * @param tokenId The unique identifier of the token.
     * @return Returns the unique identifier of the created MarketplaceItem as a uint256.
     *
     * Emits a {MarketplaceItemCreated} event indicating a new item has been created.
     * Emits a {Transfer} event indicating the transfer of the token to the escrow contract.
     */
    function createItem(
        address tokenContract,
        uint256 tokenId
    ) public whenNotPaused nonReentrant returns (uint256) {
        if (_activeListings.current() >= MAX_ITEMS) revert MarketplaceFull();
        if (!getAllowedContract(tokenContract)) revert InputContractInvalid();
        if (IERC721(tokenContract).ownerOf(tokenId) != _msgSender())
            revert NotTokenOwner();
        if (_items[tokenContract][tokenId].buyer != address(0))
            revert ItemAlreadyForSale();

        IERC721(tokenContract).safeTransferFrom(
            _msgSender(),
            address(this),
            tokenId
        );

        _activeListings.increment();
        _itemIdCounter.increment();

        uint256 itemId = _itemIdCounter.current();

        _items[tokenContract][tokenId] = MarketplaceItem({
            itemId: itemId,
            seller: _msgSender(),
            buyer: address(0)
        });

        emit MarketplaceItemCreated({
            tokenContract: tokenContract,
            tokenId: tokenId,
            seller: _msgSender(),
            itemId: itemId
        });

        return itemId;
    }

    /**
     * @dev Cancels a MarketplaceItem and transfers the token back to the seller.
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

        MarketplaceItem storage item = _items[tokenContract][tokenId];

        if (item.itemId == 0) revert ItemDoesNotExist();
        /**
         * The token is not approved for transfer by the marketplace during the createItem function.
         * We use the item.seller instead of an approved caller or owner.
         * This prevents the item from being cancelled without clearing the mapping.
         */
        if (item.seller != _msgSender()) revert NotTokenSeller();
        if (item.buyer != address(0)) revert ItemIsSold();

        emit MarketplaceItemCancelled({
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
     * @dev Creates a MarketplaceItem purchase by updating the buyer and soldAt timestamp.
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

        MarketplaceItem storage item = _items[tokenContract][tokenId];

        if (item.buyer != address(0)) revert ItemIsSold();
        if (item.seller == address(0)) revert ItemSellerCannotBeZeroAddress();
        if (item.seller == buyer) revert ItemBuyerCannotBeSeller();

        item.buyer = buyer;

        emit MarketplaceItemPurchaseCreated({
            itemId: item.itemId,
            tokenContract: tokenContract,
            tokenId: tokenId,
            seller: item.seller,
            buyer: buyer
        });
    }

    /**
     * @dev Claims a purchased MarketplaceItem and transfers ownership to the buyer.
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

        MarketplaceItem storage item = _items[tokenContract][tokenId];

        if (item.itemId == 0) revert ItemDoesNotExist();
        if (item.buyer == address(0)) revert ItemIsNotSold();
        if (item.buyer != _msgSender()) revert NotTokenBuyer();

        emit MarketplaceItemClaimed({
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
     * @dev Pauses the contract.
     *
     * Requirements:
     * - The contract must not already be paused.
     * - Can only be called by the owner of the contract.
     */
    function pause() public onlyOwner {
        _pause();
    }

    /**
     * @dev Unpauses the contract.
     *
     * Requirements:
     * - The contract must be paused.
     * - Can only be called by the owner of the contract.
     */
    function unpause() public onlyOwner {
        _unpause();
    }

    /**
     * @dev Allows the owner to set whether a particular token contract is allowed to participate in the marketplace.
     * @param tokenContract The address of the token contract to set the allowed status for.
     * @param allowed The allowed status to set for the token contract.
     *
     * Requirements:
     * - Only the owner can call this function.
     * - The token contract must implement the ERC721 standard.
     */
    function setAllowedContract(
        address tokenContract,
        bool allowed
    ) public onlyOwner {
        if (!ERC165Checker.supportsERC165(tokenContract))
            revert InputContractInvalid();
        _contracts[tokenContract] = allowed;
    }

    /**
     * @dev Retrieves the current value of the item ID counter.
     * @return Returns the current value of the item ID counter as a uint256.
     */
    function getItemIdCounter() public view returns (uint256) {
        return _itemIdCounter.current();
    }

    /**
     * @dev Retrieves the MarketplaceItem object associated with a given token and token contract.
     * @param tokenContract The address of the token contract.
     * @param tokenId The unique identifier of the token.
     * @return Returns a MarketplaceItem struct containing the details of the specified token's escrow status.
     */
    function getItem(
        address tokenContract,
        uint256 tokenId
    ) public view override returns (MarketplaceItem memory) {
        return _items[tokenContract][tokenId];
    }

    /**
     * @dev Returns whether a particular token contract is allowed to participate in the marketplace.
     * @param tokenContract The address of the token contract to get the allowed status for.
     * @return A boolean indicating whether the token contract is allowed to participate in the marketplace.
     */
    function getAllowedContract(
        address tokenContract
    ) public view returns (bool) {
        return _contracts[tokenContract];
    }
}
