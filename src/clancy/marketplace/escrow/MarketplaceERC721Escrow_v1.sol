// SPDX-License-Identifier: None
pragma solidity ^0.8.17;

import "openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";
import "openzeppelin-contracts/contracts/security/Pausable.sol";
import "openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/utils/introspection/ERC165Checker.sol";
import "./IMarketplaceERC721Escrow_v1.sol";
import "./MarketplaceERC721EscrowStructs_v1.sol";
import "clancy/ERC/ClancyERC721.sol";

contract MarketplaceERC721Escrow_v1 is
    IMarketplaceERC721Escrow_v1,
    IERC721Receiver,
    Ownable,
    Pausable,
    ReentrancyGuard
{
    using Counters for Counters.Counter;
    using Address for address;

    uint32 public constant MAX_ITEMS = 10;
    uint32 private activeListings = 0;
    mapping(address => bool) private _contracts;
    mapping(address => mapping(uint256 => MarketplaceEscrowItem))
        private _items;
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
     * @dev Creates a new MarketplaceEscrowItem and places it in escrow.
     * @param tokenContract The address of the token contract.
     * @param tokenId The unique identifier of the token.
     * @return Returns the unique identifier of the created MarketplaceEscrowItem as a uint256.
     *
     * Emits a {MarketplaceItemCreated} event indicating a new item has been created.
     * Emits a {Transfer} event indicating the transfer of the token to the escrow contract.
     */
    function createItem(
        address tokenContract,
        uint256 tokenId
    ) public whenNotPaused nonReentrant returns (uint256) {
        if (activeListings >= MAX_ITEMS)
            revert MarketplaceERC721Escrow_v1_MarketplaceFull();
        if (!getAllowedContract(tokenContract))
            revert MarketplaceERC721Escrow_v1_InputContractInvalid();
        if (IERC721(tokenContract).ownerOf(tokenId) != _msgSender())
            revert MarketplaceERC721Escrow_v1_NotTokenOwner();
        if (_items[tokenContract][tokenId].soldAt != 0)
            revert MarketplaceERC721Escrow_v1_ItemAlreadyForSale();

        IERC721(tokenContract).safeTransferFrom(
            _msgSender(),
            address(this),
            tokenId
        );

        _itemIdCounter.increment();
        uint256 itemId = _itemIdCounter.current();
        ++activeListings;

        _items[tokenContract][tokenId] = MarketplaceEscrowItem({
            itemId: itemId,
            listedAt: block.timestamp,
            seller: _msgSender(),
            buyer: address(0),
            soldAt: 0
        });

        emit MarketplaceItemCreated({
            listedAt: block.timestamp,
            tokenContract: tokenContract,
            tokenId: tokenId,
            seller: _msgSender(),
            itemId: itemId
        });

        return itemId;
    }

    /**
     * @dev Cancels a MarketplaceEscrowItem and transfers the token back to the seller.
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
        if (!getAllowedContract(tokenContract))
            revert MarketplaceERC721Escrow_v1_InputContractInvalid();

        MarketplaceEscrowItem storage item = _items[tokenContract][tokenId];

        if (item.itemId == 0)
            revert MarketplaceERC721Escrow_v1_ItemDoesNotExist();
        /**
         * The token is not approved for transfer by the marketplace during the createItem function.
         * We use the item.seller instead of an approved caller or owner.
         * This prevents the item from being cancelled without clearing the mapping.
         */
        if (item.seller != _msgSender())
            revert MarketplaceERC721Escrow_v1_NotTokenSeller();

        if (item.buyer != address(0))
            revert MarketplaceERC721Escrow_v1_ItemIsSold();

        delete _items[tokenContract][tokenId];
        --activeListings;

        IERC721(tokenContract).safeTransferFrom(
            address(this),
            _msgSender(),
            tokenId
        );

        emit MarketplaceItemCancelled({
            itemId: item.itemId,
            tokenContract: tokenContract,
            tokenId: tokenId,
            cancelledAt: block.timestamp
        });
    }

    /**
     * @dev Creates a MarketplaceEscrowItem purchase by updating the buyer and soldAt timestamp.
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
        if (!getAllowedContract(tokenContract))
            revert MarketplaceERC721Escrow_v1_InputContractInvalid();

        MarketplaceEscrowItem storage item = _items[tokenContract][tokenId];

        if (item.soldAt != 0) revert MarketplaceERC721Escrow_v1_ItemIsSold();
        if (item.seller == address(0))
            revert MarketplaceERC721Escrow_v1_ItemSellerCannotBeZeroAddress();
        if (item.seller == buyer)
            revert MarketplaceERC721Escrow_v1_ItemBuyerCannotBeSeller();

        item.buyer = buyer;
        item.soldAt = block.timestamp;

        emit MarketplaceItemPurchaseCreated({
            itemId: item.itemId,
            tokenContract: tokenContract,
            tokenId: tokenId,
            soldAt: item.soldAt,
            seller: item.seller,
            buyer: buyer
        });
    }

    /**
     * @dev Claims a purchased MarketplaceEscrowItem and transfers ownership to the buyer.
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
        if (!getAllowedContract(tokenContract))
            revert MarketplaceERC721Escrow_v1_InputContractInvalid();

        MarketplaceEscrowItem storage item = _items[tokenContract][tokenId];

        if (item.itemId == 0)
            revert MarketplaceERC721Escrow_v1_ItemDoesNotExist();
        if (item.soldAt == 0) revert MarketplaceERC721Escrow_v1_ItemIsNotSold();
        if (item.buyer != _msgSender())
            revert MarketplaceERC721Escrow_v1_NotTokenBuyer();

        delete _items[tokenContract][tokenId];
        --activeListings;

        IERC721(tokenContract).safeTransferFrom(
            address(this),
            _msgSender(),
            tokenId
        );

        emit MarketplaceItemClaimed({
            itemId: item.itemId,
            tokenContract: tokenContract,
            tokenId: tokenId,
            claimedAt: block.timestamp
        });
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
            revert MarketplaceERC721Escrow_v1_InputContractInvalid();
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
     * @dev Retrieves the MarketplaceEscrowItem object associated with a given token and token contract.
     * @param tokenContract The address of the token contract.
     * @param tokenId The unique identifier of the token.
     * @return Returns a MarketplaceEscrowItem struct containing the details of the specified token's escrow status.
     */
    function getItem(
        address tokenContract,
        uint256 tokenId
    ) public view returns (MarketplaceEscrowItem memory) {
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
