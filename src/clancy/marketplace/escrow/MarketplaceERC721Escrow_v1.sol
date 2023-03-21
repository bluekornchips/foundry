// SPDX-License-Identifier: None
pragma solidity ^0.8.17;

import "openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";
import "openzeppelin-contracts/contracts/security/Pausable.sol";
import "openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/utils/introspection/ERC165Checker.sol";
import "./MarketplaceERC721EscrowStructs_v1.sol";
import "clancy/ERC/ClancyERC721.sol";

error InputContractInvalid(string message);
error NotTokenOwnerOrApproved(string message);
error PriceTooHigh(string message);

contract MarketplaceERC721Escrow_v1 is
    IERC721Receiver,
    Ownable,
    Pausable,
    ReentrancyGuard
{
    using Counters for Counters.Counter;
    using Address for address;

    uint96 public constant MAX_PRICE = 1_000_000_000 ether;

    mapping(address => bool) private _contracts;
    mapping(uint256 => MarketplaceEscrowItem) private _items;
    Counters.Counter private _itemIdCounter;

    event MarketplaceItemCreated(
        uint256 indexed itemId,
        uint256 indexed tokenId,
        uint256 listedAt,
        address indexed tokenContract,
        address seller,
        address buyer,
        bool isSold,
        bool isClaimed,
        uint256 price
    );

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

    function createItem(
        address tokenContract,
        uint256 tokenId,
        uint96 price
    ) public whenNotPaused nonReentrant {
        if (!getAllowedContract(tokenContract))
            revert InputContractInvalid({
                message: "MarketplaceERC721Escrow_v1: Token contract is not allowed."
            });

        if (IERC721(tokenContract).ownerOf(tokenId) != _msgSender())
            revert NotTokenOwnerOrApproved({
                message: "MarketplaceERC721Escrow_v1: Not token owner or approved."
            });

        if (price > MAX_PRICE)
            revert PriceTooHigh({
                message: "MarketplaceERC721Escrow_v1: Price too high."
            });

        _itemIdCounter.increment();

        _items[_itemIdCounter.current()] = MarketplaceEscrowItem({
            itemId: _itemIdCounter.current(),
            tokenId: tokenId,
            listedAt: block.timestamp,
            soldAt: 0,
            tokenContract: tokenContract,
            seller: _msgSender(),
            buyer: address(0),
            isSold: false,
            isClaimed: false
        });

        IERC721(tokenContract).safeTransferFrom(
            _msgSender(),
            address(this),
            tokenId
        );

        emit MarketplaceItemCreated(
            _itemIdCounter.current(),
            tokenId,
            block.timestamp,
            tokenContract,
            _msgSender(),
            address(0),
            false,
            false,
            price
        );
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
            revert InputContractInvalid({
                message: "MarketplaceERC721Escrow_v1: Address is not an ERC721 contract."
            });
        _contracts[tokenContract] = allowed;
    }
}
