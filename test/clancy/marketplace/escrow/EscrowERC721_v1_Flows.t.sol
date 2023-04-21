// SPDX-License-Identifier: None
pragma solidity ^0.8.19;

import "forge-std/Test.sol";

import {IERC721} from "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

import {EscrowERC721_v1} from "clancy/marketplace/escrow/EscrowERC721_v1.sol";
import {IClancyERC721, ClancyERC721} from "clancy/ERC/ERC721/ClancyERC721.sol";

import {IEscrowERC721_v1_Test} from "./IEscrowERC721_v1.t.sol";

contract EscrowERC721_v1_Test is IEscrowERC721_v1_Test, Test {
    ClancyERC721 tokensOne;
    ClancyERC721 tokensTwo;
    EscrowERC721_v1 escrow;

    uint256 public escrow_max_items;

    function setUp() public {
        escrow = new EscrowERC721_v1();
        escrow_max_items = escrow.MAX_ITEMS();
        //tokensOne
        tokensOne = new ClancyERC721(NAME, SYMBOL, escrow_max_items, BASE_URI);
        tokensOne.setPublicMintStatus(true);
        //tokensTwo
        tokensTwo = new ClancyERC721(NAME, SYMBOL, escrow_max_items, BASE_URI);
        tokensTwo.setPublicMintStatus(true);

        escrow.setAllowedContract(address(tokensOne), true);
        escrow.setAllowedContract(address(tokensTwo), true);
    }

    //#region Single Contract Tests
    function test_resaleFlow_ShouldPass() public {
        uint256 tokenId = mintAndApprove();

        uint256 itemId = escrow.createItem(address(tokensOne), tokenId);
        escrow.createPurchase(
            address(tokensOne),
            tokenId,
            address(TEST_WALLET_MAIN)
        );

        vm.prank(address(TEST_WALLET_MAIN));
        escrow.claimItem(address(tokensOne), tokenId);
        assertEq(tokensOne.ownerOf(tokenId), address(TEST_WALLET_MAIN));

        vm.prank(address(TEST_WALLET_MAIN));
        tokensOne.approve(address(escrow), tokenId);

        vm.prank(address(TEST_WALLET_MAIN));
        itemId = escrow.createItem(address(tokensOne), tokenId);

        escrow.createPurchase(address(tokensOne), tokenId, address(this));

        escrow.claimItem(address(tokensOne), tokenId);
        assertEq(tokensOne.ownerOf(tokenId), address(this));
    }

    function test_BuyAndSellFlowMultipleTimes_UnderMaxLimit_ShouldPass()
        public
    {
        escrow_max_items = escrow.MAX_ITEMS();

        // Mint escrow_max_items tokens
        uint256[] memory tokenIds = new uint256[](escrow_max_items);
        for (uint256 i = 0; i < escrow_max_items; i++) {
            tokenIds[i] = mintAndApprove();
        }

        // Create escrow_max_items items
        uint256[] memory itemIds = new uint256[](escrow_max_items);
        for (uint256 i = 0; i < escrow_max_items; i++) {
            itemIds[i] = escrow.createItem(address(tokensOne), tokenIds[i]);
        }

        // Create escrow_max_items purchases
        for (uint256 i = 0; i < escrow_max_items; i++) {
            escrow.createPurchase(
                address(tokensOne),
                tokenIds[i],
                address(TEST_WALLET_MAIN)
            );
        }

        // Claim escrow_max_items items
        for (uint256 i = 0; i < escrow_max_items; i++) {
            vm.prank(address(TEST_WALLET_MAIN));
            escrow.claimItem(address(tokensOne), tokenIds[i]);
        }

        // List the same escrow_max_items items again
        for (uint256 i = 0; i < escrow_max_items; i++) {
            vm.prank(address(TEST_WALLET_MAIN));
            tokensOne.approve(address(escrow), tokenIds[i]);
            vm.prank(address(TEST_WALLET_MAIN));
            itemIds[i] = escrow.createItem(address(tokensOne), tokenIds[i]);
        }

        // Create escrow_max_items purchases
        for (uint256 i = 0; i < escrow_max_items; i++) {
            escrow.createPurchase(
                address(tokensOne),
                tokenIds[i],
                address(this)
            );
        }

        // Claim escrow_max_items items
        for (uint256 i = 0; i < escrow_max_items; i++) {
            vm.prank(address(this));
            escrow.claimItem(address(tokensOne), tokenIds[i]);
        }
    }

    //#endregion

    //#region Multiple Contracts Tests
    function test_ListingOneTokenFromEitherContract_ShouldPass() public {
        // console.log("Escrow Address:%s", address(escrow));
        uint256 tokensOne_tokenId = mintPrank(TEST_WALLET_MAIN, tokensOne);
        uint256 tokensTwo_tokenId = mintPrank(TEST_WALLET_MAIN, tokensTwo);

        assertEq(
            IERC721(tokensOne).ownerOf(tokensOne_tokenId),
            address(TEST_WALLET_MAIN)
        );
        assertEq(
            IERC721(tokensTwo).ownerOf(tokensTwo_tokenId),
            address(TEST_WALLET_MAIN)
        );

        approvePrank(TEST_WALLET_MAIN, tokensOne, tokensOne_tokenId);
        approvePrank(TEST_WALLET_MAIN, tokensTwo, tokensTwo_tokenId);

        vm.prank(TEST_WALLET_MAIN);
        escrow.createItem(address(tokensOne), tokensOne_tokenId);

        vm.prank(TEST_WALLET_MAIN);
        escrow.createItem(address(tokensTwo), tokensTwo_tokenId);

        assertEq(
            IERC721(tokensOne).ownerOf(tokensOne_tokenId),
            address(escrow)
        );
        assertEq(
            IERC721(tokensTwo).ownerOf(tokensTwo_tokenId),
            address(escrow)
        );

        // Create a purchase for TEST_WALLET_1 for both tokens
        escrow.createPurchase(
            address(tokensOne),
            tokensOne_tokenId,
            address(TEST_WALLET_1)
        );

        escrow.createPurchase(
            address(tokensTwo),
            tokensTwo_tokenId,
            address(TEST_WALLET_1)
        );

        // Claim both tokens
        vm.prank(TEST_WALLET_1);
        escrow.claimItem(address(tokensOne), tokensOne_tokenId);
        vm.prank(TEST_WALLET_1);
        escrow.claimItem(address(tokensTwo), tokensTwo_tokenId);

        // Check that both tokens are owned by TEST_WALLET_1
        assertEq(
            IERC721(tokensOne).ownerOf(tokensOne_tokenId),
            address(TEST_WALLET_1)
        );
        assertEq(
            IERC721(tokensTwo).ownerOf(tokensTwo_tokenId),
            address(TEST_WALLET_1)
        );
    }

    //#endregion

    //#region Helpers
    function mintAndApprove() internal returns (uint256) {
        uint256 tokenId = tokensOne.mint();
        tokensOne.approve(address(escrow), tokenId);
        return tokenId;
    }

    function mintPrank(
        address pranker,
        ClancyERC721 ercContract
    ) internal returns (uint256) {
        vm.prank(pranker);
        return IClancyERC721(ercContract).mint();
    }

    function approvePrank(
        address pranker,
        ClancyERC721 ercContract,
        uint256 tokenId
    ) internal {
        vm.prank(pranker);
        IERC721(ercContract).approve(address(escrow), tokenId);
    }
    //#endregion
}
