// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";

import {ClancyERC721StorageURI} from "clancy/ERC/ERC721/extensions/ClancyERC721StorageURI.sol";

import {ClancyERC721TestHelpers} from "test-helpers//ClancyERC721TestHelpers.sol";
import {Titan} from "test-helpers/Titan/Titan.sol";

contract ClancyERC721StorageURI_Test is Test, ClancyERC721TestHelpers, Titan {
    ClancyERC721StorageURI public clancyERC721StorageURI;

    function setUp() public {
        clancyERC721StorageURI = new ClancyERC721StorageURI(
            NAME,
            SYMBOL,
            MAX_SUPPLY,
            BASE_URI
        );
    }

    function test_setTokenURI() public {
        uint32 tokenId = 1;
        string memory tokenURI = "https://browncows.com/chocolate";

        // Clear the BaseURI
        clancyERC721StorageURI.setBaseURI("");
        clancyERC721StorageURI.setPublicMintEnabled(true);
        clancyERC721StorageURI.mint();
        clancyERC721StorageURI.setTokenURI(tokenId, tokenURI);

        assertEq(
            clancyERC721StorageURI.tokenURI(tokenId),
            tokenURI,
            "tokenURI should be set"
        );

        // Mint another token to test that the tokenURI is not set for the new token
        clancyERC721StorageURI.mint();
        tokenId++;
        assertEq(
            clancyERC721StorageURI.tokenURI(tokenId),
            "",
            "tokenURI should be set"
        );
    }
}
