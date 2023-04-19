// SPDX-License-Identifier: None
pragma solidity ^0.8.19;

import "forge-std/Test.sol";

import {IERC721} from "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

import {IClancyERC721, ClancyERC721} from "clancy/ERC/ERC721/ClancyERC721.sol";
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

    //#region newOffer
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

    function test_createOffer_CannotBeFromZeroAddress_ShouldFail() public {
        vm.deal(address(0), 1 ether);
        uint256 tokenId = mintAndApprove();
        vm.expectRevert(IOffersERC721_v1.OfferorCannotBeZeroAddress.selector);
        vm.prank(address(0));
        offers.createOffer{value: 1 ether}(address(clancyERC721), tokenId);
    }

    function test_createOffer_OfferCannotBeTokenOwner_ShouldFail() public {
        uint256 tokenId = mintAndApprove();
        vm.expectRevert(IOffersERC721_v1.OfferorCannotBeTokenOwner.selector);
        offers.createOffer{value: 1 ether}(address(clancyERC721), tokenId);
    }

    function test_createOffer_TokenDoesNotExist_ShouldFail() public {
        uint256 tokenId = mintAndApprove();
        vm.expectRevert("ERC721: invalid token ID");
        offers.createOffer{value: 1 ether}(address(clancyERC721), tokenId + 1);
    }

    function test_createOffer_ValidContract_ShouldPass() public {
        vm.startPrank(TEST_WALLET_MAIN);

        uint256 tokenId = mintAndApprove();
        uint256 itemId = offers.getItemIdCounter();

        vm.stopPrank();

        vm.expectEmit(true, true, true, true, address(offers));
        emit OfferEvent({
            offerType: "New",
            itemId: itemId + 1,
            contractAddress: address(clancyERC721),
            tokenId: tokenId,
            tokenOwner: TEST_WALLET_MAIN,
            offeror: address(this),
            value: 1 ether
        });
        offers.createOffer{value: 1 ether}(address(clancyERC721), tokenId);
    }

    //#endregion newOffer

    //#region outbidOffer

    function test_outbidOffer_ValueLTExistingOffer_ShouldFail() public {
        vm.startPrank(TEST_WALLET_MAIN);

        uint256 tokenId = mintAndApprove();

        vm.stopPrank();

        offers.createOffer{value: 1 ether}(address(clancyERC721), tokenId);

        vm.expectRevert(IOffersERC721_v1.OfferMustBeGTExistingOffer.selector);
        offers.createOffer{value: 1 ether}(address(clancyERC721), tokenId);
    }

    function test_outbidOffer_ValueGTExistingOffer_ShouldPass() public {
        vm.deal(TEST_WALLET_1, 3 ether);
        vm.startPrank(TEST_WALLET_MAIN);

        uint256 tokenId = mintAndApprove();

        vm.stopPrank();

        offers.createOffer{value: 1 ether}(address(clancyERC721), tokenId);

        uint256 balanceBefore = address(this).balance;
        uint256 itemId = offers.getItemIdCounter();

        vm.startPrank(TEST_WALLET_1);

        vm.expectEmit(true, true, true, true, address(offers));
        emit OfferEvent({
            offerType: "Outbid",
            itemId: itemId,
            contractAddress: address(clancyERC721),
            tokenId: tokenId,
            tokenOwner: TEST_WALLET_MAIN,
            offeror: TEST_WALLET_1,
            value: 2 ether
        });
        offers.createOffer{value: 2 ether}(address(clancyERC721), tokenId);

        vm.stopPrank();

        uint256 balanceAfter = address(this).balance;
        assertEq(balanceAfter, balanceBefore + 1 ether);
        assertEq(TEST_WALLET_1.balance, 1 ether);
    }

    //#endregion outbidOffer

    //#endregion

    //#region acceptOffer

    function test_acceptOffer_ItemDoesNotExist_ShouldFail() public {
        vm.expectRevert(IOffersERC721_v1.OfferDoesNotExist.selector);
        offers.acceptOffer(address(clancyERC721), 1);
    }

    function test_acceptOffer_NotTokenOwner_ShouldFail() public {
        vm.startPrank(TEST_WALLET_MAIN);

        uint256 tokenId = mintAndApprove();

        vm.stopPrank();

        offers.createOffer{value: 1 ether}(address(clancyERC721), tokenId);

        vm.expectRevert(IClancyMarketplaceERC721_v1.NotTokenOwner.selector);
        offers.acceptOffer(address(clancyERC721), 1);
    }

    function test_acceptOffer_InsufficientContractBalance_ShouldFail() public {
        vm.startPrank(TEST_WALLET_MAIN);

        uint256 tokenId = mintAndApprove();

        vm.stopPrank();

        offers.createOffer{value: 1 ether}(address(clancyERC721), tokenId);
        offers.withdraw();

        vm.startPrank(TEST_WALLET_MAIN);
        vm.expectRevert(IOffersERC721_v1.InsufficientContractBalance.selector);
        offers.acceptOffer(address(clancyERC721), 1);
        vm.stopPrank();
    }

    function test_acceptOffer_ShouldPass() public {
        vm.deal(TEST_WALLET_1, 2 ether);

        vm.startPrank(TEST_WALLET_MAIN);

        uint256 tokenId = mintAndApprove();

        vm.stopPrank();

        vm.prank(TEST_WALLET_1);

        offers.createOffer{value: 1 ether}(address(clancyERC721), tokenId);
        assertEq(address(offers).balance, 1 ether);
        uint256 sellerBalanceBefore = TEST_WALLET_MAIN.balance;
        console.log("sellerBalanceBefore", sellerBalanceBefore);
        uint256 itemId = offers.getItemIdCounter();

        vm.startPrank(TEST_WALLET_MAIN);

        IERC721(clancyERC721).approve(address(offers), tokenId);

        vm.expectEmit(true, true, true, true, address(offers));
        emit OfferEvent({
            offerType: "Accept",
            itemId: itemId,
            contractAddress: address(clancyERC721),
            tokenId: tokenId,
            tokenOwner: TEST_WALLET_MAIN,
            offeror: TEST_WALLET_1,
            value: 1 ether
        });
        offers.acceptOffer(address(clancyERC721), tokenId);
        console.log("sellerBalanceAfter", TEST_WALLET_MAIN.balance);
        assertEq(IERC721(clancyERC721).ownerOf(tokenId), TEST_WALLET_1);
        assertEq(TEST_WALLET_MAIN.balance, sellerBalanceBefore + 1 ether);

        vm.stopPrank();

        OfferItem memory offerItem = offers.getOffer(
            address(clancyERC721),
            itemId
        );
        assertEq(offerItem.itemId, 0);
        assertEq(offerItem.offeror, address(0));
        assertEq(offerItem.offerAmount, 0);
    }

    //#endregion acceptOffer

    //#region cancelOffer
    function test_cancelOffer_NotOwner_ShouldFail() public {
        vm.startPrank(TEST_WALLET_MAIN);

        uint256 tokenId = mintAndApprove();

        vm.stopPrank();

        offers.createOffer{value: 1 ether}(address(clancyERC721), tokenId);

        vm.prank(TEST_WALLET_MAIN);
        vm.expectRevert("Ownable: caller is not the owner");
        offers.cancelOffer(address(clancyERC721), tokenId);
    }

    function test_cancelOffer_ToNonPayable_ShouldFail() public {
        vm.deal(address(clancyERC721), 1 ether);

        uint256 tokenId = mintAndApprove();

        vm.startPrank(address(clancyERC721));

        offers.createOffer{value: 1 ether}(address(clancyERC721), tokenId);

        vm.stopPrank();

        vm.expectRevert();
        offers.cancelOffer(address(clancyERC721), tokenId);
    }

    function test_cancelOffer_ContractHasInsuffienctBalance_ShouldFail()
        public
    {
        vm.startPrank(TEST_WALLET_MAIN);

        uint256 tokenId = mintAndApprove();

        vm.stopPrank();

        offers.createOffer{value: 1 ether}(address(clancyERC721), tokenId);

        offers.withdraw();

        vm.expectRevert(IOffersERC721_v1.InsufficientContractBalance.selector);
        offers.cancelOffer(address(clancyERC721), tokenId);
    }

    function test_cancelOffer_ShouldPass() public {
        vm.deal(TEST_WALLET_1, 1 ether);

        vm.startPrank(TEST_WALLET_MAIN);

        uint256 tokenId = mintAndApprove();

        vm.stopPrank();

        vm.startPrank(TEST_WALLET_1);

        uint256 balanceBefore = TEST_WALLET_1.balance;
        offers.createOffer{value: 1 ether}(address(clancyERC721), tokenId);
        uint256 balanceAfter = TEST_WALLET_1.balance;
        assertEq(balanceAfter, balanceBefore - 1 ether);

        vm.stopPrank();

        uint256 itemId = offers.getItemIdCounter();
        vm.expectEmit(true, true, true, true, address(offers));
        emit OfferEvent({
            offerType: "Cancel",
            itemId: itemId,
            contractAddress: address(clancyERC721),
            tokenId: tokenId,
            tokenOwner: TEST_WALLET_MAIN,
            offeror: TEST_WALLET_1,
            value: 1 ether
        });
        offers.cancelOffer(address(clancyERC721), tokenId);

        balanceAfter = TEST_WALLET_1.balance;
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
        assertEq(offer.itemId, itemId);
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
