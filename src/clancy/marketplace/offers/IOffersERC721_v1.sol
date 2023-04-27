// SPDX-License-Identifier: None
pragma solidity ^0.8.19;

interface IOffersERC721_v1 {
    //#region Errors

    /// @notice Thrown when the offer is less than or equal to zero.
    error OfferCannotBeLTEZero();

    /// @notice Thrown when an offer does not exist.
    error OfferDoesNotExist();

    /// @notice Thrown when the caller is not the offeror.
    error NotOfferor();

    /// @notice Thrown when the new offer is less than or equal to the existing offer.
    error OfferMustBeGTExistingOffer();

    /// @notice Thrown when the contract balance is insufficient.
    error InsufficientContractBalance();

    /// @notice Thrown when the offeror's address is the zero address.
    error OfferorCannotBeZeroAddress();

    /// @notice Thrown when the offeror is also the token owner.
    error OfferorCannotBeTokenOwner();

    /// @notice Thrown when a token transfer fails.
    /// @param errorMessage The error message explaining the reason for transfer failure.
    error TransferFailed(string errorMessage);

    //#endregion Errors

    //#region Enum

    enum OfferType {
        Accept,
        Cancel,
        Create,
        Outbid
    }

    //#endregion Enum

    //#region Events

    /**
     * @dev Emitted when an offer is created, cancelled, or accepted.
     */
    event CollectionOfferEvent(
        OfferType indexed offerType,
        address indexed contractAddress,
        address indexed offeror,
        uint256 value
    );

    event OfferEvent(
        OfferType offerType,
        uint256 indexed itemId,
        address indexed contractAddress,
        uint256 indexed tokenId,
        address tokenOwner,
        address offeror,
        uint256 value
    );

    //#endregion Events

    //#region Structs

    struct CollectionOfferItem {
        uint32 itemId;
        address contractAddress;
        address offeror;
        uint256 value;
    }

    struct OfferItem {
        uint256 itemId;
        uint256 offerAmount;
        address offeror;
    }

    //#endregion Structs
}
