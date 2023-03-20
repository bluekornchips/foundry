// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "clancy/ERC/extensions/ClancyERC721StorageURI.sol";
import "../../helpers/ClancyERC721TestHelpers.sol";

contract ClancyERC721StorageURI_Test is Test, ClancyERC721TestHelpers {
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
        uint256 tokenId = 1;
        string memory tokenURI = "https://browncows.com/chocolate";

        // Clear the BaseURI
        clancyERC721StorageURI.setBaseURI("");
        clancyERC721StorageURI.setPublicMintStatus(true);
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
