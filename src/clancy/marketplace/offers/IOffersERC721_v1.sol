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

    event OfferCreated(
        uint256 indexed itemId,
        address indexed contractAddress,
        uint256 indexed tokenId,
        address offeror
    );

    event OfferOutbid(
        uint256 indexed itemId,
        address indexed contractAddress,
        uint256 indexed tokenId,
        address offeror
    );

    event OfferCancelled(
        uint256 indexed itemId,
        address indexed contractAddress,
        uint256 indexed tokenId,
        address offeror
    );

    event OfferAccepted(
        uint256 indexed itemId,
        address indexed contractAddress,
        uint256 indexed tokenId,
        address offeror,
        address tokenOwner
    );

    struct OfferItem {
        uint256 itemId;
        uint256 offerAmount;
        address offeror;
        address tokenOwner;
    }
}
