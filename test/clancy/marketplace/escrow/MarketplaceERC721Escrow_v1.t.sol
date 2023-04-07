// SPDX-License-Identifier: None
pragma solidity ^0.8.19;

import "forge-std/Test.sol";

import {IMarketplaceERC721Escrow_v1_Test} from "./IMarketplaceERC721Escrow_v1.t.sol";

import {ClancyERC721} from "clancy/ERC/ClancyERC721.sol";
import {IMarketplaceERC721Escrow_v1, MarketplaceERC721Escrow_v1} from "clancy/marketplace/escrow/MarketplaceERC721Escrow_v1.sol";

contract MarketplaceERC721Escrow_v1_Test is
    IMarketplaceERC721Escrow_v1_Test,
    Test
{
    ClancyERC721 clancyERC721;
    MarketplaceERC721Escrow_v1 marketplace;

    uint256 public marketplace_max_items;

    function setUp() public {
        marketplace = new MarketplaceERC721Escrow_v1();
        marketplace_max_items = marketplace.MAX_ITEMS();

        clancyERC721 = new ClancyERC721(NAME, SYMBOL, MAX_SUPPLY, BASE_URI);
        clancyERC721.setPublicMintStatus(true);
    }

    //#region setAllowedContract
    function test_setAllowedContract_WhenNotOwner_ShouldRevert() public {
        vm.prank(TEST_WALLET_MAIN);
        vm.expectRevert("Ownable: caller is not the owner");
        marketplace.setAllowedContract(address(clancyERC721), true);
    }

    function test_setAllowedContract_ForZeroAddress_ShouldRevert() public {
        vm.expectRevert(
            IMarketplaceERC721Escrow_v1.InputContractInvalid.selector
        );
        marketplace.setAllowedContract(address(0), true);
    }

    function test_setAllowedContract_ForNonERC721Contract_ShouldRevert()
        public
    {
        vm.expectRevert(
            IMarketplaceERC721Escrow_v1.InputContractInvalid.selector
        );
        marketplace.setAllowedContract(TEST_WALLET_MAIN, true);
    }

    function test_setAllowedContract_ShouldSucceed() public {
        marketplace.setAllowedContract(address(clancyERC721), true);
    }

    //#endregion

    //#region getAllowedContract
    function test_getAllowedContract() public {
        marketplace.setAllowedContract(address(clancyERC721), true);
        assertEq(marketplace.getAllowedContract(address(clancyERC721)), true);
    }

    function test_getAllowedContract_ShouldReturnFalse() public {
        assertEq(marketplace.getAllowedContract(address(clancyERC721)), false);
    }

    //#endregion

    //#region createItem
    function test_createItem_AsNonOwner_ShouldRevert() public {
        marketplaceSetup();

        uint256 tokenId = clancyERC721.mint();
        vm.expectRevert("ERC721: caller is not token owner or approved");
        marketplace.createItem(address(clancyERC721), tokenId);
    }

    function test_createItem_AsUnapproved_ShouldRevert() public {
        marketplaceSetup();

        uint256 tokenId = clancyERC721.mint();
        vm.expectRevert("ERC721: caller is not token owner or approved");
        marketplace.createItem(address(clancyERC721), tokenId);
    }

    function test_createItem_ShouldPass() public returns (uint256) {
        marketplaceSetup();

        uint256 tokenId = clancyERC721.mint();

        assertEq(clancyERC721.balanceOf(address(this)), 1);
        assertEq(clancyERC721.ownerOf(tokenId), address(this));
        assertEq(clancyERC721.balanceOf(address(marketplace)), 0);

        clancyERC721.approve(address(marketplace), tokenId);

        vm.expectEmit(true, true, true, true, address(marketplace));
        emit MarketplaceItemCreated(
            marketplace.getItemIdCounter() + 1,
            address(clancyERC721),
            tokenId,
            address(this)
        );
        uint256 marketplaceItemId = marketplace.createItem(
            address(clancyERC721),
            tokenId
        );
        assertEq(clancyERC721.ownerOf(tokenId), address(marketplace));
        assertEq(clancyERC721.balanceOf(address(marketplace)), 1);
        assertEq(clancyERC721.balanceOf(address(this)), 0);
        return marketplaceItemId;
    }

    function test_createItem_MaxItems_ShouldPass() public {
        marketplaceSetup();

        for (uint256 i = 0; i < marketplace_max_items; i++) {
            uint256 tokenId = clancyERC721.mint();
            clancyERC721.approve(address(marketplace), tokenId);
            vm.expectEmit(true, true, true, true, address(marketplace));
            emit MarketplaceItemCreated(
                marketplace.getItemIdCounter() + 1,
                address(clancyERC721),
                tokenId,
                address(this)
            );
            marketplace.createItem(address(clancyERC721), tokenId);
        }

        assertEq(
            clancyERC721.balanceOf(address(marketplace)),
            marketplace_max_items
        );
        assertEq(clancyERC721.balanceOf(address(this)), 0);

        console.log("Created", marketplace.getItemIdCounter(), "items.");
    }

    function test_createItem_MaxItemsPlusOne_ShouldRevert() public {
        marketplaceSetup();

        uint256 tokenId = 0;

        for (uint256 i = 0; i < marketplace_max_items; i++) {
            tokenId = clancyERC721.mint();
            clancyERC721.approve(address(marketplace), tokenId);
            marketplace.createItem(address(clancyERC721), tokenId);
        }
        // console.log(
        //     "Active listing count: %s",
        //     marketplace.getActiveListingCount()
        // );
        tokenId = clancyERC721.mint();
        clancyERC721.approve(address(marketplace), tokenId);

        vm.expectRevert(
            abi.encodeWithSelector(
                IMarketplaceERC721Escrow_v1.MarketplaceFull.selector
            )
        );
        marketplace.createItem(address(clancyERC721), tokenId);
    }

    //#endregion

    //#region getItem

    function test_getItem_DoesNotExist_ShouldReturnZeroes() public {
        marketplaceSetup();

        IMarketplaceERC721Escrow_v1.MarketplaceItem memory item = marketplace
            .getItem(address(clancyERC721), 0);

        assertEq(item.seller, address(0));
        assertEq(item.buyer, address(0));
    }

    function test_getItem_ShouldPass() public {
        marketplaceSetup();

        uint256 tokenId = mintAndApprove();
        marketplace.createItem(address(clancyERC721), tokenId);

        IMarketplaceERC721Escrow_v1.MarketplaceItem memory item = marketplace
            .getItem(address(clancyERC721), tokenId);

        assertEq(item.seller, address(this));
        assertEq(item.buyer, address(0));
    }

    //#endregion

    //#region cancelItem
    function test_cancelItem_ForNonApprovedContract_ShouldRevert() public {
        marketplaceSetup();

        uint256 tokenId = mintAndApprove();
        vm.expectRevert(
            IMarketplaceERC721Escrow_v1.InputContractInvalid.selector
        );
        marketplace.cancelItem(address(marketplace), tokenId);
    }

    function test_cancelItem_ForNonListedItem_ShouldRevert() public {
        marketplaceSetup();

        vm.expectRevert(IMarketplaceERC721Escrow_v1.ItemDoesNotExist.selector);
        marketplace.cancelItem(address(clancyERC721), 5);
    }

    /* The marketplace is approved to transfer the tokens, but cannot cancel the listing
     * from within this contract. It _can_ still use the ERC721 functions to transfer.
     */
    function test_cancelItem_ByApprovedNonSeller_ShouldRevert() public {
        marketplaceSetup();

        uint256 tokenId = mintAndApprovePrank(TEST_WALLET_MAIN);

        vm.prank(address(TEST_WALLET_MAIN));
        marketplace.createItem(address(clancyERC721), tokenId);

        vm.prank(address(marketplace));
        vm.expectRevert(IMarketplaceERC721Escrow_v1.NotTokenSeller.selector);
        marketplace.cancelItem(address(clancyERC721), tokenId);
    }

    function test_cancelItem_ByApprovedNonSellerThroughAttackerContract_ShouldRevert()
        public
    {
        marketplaceSetup();

        uint256 tokenId = mintAndApprovePrank(TEST_WALLET_MAIN);

        vm.prank(address(TEST_WALLET_MAIN));
        marketplace.createItem(address(clancyERC721), tokenId);

        string
            memory attackerFunction = "safeTransferFrom(address,address,uint256)";

        console.log("Attacker function: %s", attackerFunction);

        bytes4 selector = bytes4(keccak256(bytes(attackerFunction)));
        (bool success, ) = address(marketplace).call(
            abi.encodeWithSelector(
                selector,
                address(marketplace),
                address(this),
                tokenId
            )
        );
        assertEq(success, false);
    }

    function test_cancelItem_AsOwnerButNotSeller_ShouldRevert() public {
        marketplaceSetup();

        uint256 tokenId = mintAndApprove();
        marketplace.createItem(address(clancyERC721), tokenId);

        vm.prank(address(clancyERC721));
        vm.expectRevert(IMarketplaceERC721Escrow_v1.NotTokenSeller.selector);
        marketplace.cancelItem(address(clancyERC721), tokenId);
    }

    function test_cancelItem_WhenItemIsSold_ShouldRevert() public {
        marketplaceSetup();

        uint256 tokenId = mintAndApprove();

        marketplace.createItem(address(clancyERC721), tokenId);
        marketplace.createPurchase(
            address(clancyERC721),
            tokenId,
            address(TEST_WALLET_MAIN)
        );

        vm.expectRevert(IMarketplaceERC721Escrow_v1.ItemIsSold.selector);
        marketplace.cancelItem(address(clancyERC721), tokenId);
    }

    function test_cancelItem_ShouldPass() public {
        marketplaceSetup();

        uint256 tokenId = mintAndApprove();

        uint256 itemId = marketplace.createItem(address(clancyERC721), tokenId);
        console.log("Listed item with ID: %s", itemId);

        IMarketplaceERC721Escrow_v1.MarketplaceItem memory item = marketplace
            .getItem(address(clancyERC721), tokenId);
        console.log("itemId: %s, seller: %s", item.itemId, item.seller);

        vm.expectEmit(true, true, true, false, address(marketplace));
        emit MarketplaceItemCancelled(itemId, address(clancyERC721), tokenId);
        marketplace.cancelItem(address(clancyERC721), tokenId);

        assertEq(clancyERC721.ownerOf(tokenId), address(this));
        assertEq(clancyERC721.balanceOf(address(marketplace)), 0);
        assertEq(clancyERC721.balanceOf(address(this)), 1);

        console.log("Cancelled item with ID: %s", itemId);

        // GetItem should return 0
        item = marketplace.getItem(address(clancyERC721), tokenId);
        assertEq(item.itemId, 0);
        assertEq(item.seller, address(0));
        assertEq(item.buyer, address(0));
    }

    //#endregion

    //#region createPurchase
    function test_createPurchase_ForNonApprovedContract_ShouldRevert() public {
        marketplaceSetup();

        uint256 tokenId = mintAndApprove();

        marketplace.createItem(address(clancyERC721), tokenId);

        vm.expectRevert(
            IMarketplaceERC721Escrow_v1.InputContractInvalid.selector
        );
        marketplace.createPurchase(
            address(marketplace),
            tokenId,
            address(TEST_WALLET_MAIN)
        );
    }

    function test_createPurchase_AsNonOwner_ShouldRevert() public {
        marketplaceSetup();

        uint256 tokenId = mintAndApprove();

        marketplace.createItem(address(clancyERC721), tokenId);

        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(address(clancyERC721));
        marketplace.createPurchase(
            address(clancyERC721),
            tokenId,
            address(TEST_WALLET_MAIN)
        );
    }

    function test_createPurchase_SetBuyerToSeller_ShouldRevert() public {
        marketplaceSetup();

        uint256 tokenId = mintAndApprove();

        marketplace.createItem(address(clancyERC721), tokenId);

        vm.expectRevert(
            IMarketplaceERC721Escrow_v1.ItemBuyerCannotBeSeller.selector
        );
        marketplace.createPurchase(
            address(clancyERC721),
            tokenId,
            address(this)
        );
    }

    function test_createPurchase_Twice_ShouldRevert() public {
        marketplaceSetup();

        uint256 tokenId = mintAndApprove();

        marketplace.createItem(address(clancyERC721), tokenId);

        marketplace.createPurchase(
            address(clancyERC721),
            tokenId,
            address(TEST_WALLET_MAIN)
        );

        vm.expectRevert(IMarketplaceERC721Escrow_v1.ItemIsSold.selector);
        marketplace.createPurchase(
            address(clancyERC721),
            tokenId,
            address(TEST_WALLET_MAIN)
        );
    }

    function test_createPurchase_ShouldPass() public {
        marketplaceSetup();

        uint256 tokenId = mintAndApprove();

        uint256 itemId = marketplace.createItem(address(clancyERC721), tokenId);

        vm.expectEmit(true, true, true, true, address(marketplace));
        emit MarketplaceItemPurchaseCreated(
            itemId,
            address(clancyERC721),
            tokenId,
            address(this),
            address(TEST_WALLET_MAIN)
        );
        marketplace.createPurchase(
            address(clancyERC721),
            tokenId,
            address(TEST_WALLET_MAIN)
        );
    }

    //#endregion

    //#region claimItem
    function test_claimItem_ForInvalidId_ShouldRevert() public {
        marketplaceSetup();

        uint256 tokenId = mintAndApprove();

        marketplace.createItem(address(clancyERC721), tokenId);

        vm.expectRevert(IMarketplaceERC721Escrow_v1.ItemDoesNotExist.selector);
        marketplace.claimItem(address(clancyERC721), tokenId + 1);
    }

    function test_claimItem_SenderIsNotBuyer_ShouldRevert() public {
        marketplaceSetup();

        uint256 tokenId = mintAndApprove();

        marketplace.createItem(address(clancyERC721), tokenId);
        marketplace.createPurchase(
            address(clancyERC721),
            tokenId,
            address(TEST_WALLET_MAIN)
        );

        vm.expectRevert(IMarketplaceERC721Escrow_v1.NotTokenBuyer.selector);
        marketplace.claimItem(address(clancyERC721), tokenId);
    }

    function test_claimItem_ItemIsNotSold_ShouldRevert() public {
        marketplaceSetup();

        uint256 tokenId = mintAndApprove();

        marketplace.createItem(address(clancyERC721), tokenId);

        vm.expectRevert(IMarketplaceERC721Escrow_v1.ItemIsNotSold.selector);
        marketplace.claimItem(address(clancyERC721), tokenId);
    }

    function test_claimItem_WhenContractIsPaused_ShouldRevert() public {
        marketplaceSetup();

        uint256 tokenId = mintAndApprove();

        marketplace.createItem(address(clancyERC721), tokenId);
        marketplace.createPurchase(
            address(clancyERC721),
            tokenId,
            address(TEST_WALLET_MAIN)
        );

        marketplace.pause();
        vm.expectRevert("Pausable: paused");
        vm.prank(address(TEST_WALLET_MAIN));
        marketplace.claimItem(address(clancyERC721), tokenId);
    }

    function test_claimItem_ShouldPass() public {
        marketplaceSetup();

        uint256 tokenId = mintAndApprove();

        uint256 itemId = marketplace.createItem(address(clancyERC721), tokenId);
        console.log("Created item with ID: %s", itemId);

        marketplace.createPurchase(
            address(clancyERC721),
            tokenId,
            address(TEST_WALLET_MAIN)
        );

        vm.expectEmit(true, true, true, false, address(marketplace));
        emit MarketplaceItemClaimed(itemId, address(clancyERC721), tokenId);

        vm.prank(address(TEST_WALLET_MAIN));
        marketplace.claimItem(address(clancyERC721), tokenId);
        assertEq(clancyERC721.ownerOf(tokenId), address(TEST_WALLET_MAIN));
    }

    //#endregion

    //#region Helpers
    function marketplaceSetup() internal {
        clancyERC721 = new ClancyERC721(
            NAME,
            SYMBOL,
            marketplace_max_items + 1,
            BASE_URI
        );
        clancyERC721.setPublicMintStatus(true);

        marketplace = new MarketplaceERC721Escrow_v1();
        marketplace.setAllowedContract(address(clancyERC721), true);
    }

    function mintAndApprove() internal returns (uint256) {
        uint256 tokenId = clancyERC721.mint();
        clancyERC721.approve(address(marketplace), tokenId);
        return tokenId;
    }

    function mintAndApprovePrank(address pranker) internal returns (uint256) {
        vm.prank(pranker);
        uint256 tokenId = clancyERC721.mint();
        vm.prank(pranker);
        clancyERC721.approve(address(marketplace), tokenId);
        return tokenId;
    }
    //#endregion
}
