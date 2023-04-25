// SPDX-License-Identifier: None
pragma solidity ^0.8.19;

import {IERC721} from "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

import {ClancyPayable} from "clancy/utils/ClancyPayable.sol";
import {IOffersERC721_v1} from "clancy/marketplace/offers/IOffersERC721_v1.sol";
import {ClancyMarketplaceERC721_v1} from "clancy/marketplace/ClancyMarketplaceERC721_v1.sol";

contract OffersERC721_v1 is
    ClancyMarketplaceERC721_v1,
    IOffersERC721_v1,
    ClancyPayable
{
    /**
     * @dev Mapping of token contract addresses to token IDs to OfferItem structs, representing offers
     */
    mapping(address => mapping(uint256 => OfferItem)) private _items;

    /**
     * @notice Creates a new offer or outbids an existing offer for a specific token in a specific contract
     * @dev This function is public and can only be called when the contract is not paused
     * @param contractAddress_ The address of the token contract
     * @param tokenId The ID of the token for which to create or outbid the offer
     */
    function createOffer(
        address contractAddress_,
        uint32 tokenId
    ) public payable whenNotPaused {
        uint256 value = msg.value;
        if (value <= 0) {
            revert OfferCannotBeLTEZero();
        }
        if (!getAllowedContract(contractAddress_)) {
            revert InputContractInvalid();
        }
        if (msg.sender == address(0)) {
            revert OfferorCannotBeZeroAddress();
        }
        address ownerOfToken = IERC721(contractAddress_).ownerOf(tokenId); // Will revert if token does not exist
        if (ownerOfToken == msg.sender) {
            revert OfferorCannotBeTokenOwner();
        }
        OfferItem storage existingItem = _items[contractAddress_][tokenId];

        if (existingItem.offeror != address(0)) {
            if (value <= existingItem.offerAmount) {
                revert OfferMustBeGTExistingOffer();
            }
            outbidOffer(contractAddress_, tokenId, msg.sender, value);
        } else {
            newOffer(contractAddress_, tokenId, ownerOfToken, value);
        }
    }

    /**
     * @notice Accepts an existing offer for a specific token in a specific contract
     * @dev This function is public and can only be called by the token owner
     * @param contractAddress_ The address of the token contract
     * @param tokenId The ID of the token for which to accept the offer
     */
    function acceptOffer(
        address contractAddress_,
        uint256 tokenId
    ) public whenNotPaused {
        OfferItem storage item = _items[contractAddress_][tokenId];
        if (item.itemId <= 0) {
            revert OfferDoesNotExist();
        }
        if (IERC721(contractAddress_).ownerOf(tokenId) != msg.sender) {
            revert NotTokenOwner();
        }
        if (address(this).balance < item.offerAmount) {
            revert InsufficientContractBalance();
        }

        uint256 offerAmount = item.offerAmount;
        address offeror = item.offeror;
        uint256 itemId = item.itemId;

        delete _items[contractAddress_][tokenId];

        (bool success, ) = msg.sender.call{value: offerAmount}("");
        if (!success) {
            revert TransferFailed(
                "OffersERC721_v1: Offer amount failed to transfer."
            );
        }

        IERC721(contractAddress_).safeTransferFrom(
            msg.sender,
            offeror,
            tokenId
        );

        emit OfferEvent({
            offerType: "Accept",
            itemId: itemId,
            contractAddress: contractAddress_,
            tokenId: tokenId,
            tokenOwner: msg.sender,
            offeror: offeror,
            value: offerAmount
        });
    }

    /**
     * @notice Cancels an offer made by the caller for a specific token in a specific contract
     * @dev Can only be called by the owner of the contract
     * @param contractAddress_ The address of the token contract
     * @param tokenId The ID of the token for which to cancel the offer
     */
    function cancelOffer(
        address contractAddress_,
        uint256 tokenId
    ) public onlyOwner {
        OfferItem storage item = _items[contractAddress_][tokenId];

        if (address(this).balance < item.offerAmount) {
            revert InsufficientContractBalance();
        }

        uint256 offerAmount = item.offerAmount;
        (bool success, ) = item.offeror.call{value: offerAmount}("");
        if (!success) {
            revert TransferFailed(
                "OffersERC721_v1: Cancelled Offer refund failed."
            );
        }

        emit OfferEvent({
            offerType: "Cancel",
            itemId: item.itemId,
            contractAddress: contractAddress_,
            tokenId: tokenId,
            tokenOwner: IERC721(contractAddress_).ownerOf(tokenId),
            offeror: item.offeror,
            value: item.offerAmount
        });

        delete _items[contractAddress_][tokenId];
    }

    /**
     * @notice Retrieves the offer details for a specific token in a specific contract
     * @param contractAddress_ The address of the token contract
     * @param tokenId The ID of the token for which to retrieve the offer details
     * @return The OfferItem struct containing the offer details
     */
    function getOffer(
        address contractAddress_,
        uint256 tokenId
    ) public view returns (OfferItem memory) {
        return _items[contractAddress_][tokenId];
    }

    /**
     * @notice Creates a new offer for a specific token in a specific contract
     * @dev This function is private and non-reentrant
     * @param contractAddress_ The address of the token contract
     * @param tokenId The ID of the token for which to create the offer
     * @param ownerOfToken The address of the owner of the token
     * @param value The offer amount
     */
    function newOffer(
        address contractAddress_,
        uint32 tokenId,
        address ownerOfToken,
        uint256 value
    ) private nonReentrant {
        _itemIdCounter++;

        _items[contractAddress_][tokenId] = OfferItem({
            itemId: _itemIdCounter,
            offerAmount: value,
            offeror: msg.sender
        });

        emit OfferEvent({
            offerType: "New",
            itemId: _itemIdCounter,
            contractAddress: contractAddress_,
            tokenId: tokenId,
            tokenOwner: ownerOfToken,
            offeror: msg.sender,
            value: value
        });
    }

    /**
     * @notice Outbids an existing offer for a specific token in a specific contract
     * @dev This function is private and non-reentrant
     * @param contractAddress_ The address of the token contract
     * @param tokenId The ID of the token for which to outbid the offer
     * @param newOfferor The address of the new offeror
     * @param value The new offer amount
     */
    function outbidOffer(
        address contractAddress_,
        uint32 tokenId,
        address newOfferor,
        uint256 value
    ) private nonReentrant {
        OfferItem storage existingItem = _items[contractAddress_][tokenId];

        address existingOfferor = existingItem.offeror;
        uint256 existingOfferAmount = existingItem.offerAmount;

        existingItem.offerAmount = value;
        existingItem.offeror = newOfferor;

        (bool success, ) = existingOfferor.call{value: existingOfferAmount}("");
        if (!success) {
            revert TransferFailed("OffersERC721_v1: Outbid refund failed.");
        }

        emit OfferEvent({
            offerType: "Outbid",
            itemId: existingItem.itemId,
            contractAddress: contractAddress_,
            tokenId: tokenId,
            tokenOwner: IERC721(contractAddress_).ownerOf(tokenId),
            offeror: newOfferor,
            value: value
        });
    }
}
