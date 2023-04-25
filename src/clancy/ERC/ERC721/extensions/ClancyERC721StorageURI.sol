//SPDX-License-Identifier: None
pragma solidity ^0.8.19;

import {ERC721} from "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {ERC721Enumerable} from "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

import {ClancyERC721} from "clancy/ERC/ERC721/ClancyERC721.sol";

contract ClancyERC721StorageURI is ClancyERC721, ERC721URIStorage {
    constructor(
        string memory name_,
        string memory symbol_,
        uint32 maxSupply_,
        string memory baseURILocal_
    ) ClancyERC721(name_, symbol_, maxSupply_, baseURILocal_) {}

    /**
     * @dev Sets the token URI for a given token ID.
     *
     * Requirements:
     * - Can only be called by the owner of the contract.
     *
     * @param tokenId The ID of the token to set the URI for.
     * @param tokenURI_ The URI to assign to the token.
     */
    function setTokenURI(
        uint32 tokenId,
        string memory tokenURI_
    ) public onlyOwner {
        _setTokenURI(tokenId, tokenURI_);
    }

    //# region Overrides
    /**
     * @dev Returns true if the contract implements a given interface.
     *
     * @param interfaceId The ID of the interface to query.
     * @return True if the contract implements the given interface, false otherwise.
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721Enumerable, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /**
     * @dev Hook that is called before any token transfer, including minting and burning.
     *
     * Requirements:
     * - The contract must not be paused.
     *
     * @param from The address that the token is being transferred from.
     * @param to The address that the token is being transferred to.
     * @param tokenId The ID of the token being transferred.
     * @param batchSize The number of tokens being transferred.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) whenNotPaused {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    /**
     * @dev Returns the URI for a given token ID.
     *
     * @param tokenId The ID of the token to retrieve the URI for.
     * @return A string representing the URI for the token.
     */
    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    /**
     * @dev Burns a token.
     *
     * Requirements:
     * - The token must exist.
     *
     * @param tokenId The ID of the token to be burned.
     */
    function _burn(
        uint256 tokenId
    ) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    /**
     * @dev Returns the base URI for the contract.
     *
     * @return A string representing the base URI for the contract.
     */
    function _baseURI()
        internal
        view
        override(ClancyERC721, ERC721)
        returns (string memory)
    {
        return _baseURILocal;
    }
    //# endregion
}
