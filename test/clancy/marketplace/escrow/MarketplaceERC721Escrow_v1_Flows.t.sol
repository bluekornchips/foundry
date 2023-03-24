// SPDX-License-Identifier: None
pragma solidity ^0.8.17;

import {Test} from "forge-std/Test.sol";

import {IERC721} from "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

import {MarketplaceERC721Escrow_v1} from "clancy/marketplace/escrow/MarketplaceERC721Escrow_v1.sol";
import {IClancyERC721, ClancyERC721} from "clancy/ERC/ClancyERC721.sol";

import {IMarketplaceERC721Escrow_v1_Test} from "./IMarketplaceERC721Escrow_v1.t.sol";

contract MarketplaceERC721Escrow_v1_Test is
    IMarketplaceERC721Escrow_v1_Test,
    Test
{
    ClancyERC721 tokensOne;
    ClancyERC721 tokensTwo;
    MarketplaceERC721Escrow_v1 marketplace;

    uint256 public marketplace_max_items;

    function setUp() public {
        //tokensOne
        tokensOne = new ClancyERC721(NAME, SYMBOL, MAX_SUPPLY, BASE_URI);
        tokensOne.setPublicMintStatus(true);
        //tokensTwo
        tokensTwo = new ClancyERC721(NAME, SYMBOL, MAX_SUPPLY, BASE_URI);
        tokensTwo.setPublicMintStatus(true);

        marketplace = new MarketplaceERC721Escrow_v1();
        marketplace_max_items = marketplace.MAX_ITEMS();
        marketplace.setAllowedContract(address(tokensOne), true);
        marketplace.setAllowedContract(address(tokensTwo), true);
    }

    //#region Single Contract Tests
    function test_resaleFlow_ShouldPass() public {
        uint256 tokenId = mintAndApprove();

        uint256 itemId = marketplace.createItem(address(tokensOne), tokenId);
        marketplace.createPurchase(
            address(tokensOne),
            tokenId,
            address(TEST_WALLET_MAIN)
        );

        vm.prank(address(TEST_WALLET_MAIN));
        marketplace.claimItem(address(tokensOne), tokenId);
        assertEq(tokensOne.ownerOf(tokenId), address(TEST_WALLET_MAIN));

        vm.prank(address(TEST_WALLET_MAIN));
        tokensOne.approve(address(marketplace), tokenId);

        vm.prank(address(TEST_WALLET_MAIN));
        itemId = marketplace.createItem(address(tokensOne), tokenId);

        marketplace.createPurchase(address(tokensOne), tokenId, address(this));

        marketplace.claimItem(address(tokensOne), tokenId);
        assertEq(tokensOne.ownerOf(tokenId), address(this));
    }

    function test_BuyAndSellFlowMultipleTimes_UnderMaxLimit_ShouldPass()
        public
    {
        marketplace_max_items = marketplace.MAX_ITEMS();

        // Mint marketplace_max_items tokens
        uint256[] memory tokenIds = new uint256[](marketplace_max_items);
        for (uint256 i = 0; i < marketplace_max_items; i++) {
            tokenIds[i] = mintAndApprove();
        }

        // Create marketplace_max_items items
        uint256[] memory itemIds = new uint256[](marketplace_max_items);
        for (uint256 i = 0; i < marketplace_max_items; i++) {
            itemIds[i] = marketplace.createItem(
                address(tokensOne),
                tokenIds[i]
            );
        }

        // Create marketplace_max_items purchases
        for (uint256 i = 0; i < marketplace_max_items; i++) {
            marketplace.createPurchase(
                address(tokensOne),
                tokenIds[i],
                address(TEST_WALLET_MAIN)
            );
        }

        // Claim marketplace_max_items items
        for (uint256 i = 0; i < marketplace_max_items; i++) {
            vm.prank(address(TEST_WALLET_MAIN));
            marketplace.claimItem(address(tokensOne), tokenIds[i]);
        }

        // List the same marketplace_max_items items again
        for (uint256 i = 0; i < marketplace_max_items; i++) {
            vm.prank(address(TEST_WALLET_MAIN));
            tokensOne.approve(address(marketplace), tokenIds[i]);
            vm.prank(address(TEST_WALLET_MAIN));
            itemIds[i] = marketplace.createItem(
                address(tokensOne),
                tokenIds[i]
            );
        }

        // Create marketplace_max_items purchases
        for (uint256 i = 0; i < marketplace_max_items; i++) {
            marketplace.createPurchase(
                address(tokensOne),
                tokenIds[i],
                address(this)
            );
        }

        // Claim marketplace_max_items items
        for (uint256 i = 0; i < marketplace_max_items; i++) {
            vm.prank(address(this));
            marketplace.claimItem(address(tokensOne), tokenIds[i]);
        }
    }

    //#endregion

    //#region Multiple Contracts Tests
    function test_ListingOneTokenFromEitherContract_ShouldPass() public {
        uint256 tokensOne_tokenId = mintAndApprovePrank(
            TEST_WALLET_MAIN,
            tokensOne
        );
        uint256 tokensTwo_tokenId = mintAndApprovePrank(
            TEST_WALLET_MAIN,
            tokensTwo
        );

        vm.prank(TEST_WALLET_MAIN);
        uint256 tokensOne_itemId = marketplace.createItem(
            address(tokensOne),
            tokensOne_tokenId
        );

        vm.prank(TEST_WALLET_MAIN);
        uint256 tokensTwo_itemId = marketplace.createItem(
            address(tokensTwo),
            tokensTwo_tokenId
        );
    }

    //#endregion
    //#region Helpers

    function mintAndApprove() internal returns (uint256) {
        uint256 tokenId = tokensOne.mint();
        tokensOne.approve(address(marketplace), tokenId);
        return tokenId;
    }

    function mintAndApprovePrank(
        address pranker,
        ClancyERC721 ercContract
    ) internal returns (uint256) {
        vm.prank(pranker);
        uint256 tokenId = IClancyERC721(ercContract).mint();
        vm.prank(pranker);
        IERC721(ercContract).approve(address(marketplace), tokenId);
        return tokenId;
    }
    //#endregion
}
