// SPDX-License-Identifier: None
pragma solidity ^0.8.19;

import {IERC721} from "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

import {ClancyPayable} from "clancy/utils/ClancyPayable.sol";
import {IOffersERC721} from "clancy/marketplace/offers/IOffersERC721.sol";
import {ClancyMarketplaceERC721} from "clancy/marketplace/ClancyMarketplaceERC721.sol";

contract OffersERC721 is ClancyMarketplaceERC721, IOffersERC721, ClancyPayable {
    /// @dev Mapping of token contract addresses to token Ids to ItemOffer structs, representing offers
    mapping(address => mapping(uint256 => ItemOffer)) public itemOffers;

    mapping(address => CollectionOffer[]) public collectionOffers;
    uint32 public collectionOffersCount;
    uint8 public constant MAX_OFFERS = type(uint8).max;

    //#region Item Offers

    /**
     * @notice Creates a new offer or outbids an existing offer for a specific token in a specific contract.
     *
     * @param contractAddress_ Token contract address.
     * @param tokenId Token Id.
     */
    function createItemOffer(
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

        ItemOffer storage existingItem = itemOffers[contractAddress_][tokenId];

        if (existingItem.offeror != address(0)) {
            if (value <= existingItem.value) {
                revert OfferMustBeGTExistingOffer();
            }
            outbidItemOffer(contractAddress_, tokenId, msg.sender, value);
        } else {
            newItemOffer(contractAddress_, tokenId, ownerOfToken, value);
        }
    }

    /**
     * @notice Accepts an offer. Transfer the token to the offeror and the offer amount to the token owner.
     *
     * @param contractAddress_ Token contract address.
     * @param tokenId Token Id.
     */
    function acceptItemOffer(
        address contractAddress_,
        uint256 tokenId
    ) public whenNotPaused {
        ItemOffer storage item = itemOffers[contractAddress_][tokenId];

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

        delete itemOffers[contractAddress_][tokenId];

        (bool success, ) = msg.sender.call{value: value}("");
        if (!success) {
            revert TransferFailed(
                "OffersERC721: Failed to transfer offer amount to token owner."
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
     * @notice Cancels the current offer. Not user callable.
     *
     * @param contractAddress_ Token contract address.
     * @param tokenId Token Id.
     */
    function cancelItemOffer(
        address contractAddress_,
        uint256 tokenId
    ) public onlyOwner {
        ItemOffer storage item = itemOffers[contractAddress_][tokenId];

        if (address(this).balance < item.value) {
            revert InsufficientContractBalance();
        }

        uint256 value = item.value;
        (bool success, ) = item.offeror.call{value: value}("");
        if (!success) {
            revert TransferFailed(
                "OffersERC721: Cancelled Offer refund failed."
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

        delete itemOffers[contractAddress_][tokenId];
    }

    /**
     * @dev Retrieves the offer details for a specific token in a specific contract
     * @param contractAddress_ Token contract address.
     * @param tokenId Token Id.
     * @return {ItemOffer}
     */
    function getItemOffer(
        address contractAddress_,
        uint256 tokenId
    ) public view returns (ItemOffer memory) {
        return itemOffers[contractAddress_][tokenId];
    }

    /**
     * @notice Creates a new offer for a specific token in a specific contract
     * @param contractAddress_ Token contract address.
     * @param tokenId Token Id.
     * @param ownerOfToken Token ownner.
     * @param value Offer amount.
     */
    function newItemOffer(
        address contractAddress_,
        uint32 tokenId,
        address ownerOfToken,
        uint256 value
    ) private nonReentrant {
        ++itemIdCounter;

        itemOffers[contractAddress_][tokenId] = ItemOffer({
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
     * @dev Outbids an existing offer.
     * @param contractAddress_ Token contract address.
     * @param tokenId Token Id.
     * @param newOfferor New offeror.
     * @param value The new offer amount.
     */
    function outbidItemOffer(
        address contractAddress_,
        uint32 tokenId,
        address newOfferor,
        uint256 value
    ) private nonReentrant {
        ItemOffer storage existingItem = itemOffers[contractAddress_][tokenId];

        address existingOfferor = existingItem.offeror;
        uint256 existingvalue = existingItem.value;

        existingItem.value = value;
        existingItem.offeror = newOfferor;

        (bool success, ) = existingOfferor.call{value: existingvalue}("");
        if (!success) {
            revert TransferFailed("OffersERC721: Outbid refund failed.");
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
        if (offerIndex > collectionOffers[contractAddress_].length) {
            revert OfferDoesNotExist();
        }

        CollectionOffer memory offer = collectionOffers[contractAddress_][
            offerIndex
        ];

        if (address(this).balance < offer.value) {
            revert InsufficientContractBalance();
        }

        if (offer.offeror != msg.sender && msg.sender != owner()) {
            revert NotOfferorOrAdmin();
        }

        uint256 value = offer.value;
        address offeror = offer.offeror;

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

        (bool success, ) = offeror.call{value: value}("");
        if (!success) {
            revert TransferFailed(
                "OffersERC721: Cancelled Offer refund failed."
            );
        }

        emit CollectionOfferEvent({
            offerType: OfferType.Cancel,
            contractAddress: contractAddress_,
            offeror: offeror,
            value: value
        });
    }

    function cancelCollectionOffers(address contractAddress_) public onlyOwner {
        CollectionOffer[] memory offers = collectionOffers[contractAddress_];

        if (offers.length < 1) {
            revert CollectionOffersEmpty();
        }

        uint256 repaymentTotal;
        uint8 i;

        do {
            repaymentTotal += offers[i].value;
            ++i;
        } while (i < offers.length);

        if (address(this).balance < repaymentTotal) {
            revert InsufficientContractBalance();
        }

        i = uint8(offers.length); // Start at the end of the array.

        do {
            --i; // Decrement immediately, as the above i will have an index of 1 greater than the length.
            cancelCollectionOffer(contractAddress_, i);
        } while (i > 0);

        delete collectionOffers[contractAddress_];
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
