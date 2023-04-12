// SPDX-License-Identifier: None
pragma solidity ^0.8.19;

interface IClancyMarketplaceERC721_v1 {
    /**
     * @dev Custom error to be thrown if the input token contract address is not valid
     */
    error InputContractInvalid();

    /**
     * @dev Custom error to be thrown if the caller is not the owner of the token
     */
    error NotTokenOwner();

    /**
     * @dev Custom error to be thrown if the specified token does not exist
     */
    error TokenDoesNotExist();
}
