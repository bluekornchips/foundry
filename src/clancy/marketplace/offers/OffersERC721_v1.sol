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
    mapping(address => mapping(uint256 => OfferItem)) public offerItems;

    mapping(address => CollectionOffer[]) public collectionOffers;
    uint32 public collectionOffersCount;
    uint8 public constant MAX_OFFERS = type(uint8).max;

    //#region Item Offers

    /**
     * @notice Creates a new offer or outbids an existing offer for a specific token in a specific contract
     * @dev This function is public and can only be called when the contract is not paused
     * @param contractAddress_ The address of the token contract
     * @param tokenId The ID of the token for which to create or outbid the offer
     */
    function createOfferItem(
        address contractAddress_,
        uint32 tokenId
    ) public payable whenNotPaused {
        uint256 value = msg.value;

        if (value <= 0) {
            revert OfferCannotBeLTEZero();
        }
        if (!vendors[contractAddress_]) {
            revert InputContractInvalid();
        }
        if (msg.sender == address(0)) {
            revert OfferorCannotBeZeroAddress();
        }

        address ownerOfToken = IERC721(contractAddress_).ownerOf(tokenId); // Will revert if token does not exist

        if (ownerOfToken == msg.sender) {
            revert OfferorCannotBeTokenOwner();
        }

        OfferItem storage existingItem = offerItems[contractAddress_][tokenId];

        if (existingItem.offeror != address(0)) {
            if (value <= existingItem.value) {
                revert OfferMustBeGTExistingOffer();
            }
            outbidOfferItem(contractAddress_, tokenId, msg.sender, value);
        } else {
            newOfferItem(contractAddress_, tokenId, ownerOfToken, value);
        }
    }

    /**
     * @notice Accepts an existing offer for a specific token in a specific contract
     * @dev This function is public and can only be called by the token owner
     * @param contractAddress_ The address of the token contract
     * @param tokenId The ID of the token for which to accept the offer
     */
    function acceptOfferItem(
        address contractAddress_,
        uint256 tokenId
    ) public whenNotPaused {
        OfferItem storage item = offerItems[contractAddress_][tokenId];
        if (item.itemId <= 0) {
            revert OfferDoesNotExist();
        }
        if (IERC721(contractAddress_).ownerOf(tokenId) != msg.sender) {
            revert NotTokenOwner();
        }
        if (address(this).balance < item.value) {
            revert InsufficientContractBalance();
        }

        uint256 value = item.value;
        address offeror = item.offeror;
        uint256 itemId = item.itemId;

        delete offerItems[contractAddress_][tokenId];

        (bool success, ) = msg.sender.call{value: value}("");
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
            offerType: OfferType.Accept,
            itemId: itemId,
            contractAddress: contractAddress_,
            tokenId: tokenId,
            tokenOwner: msg.sender,
            offeror: offeror,
            value: value
        });
    }

    /**
     * @notice Cancels an offer made by the caller for a specific token in a specific contract
     * @dev Can only be called by the owner of the contract
     * @param contractAddress_ The address of the token contract
     * @param tokenId The ID of the token for which to cancel the offer
     */
    function cancelOfferItem(
        address contractAddress_,
        uint256 tokenId
    ) public onlyOwner {
        OfferItem storage item = offerItems[contractAddress_][tokenId];

        if (address(this).balance < item.value) {
            revert InsufficientContractBalance();
        }

        uint256 value = item.value;
        (bool success, ) = item.offeror.call{value: value}("");
        if (!success) {
            revert TransferFailed(
                "OffersERC721_v1: Cancelled Offer refund failed."
            );
        }

        emit OfferEvent({
            offerType: OfferType.Cancel,
            itemId: item.itemId,
            contractAddress: contractAddress_,
            tokenId: tokenId,
            tokenOwner: IERC721(contractAddress_).ownerOf(tokenId),
            offeror: item.offeror,
            value: item.value
        });

        delete offerItems[contractAddress_][tokenId];
    }

    /**
     * @notice Retrieves the offer details for a specific token in a specific contract
     * @param contractAddress_ The address of the token contract
     * @param tokenId The ID of the token for which to retrieve the offer details
     * @return The OfferItem struct containing the offer details
     */
    function getOfferItem(
        address contractAddress_,
        uint256 tokenId
    ) public view returns (OfferItem memory) {
        return offerItems[contractAddress_][tokenId];
    }

    /**
     * @notice Creates a new offer for a specific token in a specific contract
     * @dev This function is private and non-reentrant
     * @param contractAddress_ The address of the token contract
     * @param tokenId The ID of the token for which to create the offer
     * @param ownerOfToken The address of the owner of the token
     * @param value The offer amount
     */
    function newOfferItem(
        address contractAddress_,
        uint32 tokenId,
        address ownerOfToken,
        uint256 value
    ) private nonReentrant {
        itemIdCounter++;

        offerItems[contractAddress_][tokenId] = OfferItem({
            itemId: itemIdCounter,
            value: value,
            offeror: msg.sender
        });

        emit OfferEvent({
            offerType: OfferType.Create,
            itemId: itemIdCounter,
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
    function outbidOfferItem(
        address contractAddress_,
        uint32 tokenId,
        address newOfferor,
        uint256 value
    ) private nonReentrant {
        OfferItem storage existingItem = offerItems[contractAddress_][tokenId];

        address existingOfferor = existingItem.offeror;
        uint256 existingvalue = existingItem.value;

        existingItem.value = value;
        existingItem.offeror = newOfferor;

        (bool success, ) = existingOfferor.call{value: existingvalue}("");
        if (!success) {
            revert TransferFailed("OffersERC721_v1: Outbid refund failed.");
        }

        emit OfferEvent({
            offerType: OfferType.Outbid,
            itemId: existingItem.itemId,
            contractAddress: contractAddress_,
            tokenId: tokenId,
            tokenOwner: IERC721(contractAddress_).ownerOf(tokenId),
            offeror: newOfferor,
            value: value
        });
    }

    //#endregion Item Offers

    function createCollectionOffer(
        address contractAddress_
    ) public payable whenNotPaused {
        if (msg.value <= 0) {
            revert OfferCannotBeLTEZero();
        }
        if (!vendors[contractAddress_]) {
            revert InputContractInvalid();
        }
        if (msg.sender == address(0)) {
            revert OfferorCannotBeZeroAddress();
        }
        uint32 itemId = collectionOffersCount;
        if (itemId >= MAX_OFFERS) {
            revert MaxOffersReached();
        }

        uint256 value = msg.value;
        ++itemId;

        CollectionOffer memory item = CollectionOffer({
            itemId: itemId,
            contractAddress: contractAddress_,
            offeror: msg.sender,
            value: value
        });

        collectionOffersCount = itemId;
        collectionOffers[contractAddress_].push(item);

        emit CollectionOfferEvent({
            offerType: OfferType.Create,
            contractAddress: contractAddress_,
            offeror: msg.sender,
            value: value
        });
    }

    function cancelCollectionOffer(
        address contractAddress_,
        uint32 offerIndex
    ) public whenNotPaused {
        if (!vendors[contractAddress_]) {
            revert InputContractInvalid();
        }
        if (offerIndex >= collectionOffers[contractAddress_].length) {
            revert OfferDoesNotExist();
        }
        CollectionOffer memory offer = collectionOffers[contractAddress_][
            offerIndex
        ];

        if (offer.offeror != msg.sender) {
            revert NotOfferor();
        }

        uint256 value = offer.value;

        // Swap the last offer with the offer to delete, and then delete the last offer
        uint32 lastOfferIndex = uint32(
            collectionOffers[contractAddress_].length - 1
        );
        if (offerIndex != lastOfferIndex) {
            collectionOffers[contractAddress_][offerIndex] = collectionOffers[
                contractAddress_
            ][lastOfferIndex];
        }
        collectionOffers[contractAddress_].pop();

        (bool success, ) = msg.sender.call{value: value}("");
        if (!success) {
            revert TransferFailed(
                "OffersERC721_v1: Cancelled Offer refund failed."
            );
        }

        emit CollectionOfferEvent({
            offerType: OfferType.Cancel,
            contractAddress: contractAddress_,
            offeror: msg.sender,
            value: value
        });
    }

    /**
     * @dev This is a gas heavy method that is not intended to be ran on on chain.
     *      Use this method to get all the offers on chain and pass in info for other methods
     *      as required.
     *      eg: For cancelling a collection offer, get all collection offers, find the index of
     *          the offer you want to cancel, and pass in the index to the cancelCollectionOffer method.
     */
    function getCollectionOffers(
        address collectionAddress_
    ) public view returns (CollectionOffer[] memory) {
        if (!vendors[collectionAddress_]) {
            revert InputContractInvalid();
        }
        return collectionOffers[collectionAddress_];
    }
}
