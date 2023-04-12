// SPDX-License-Identifier: None
pragma solidity ^0.8.19;

import {Counters} from "openzeppelin-contracts/contracts/utils/Counters.sol";
import {IERC721} from "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

import {ClancyPayable} from "clancy/utils/ClancyPayable.sol";
import {ClancyMarketplaceERC721_v1} from "clancy/marketplace/ClancyMarketplaceERC721_v1.sol";
import {IOffersERC721_v1} from "clancy/marketplace/offers/IOffersERC721_v1.sol";

contract OffersERC721_v1 is
    ClancyMarketplaceERC721_v1,
    IOffersERC721_v1,
    ClancyPayable
{
    /**
     * @dev Uses the Counters library to handle counters for the contract
     */
    using Counters for Counters.Counter;

    mapping(address => mapping(uint256 => OfferItem)) private _items;

    /**
     * @notice Creates a new offer for a specific token in a specific contract with the sent ether value
     * @dev Can only be called when contract is not paused
     * @param contractAddress_ The address of the token contract
     * @param tokenId The ID of the token for which to create the offer
     */
    function createOffer(
        address contractAddress_,
        uint256 tokenId
    ) public payable whenNotPaused {
        uint256 value = msg.value;
        if (value <= 0) {
            revert OfferCannotBeLTEZero();
        }
        if (!getAllowedContract(contractAddress_)) {
            revert InputContractInvalid();
        }
        address ownerOfToken = IERC721(contractAddress_).ownerOf(tokenId); // Will revert if token does not exist

        _itemIdCounter.increment();

        _items[contractAddress_][tokenId] = OfferItem({
            itemId: _itemIdCounter.current(),
            offerAmount: value,
            offeror: msg.sender,
            tokenOwner: ownerOfToken
        });

        emit OfferCreated({
            itemId: _itemIdCounter.current(),
            contractAddress: contractAddress_,
            tokenId: tokenId,
            offeror: msg.sender
        });
    }

    function cancelOffer(
        address contractAddress_,
        uint256 tokenId
    ) public whenNotPaused nonReentrant {
        OfferItem storage item = _items[contractAddress_][tokenId];

        if (item.offeror != msg.sender) {
            revert NotOfferor();
        }
        if (address(this).balance < item.offerAmount) {
            revert InsufficientContractBalance();
        }

        uint256 offerAmount = item.offerAmount;
        (bool success, ) = msg.sender.call{value: offerAmount}("");
        require(success, "Transfer failed.");

        delete _items[contractAddress_][tokenId];

        emit OfferCancelled({
            itemId: item.itemId,
            contractAddress: contractAddress_,
            tokenId: tokenId,
            offeror: msg.sender
        });
    }

    function getOffer(
        address contractAddress_,
        uint256 tokenId
    ) public view returns (OfferItem memory) {
        return _items[contractAddress_][tokenId];
    }
}
