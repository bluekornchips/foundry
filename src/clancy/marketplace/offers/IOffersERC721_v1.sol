// SPDX-License-Identifier: None
pragma solidity ^0.8.19;

interface IOffersERC721_v1 {
    error OfferCannotBeLTEZero();
    error OfferDoesNotExist();
    error NotOfferor();
    error OfferMustBeGTExistingOffer();
    error InsufficientContractBalance();
    error OfferorCannotBeZeroAddress();
    error OfferorCannotBeTokenOwner();
    error TransferFailed(string);

    event OfferEvent(
        string offerType,
        uint256 indexed itemId,
        address indexed contractAddress,
        uint256 indexed tokenId,
        address tokenOwner,
        address offeror,
        uint256 value
    );

    struct OfferItem {
        uint256 itemId;
        uint256 offerAmount;
        address offeror;
    }
}
