// SPDX-License-Identifier: None
pragma solidity ^0.8.19;

import "forge-std/Test.sol";

import {IERC721} from "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

import {IClancyERC721, ClancyERC721} from "clancy/ERC/ClancyERC721.sol";
import {IOffersERC721_v1, OffersERC721_v1} from "clancy/marketplace/offers/OffersERC721_v1.sol";
import {IOffersERC721_v1_Test} from "./IOffersERC721_v1.t.sol";
import {IClancyMarketplaceERC721_v1, ClancyMarketplaceERC721_v1} from "clancy/marketplace/ClancyMarketplaceERC721_v1.sol";

contract MarketplaceOffersERC721_Test is Test, IOffersERC721_v1_Test {
    ClancyERC721 clancyERC721;
    OffersERC721_v1 offers;

    function setUp() public {
        vm.deal(TEST_WALLET_MAIN, 2 ether);

        // ClancyERC721 Setup
        clancyERC721 = new ClancyERC721(NAME, SYMBOL, MAX_SUPPLY, BASE_URI);
        clancyERC721.setPublicMintStatus(true);
        clancyERC721.setBurnStatus(true);

        // Offers Setup
        offers = new OffersERC721_v1();
        offers.setAllowedContract(address(clancyERC721), true);
    }

    //#region createOffer

    function test_createOffer_ValueLTEZero_ShouldFail() public {
        uint256 tokenId = mintAndApprove();
        vm.expectRevert(IOffersERC721_v1.OfferCannotBeLTEZero.selector);
        offers.createOffer{value: 0}(address(clancyERC721), tokenId);
    }

    function test_createOffer_InvalidContract_ShouldFail() public {
        uint256 tokenId = mintAndApprove();

        vm.expectRevert(
            IClancyMarketplaceERC721_v1.InputContractInvalid.selector
        );
        offers.createOffer{value: 1 ether}(address(0), tokenId);
    }

    function test_createOffer_TokenDoesNotExist_ShouldFail() public {
        uint256 tokenId = mintAndApprove();
        vm.expectRevert("ERC721: invalid token ID");
        offers.createOffer{value: 1 ether}(address(clancyERC721), tokenId + 1);
    }

    function test_createOffer_ValidContract_ShouldPass() public {
        uint256 tokenId = mintAndApprove();
        uint256 itemId = offers.getItemIdCounter();
        vm.expectEmit(true, true, true, false, address(offers));
        emit OfferCreated({
            itemId: itemId + 1,
            contractAddress: address(clancyERC721),
            tokenId: tokenId,
            offeror: address(this)
        });
        offers.createOffer{value: 1 ether}(address(clancyERC721), tokenId);
    }

    //#endregion

    //#region cancelOffer
    function test_cancelOffer_NotOfferor_ShouldFail() public {
        uint256 tokenId = mintAndApprove();
        offers.createOffer{value: 1 ether}(address(clancyERC721), tokenId);

        vm.expectRevert(IOffersERC721_v1.NotOfferor.selector);

        vm.prank(address(TEST_WALLET_MAIN));
        offers.cancelOffer(address(clancyERC721), tokenId);
    }

    function test_cancelOffer_ToNonERC721Reciever_ShouldFail() public {
        vm.deal(address(clancyERC721), 2 ether);
        vm.startPrank(address(clancyERC721));
        uint256 tokenId = mintAndApprove();
        offers.createOffer{value: 1 ether}(address(clancyERC721), tokenId);

        vm.expectRevert("Transfer failed.");
        offers.cancelOffer(address(clancyERC721), tokenId);
        vm.stopPrank();
    }

    function test_cancelOffer_ContractHasInsuffienctBalance_ShouldFail()
        public
    {
        vm.startPrank(TEST_WALLET_MAIN);
        uint256 tokenId = mintAndApprove();
        offers.createOffer{value: 1 ether}(address(clancyERC721), tokenId);
        vm.stopPrank();

        offers.withdraw();

        vm.startPrank(TEST_WALLET_MAIN);

        vm.expectRevert(IOffersERC721_v1.InsufficientContractBalance.selector);
        offers.cancelOffer(address(clancyERC721), tokenId);
        vm.stopPrank();
    }

    function test_cancelOffer_ShouldPass() public {
        vm.startPrank(TEST_WALLET_MAIN);
        uint256 tokenId = mintAndApprove();
        uint256 itemId = offers.getItemIdCounter();

        uint256 balanceBefore = TEST_WALLET_MAIN.balance;
        offers.createOffer{value: 1 ether}(address(clancyERC721), tokenId);
        uint256 balanceAfter = TEST_WALLET_MAIN.balance;
        assertEq(balanceAfter, balanceBefore - 1 ether);

        vm.expectEmit(true, true, true, false, address(offers));
        emit OfferCancelled({
            itemId: itemId,
            contractAddress: address(clancyERC721),
            tokenId: tokenId,
            offeror: TEST_WALLET_MAIN
        });
        offers.cancelOffer(address(clancyERC721), tokenId);
        vm.stopPrank();

        balanceAfter = TEST_WALLET_MAIN.balance;
        assertEq(balanceAfter, balanceBefore);
    }

    //#endregion

    //#region getOffer
    function test_getOffer_ForNonExistentOffer_ShouldPass() public {
        vm.startPrank(TEST_WALLET_MAIN);
        uint256 tokenId = mintAndApprove();
        uint256 itemId = offers.getItemIdCounter();

        OfferItem memory offer = offers.getOffer(
            address(clancyERC721),
            tokenId
        );
        vm.stopPrank();
        assertEq(offer.itemId, 0);
    }

    function test_getOffer_ForExistentOffer_ShouldPass() public {
        vm.startPrank(TEST_WALLET_MAIN);

        uint256 tokenId = mintAndApprove();

        vm.stopPrank();

        offers.createOffer{value: 1 ether}(address(clancyERC721), tokenId);
        OfferItem memory offer = offers.getOffer(
            address(clancyERC721),
            tokenId
        );

        uint256 itemId = offers.getItemIdCounter();

        assertEq(offer.itemId, itemId);
        assertEq(offer.offerAmount, 1 ether);
        assertEq(offer.offeror, address(this));
        assertEq(offer.tokenOwner, address(TEST_WALLET_MAIN));
    }

    //#endregion

    //#region Helpers
    function mintAndApprove() internal returns (uint256) {
        uint256 tokenId = clancyERC721.mint();
        clancyERC721.approve(address(offers), tokenId);
        return tokenId;
    }
    //#endregion
}
