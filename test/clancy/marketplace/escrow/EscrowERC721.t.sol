// SPDX-License-Identifier: None
pragma solidity ^0.8.19;

import "forge-std/Test.sol";

import {IEscrowERC721_Test} from "./IEscrowERC721.t.sol";

import {ClancyERC721} from "clancy/ERC/ERC721/ClancyERC721.sol";
import {IEscrowERC721, EscrowERC721} from "clancy/marketplace/escrow/EscrowERC721.sol";
import {IClancyMarketplaceERC721, ClancyMarketplaceERC721} from "clancy/marketplace/ClancyMarketplaceERC721.sol";

import {Forks} from "test-helpers/Titan/Forks.sol";

contract EscrowERC721_Test is IEscrowERC721_Test, Forks {
    ClancyERC721 clancyERC721;
    EscrowERC721 escrow;

    uint32 public escrow_max_items;

    function setUp() public {
        escrow = new EscrowERC721();
        escrow_max_items = escrow.MAX_ITEMS();

        clancyERC721 = new ClancyERC721(NAME, SYMBOL, MAX_SUPPLY, BASE_URI);
        clancyERC721.setPublicMintEnabled(true);
    }

    //#region setVendorStatus
    function test_setAllowedContract_WhenNotOwner_ShouldRevert() public {
        vm.prank(w_main);
        vm.expectRevert("Ownable: caller is not the owner");
        escrow.setVendorStatus(address(clancyERC721), true);
    }

    function test_setAllowedContract_ForZeroAddress_ShouldRevert() public {
        vm.expectRevert(IClancyMarketplaceERC721.InputContractInvalid.selector);
        escrow.setVendorStatus(address(0), true);
    }

    function test_setAllowedContract_ForNonERC721Contract_ShouldRevert()
        public
    {
        vm.expectRevert(IClancyMarketplaceERC721.InputContractInvalid.selector);
        escrow.setVendorStatus(w_main, true);
    }

    function test_setAllowedContract_ShouldSucceed() public {
        escrow.setVendorStatus(address(clancyERC721), true);
    }

    //#endregion

    //#region getAllowedContract
    function test_getAllowedContract() public {
        escrow.setVendorStatus(address(clancyERC721), true);
        assertEq(escrow.vendors(address(clancyERC721)), true);
    }

    function test_getAllowedContract_ShouldReturnFalse() public {
        assertEq(escrow.vendors(address(clancyERC721)), false);
    }

    //#endregion

    //#region createItem
    function test_createItem_AsNonOwner_ShouldRevert() public {
        escrowSetup();

        uint32 tokenId = clancyERC721.mint();
        vm.expectRevert("ERC721: caller is not token owner or approved");
        escrow.createItem(address(clancyERC721), tokenId);
    }

    function test_createItem_AsUnapproved_ShouldRevert() public {
        escrowSetup();

        uint32 tokenId = clancyERC721.mint();
        vm.expectRevert("ERC721: caller is not token owner or approved");
        escrow.createItem(address(clancyERC721), tokenId);
    }

    function test_createItem_ShouldPass() public returns (uint32) {
        escrowSetup();

        uint32 tokenId = clancyERC721.mint();

        assertEq(clancyERC721.balanceOf(address(this)), 1);
        assertEq(clancyERC721.ownerOf(tokenId), address(this));
        assertEq(clancyERC721.balanceOf(address(escrow)), 0);

        clancyERC721.approve(address(escrow), tokenId);

        vm.expectEmit(true, true, true, true, address(escrow));
        emit EscrowItemCreated({
            itemId: escrow.itemIdCounter() + 1,
            tokenId: tokenId,
            contractAddress: address(clancyERC721),
            seller: address(this)
        });
        uint32 escrowItemId = escrow.createItem(address(clancyERC721), tokenId);
        assertEq(clancyERC721.ownerOf(tokenId), address(escrow));
        assertEq(clancyERC721.balanceOf(address(escrow)), 1);
        assertEq(clancyERC721.balanceOf(address(this)), 0);
        return escrowItemId;
    }

    function test_createItem_MaxItems_ShouldPass() public {
        escrowSetup();

        for (uint32 i; i < escrow_max_items; i++) {
            uint32 tokenId = clancyERC721.mint();
            clancyERC721.approve(address(escrow), tokenId);
            vm.expectEmit(true, true, true, true, address(escrow));
            emit EscrowItemCreated({
                itemId: escrow.itemIdCounter() + 1,
                tokenId: tokenId,
                contractAddress: address(clancyERC721),
                seller: address(this)
            });
            escrow.createItem(address(clancyERC721), tokenId);
        }

        assertEq(clancyERC721.balanceOf(address(escrow)), escrow_max_items);
        assertEq(clancyERC721.balanceOf(address(this)), 0);

        console.log("Created", escrow.itemIdCounter(), "items.");
    }

    function test_createItem_MaxItemsPlusOne_ShouldRevert() public {
        escrowSetup();

        uint32 tokenId = 0;

        for (uint32 i; i < escrow_max_items; i++) {
            tokenId = clancyERC721.mint();
            clancyERC721.approve(address(escrow), tokenId);
            escrow.createItem(address(clancyERC721), tokenId);
        }
        // console.log(
        //     "Active listing count: %s",
        //     escrow.getActiveListingCount()
        // );
        tokenId = clancyERC721.mint();
        clancyERC721.approve(address(escrow), tokenId);

        vm.expectRevert(
            abi.encodeWithSelector(IEscrowERC721.EscrowFull.selector)
        );
        escrow.createItem(address(clancyERC721), tokenId);
    }

    //#endregion

    //#region getItem

    function test_getItem_DoesNotExist_ShouldReturnZeroes() public {
        escrowSetup();

        EscrowItem memory item;
        (item.itemId, item.seller, item.buyer) = escrow.items(
            address(clancyERC721),
            0
        );

        assertEq(item.seller, address(0));
        assertEq(item.buyer, address(0));
    }

    function test_getItem_ShouldPass() public {
        escrowSetup();

        uint32 tokenId = mintAndApprove();

        uint32 escrowItemId = escrow.createItem(address(clancyERC721), tokenId);

        EscrowItem memory item = escrow.getItem(
            address(clancyERC721),
            escrowItemId
        );

        assertEq(item.seller, address(this));
        assertEq(item.buyer, address(0));
    }

    //#endregion

    //#region cancelItem
    function test_cancelItem_ForNonApprovedContract_ShouldRevert() public {
        escrowSetup();

        uint32 tokenId = mintAndApprove();
        vm.expectRevert(IClancyMarketplaceERC721.InputContractInvalid.selector);
        escrow.cancelItem(address(escrow), tokenId);
    }

    function test_cancelItem_ForNonListedItem_ShouldRevert() public {
        escrowSetup();

        vm.expectRevert(IEscrowERC721.EscrowItemDoesNotExist.selector);
        escrow.cancelItem(address(clancyERC721), 5);
    }

    /* The escrow is approved to transfer the tokens, but cannot cancel the listing
     * from within this contract. It _can_ still use the ERC721 functions to transfer.
     */
    function test_cancelItem_ByApprovedNonSeller_ShouldRevert() public {
        escrowSetup();

        uint32 tokenId = mintAndApprovePrank(w_main);

        vm.prank(address(w_main));
        escrow.createItem(address(clancyERC721), tokenId);

        vm.prank(address(escrow));
        vm.expectRevert(IEscrowERC721.NotTokenSeller.selector);
        escrow.cancelItem(address(clancyERC721), tokenId);
    }

    function test_cancelItem_ByApprovedNonSellerThroughAttackerContract_ShouldRevert()
        public
    {
        escrowSetup();

        uint32 tokenId = mintAndApprovePrank(w_main);

        vm.prank(address(w_main));
        escrow.createItem(address(clancyERC721), tokenId);

        string
            memory attackerFunction = "safeTransferFrom(address,address,uint32)";

        console.log("Attacker function: %s", attackerFunction);

        bytes4 selector = bytes4(keccak256(bytes(attackerFunction)));
        (bool success, ) = address(escrow).call(
            abi.encodeWithSelector(
                selector,
                address(escrow),
                address(this),
                tokenId
            )
        );
        assertEq(success, false);
    }

    function test_cancelItem_AsOwnerButNotSeller_ShouldRevert() public {
        escrowSetup();

        uint32 tokenId = mintAndApprove();
        escrow.createItem(address(clancyERC721), tokenId);

        vm.prank(address(clancyERC721));
        vm.expectRevert(IEscrowERC721.NotTokenSeller.selector);
        escrow.cancelItem(address(clancyERC721), tokenId);
    }

    function test_cancelItem_WhenItemIsSold_ShouldRevert() public {
        escrowSetup();

        uint32 tokenId = mintAndApprove();

        escrow.createItem(address(clancyERC721), tokenId);
        escrow.createPurchase(address(clancyERC721), tokenId, address(w_main));

        vm.expectRevert(IEscrowERC721.EscrowItemIsSold.selector);
        escrow.cancelItem(address(clancyERC721), tokenId);
    }

    function test_cancelItem_ShouldPass() public {
        escrowSetup();

        uint32 tokenId = mintAndApprove();

        uint32 itemId = escrow.createItem(address(clancyERC721), tokenId);
        console.log("Listed item with ID: %s", itemId);

        EscrowItem memory item;
        (item.itemId, item.seller, item.buyer) = escrow.items(
            address(clancyERC721),
            0
        );

        console.log("itemId: %s, seller: %s", item.itemId, item.seller);

        vm.expectEmit(true, true, true, false, address(escrow));
        emit EscrowItemCancelled({
            itemId: itemId,
            tokenId: tokenId,
            contractAddress: address(clancyERC721)
        });
        escrow.cancelItem(address(clancyERC721), tokenId);

        assertEq(clancyERC721.ownerOf(tokenId), address(this));
        assertEq(clancyERC721.balanceOf(address(escrow)), 0);
        assertEq(clancyERC721.balanceOf(address(this)), 1);

        console.log("Cancelled item with ID: %s", itemId);

        // GetItem should return 0
        (item.itemId, item.seller, item.buyer) = escrow.items(
            address(clancyERC721),
            0
        );
        assertEq(item.itemId, 0);
        assertEq(item.seller, address(0));
        assertEq(item.buyer, address(0));
    }

    //#endregion

    //#region createPurchase
    function test_createPurchase_ForNonApprovedContract_ShouldRevert() public {
        escrowSetup();

        uint32 tokenId = mintAndApprove();

        escrow.createItem(address(clancyERC721), tokenId);

        vm.expectRevert(IClancyMarketplaceERC721.InputContractInvalid.selector);
        escrow.createPurchase(address(escrow), tokenId, address(w_main));
    }

    function test_createPurchase_AsNonOwner_ShouldRevert() public {
        escrowSetup();

        uint32 tokenId = mintAndApprove();

        escrow.createItem(address(clancyERC721), tokenId);

        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(address(clancyERC721));
        escrow.createPurchase(address(clancyERC721), tokenId, address(w_main));
    }

    function test_createPurchase_SetBuyerToSeller_ShouldRevert() public {
        escrowSetup();

        uint32 tokenId = mintAndApprove();

        escrow.createItem(address(clancyERC721), tokenId);

        vm.expectRevert(IEscrowERC721.EscrowItemBuyerCannotBeSeller.selector);
        escrow.createPurchase(address(clancyERC721), tokenId, address(this));
    }

    function test_createPurchase_Twice_ShouldRevert() public {
        escrowSetup();

        uint32 tokenId = mintAndApprove();

        escrow.createItem(address(clancyERC721), tokenId);

        escrow.createPurchase(address(clancyERC721), tokenId, address(w_main));

        vm.expectRevert(IEscrowERC721.EscrowItemIsSold.selector);
        escrow.createPurchase(address(clancyERC721), tokenId, address(w_main));
    }

    function test_createPurchase_ShouldPass() public {
        escrowSetup();

        uint32 tokenId = mintAndApprove();

        uint32 itemId = escrow.createItem(address(clancyERC721), tokenId);

        vm.expectEmit(true, true, true, true, address(escrow));
        emit EscrowItemPurchaseCreated({
            itemId: itemId,
            tokenId: tokenId,
            contractAddress: address(clancyERC721),
            seller: address(this),
            buyer: address(w_main)
        });
        escrow.createPurchase(address(clancyERC721), tokenId, address(w_main));
    }

    //#endregion

    //#region claimItem
    function test_claimItem_ForInvalidId_ShouldRevert() public {
        escrowSetup();

        uint32 tokenId = mintAndApprove();

        escrow.createItem(address(clancyERC721), tokenId);

        vm.expectRevert(IEscrowERC721.EscrowItemDoesNotExist.selector);
        escrow.claimItem(address(clancyERC721), tokenId + 1);
    }

    function test_claimItem_SenderIsNotBuyer_ShouldRevert() public {
        escrowSetup();

        uint32 tokenId = mintAndApprove();

        escrow.createItem(address(clancyERC721), tokenId);
        escrow.createPurchase(address(clancyERC721), tokenId, address(w_main));

        vm.expectRevert(IEscrowERC721.NotTokenBuyer.selector);
        escrow.claimItem(address(clancyERC721), tokenId);
    }

    function test_claimItem_ItemIsNotSold_ShouldRevert() public {
        escrowSetup();

        uint32 tokenId = mintAndApprove();

        escrow.createItem(address(clancyERC721), tokenId);

        vm.expectRevert(IEscrowERC721.EscrowItemIsNotSold.selector);
        escrow.claimItem(address(clancyERC721), tokenId);
    }

    function test_claimItem_WhenContractIsPaused_ShouldRevert() public {
        escrowSetup();

        uint32 tokenId = mintAndApprove();

        escrow.createItem(address(clancyERC721), tokenId);
        escrow.createPurchase(address(clancyERC721), tokenId, address(w_main));

        escrow.pause();
        vm.expectRevert("Pausable: paused");
        vm.prank(address(w_main));
        escrow.claimItem(address(clancyERC721), tokenId);
    }

    function test_claimItem_ShouldPass() public {
        escrowSetup();

        uint32 tokenId = mintAndApprove();

        uint32 itemId = escrow.createItem(address(clancyERC721), tokenId);
        console.log("Created item with ID: %s", itemId);

        escrow.createPurchase(address(clancyERC721), tokenId, address(w_main));

        vm.expectEmit(true, true, true, false, address(escrow));
        emit EscrowItemClaimed({
            itemId: itemId,
            tokenId: tokenId,
            contractAddress: address(clancyERC721)
        });

        vm.prank(address(w_main));
        escrow.claimItem(address(clancyERC721), tokenId);
        assertEq(clancyERC721.ownerOf(tokenId), address(w_main));
    }

    //#endregion

    //#region Helpers
    function escrowSetup() internal {
        clancyERC721 = new ClancyERC721(
            NAME,
            SYMBOL,
            escrow_max_items + 1,
            BASE_URI
        );
        clancyERC721.setPublicMintEnabled(true);

        escrow = new EscrowERC721();
        escrow.setVendorStatus(address(clancyERC721), true);
    }

    function mintAndApprove() internal returns (uint32) {
        uint32 tokenId = clancyERC721.mint();
        clancyERC721.approve(address(escrow), tokenId);
        return tokenId;
    }

    function mintAndApprovePrank(address pranker) internal returns (uint32) {
        vm.prank(pranker);
        uint32 tokenId = clancyERC721.mint();
        vm.prank(pranker);
        clancyERC721.approve(address(escrow), tokenId);
        return tokenId;
    }
    //#endregion
}
