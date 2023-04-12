// SPDX-License-Identifier: None
pragma solidity ^0.8.19;

interface IOffersERC721_v1 {
    error OfferCannotBeLTEZero();
    error OfferDoesNotExist();
    error NotOfferor();
    error InsufficientContractBalance();

    event OfferCreated(
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

    struct OfferItem {
        uint256 itemId;
        uint256 offerAmount;
        address offeror;
        address tokenOwner;
    }
}
