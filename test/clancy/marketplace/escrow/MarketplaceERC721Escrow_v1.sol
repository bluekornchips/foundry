// SPDX-License-Identifier: None
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "clancy-test/helpers/ClancyERC721TestHelpers.sol";
import "clancy/marketplace/escrow/MarketplaceERC721Escrow_v1.sol";

contract MarketplaceERC721Escrow_v1_Test is
    Test,
    IMarketplaceERC721Escrow_v1,
    ClancyERC721TestHelpers
{
    ClancyERC721 clancyERC721;
    MarketplaceERC721Escrow_v1 marketplace;

    uint256 public marketplace_max_items;

    function setUp() public {
        clancyERC721 = new ClancyERC721(NAME, SYMBOL, MAX_SUPPLY, BASE_URI);
        clancyERC721.setPublicMintStatus(true);
        marketplace = new MarketplaceERC721Escrow_v1();
        marketplace_max_items = marketplace.MAX_ITEMS();
    }

    //#region setAllowedContract
    function test_setAllowedContract_WhenNotOwner_ShouldRevert() public {
        vm.prank(DEV_WALLET);
        vm.expectRevert("Ownable: caller is not the owner");
        marketplace.setAllowedContract(address(clancyERC721), true);
    }

    function test_setAllowedContract_ForZeroAddress_ShouldRevert() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                MarketplaceERC721Escrow_v1_InputContractInvalid.selector
            )
        );
        marketplace.setAllowedContract(address(0), true);
    }

    function test_setAllowedContract_ForNonERC721Contract_ShouldRevert()
        public
    {
        vm.expectRevert(
            abi.encodeWithSelector(
                MarketplaceERC721Escrow_v1_InputContractInvalid.selector
            )
        );
        marketplace.setAllowedContract(DEV_WALLET, true);
    }

    function test_setAllowedContract_shouldSucceed() public {
        marketplace.setAllowedContract(address(clancyERC721), true);
        console.log(
            "marketplace.getAllowedContract(address(clancyERC721))",
            marketplace.getAllowedContract(address(clancyERC721))
        );
    }

    //#endregion

    //#region getAllowedContract
    function test_getAllowedContract() public {
        marketplace.setAllowedContract(address(clancyERC721), true);
        assertEq(marketplace.getAllowedContract(address(clancyERC721)), true);
        console.log(
            "marketplace.getAllowedContract(address(clancyERC721))",
            marketplace.getAllowedContract(address(clancyERC721))
        );
    }

    function test_getAllowedContract_ShouldReturnFalse() public {
        assertEq(marketplace.getAllowedContract(address(clancyERC721)), false);
    }

    //#endregion

    //#region createItem
    function test_createItem_AsNonOwner_ShouldRevert() public {
        marketplaceSetup();

        uint96 tokenId = clancyERC721.mint();
        vm.expectRevert("ERC721: caller is not token owner or approved");
        marketplace.createItem(address(clancyERC721), tokenId);
    }

    function test_createItem_AsUnapproved_ShouldRevert() public {
        marketplaceSetup();

        uint96 tokenId = clancyERC721.mint();
        vm.expectRevert("ERC721: caller is not token owner or approved");
        marketplace.createItem(address(clancyERC721), tokenId);
    }

    function test_createItem_ShouldPass() public returns (uint256) {
        marketplaceSetup();

        uint96 tokenId = clancyERC721.mint();

        assertEq(clancyERC721.balanceOf(address(this)), 1);
        assertEq(clancyERC721.ownerOf(tokenId), address(this));
        assertEq(clancyERC721.balanceOf(address(marketplace)), 0);

        clancyERC721.approve(address(marketplace), tokenId);

        vm.expectEmit(true, true, false, false);
        emit MarketplaceItemCreated(
            address(clancyERC721),
            tokenId,
            block.timestamp,
            address(this),
            marketplace.getItemIdCounter() + 1
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

    function test_createItem_ReentrancyAttack_ShouldRevert() public {
        test_createItem_ShouldPass();
        uint256 tokenId = 1;

        assertEq(clancyERC721.ownerOf(tokenId), address(marketplace));
        assertEq(clancyERC721.balanceOf(address(marketplace)), 1);
        assertEq(clancyERC721.balanceOf(address(this)), 0);

        vm.expectRevert(
            abi.encodeWithSelector(
                MarketplaceERC721Escrow_v1_NotTokenOwner.selector
            )
        );
        marketplace.createItem(address(clancyERC721), tokenId);
    }

    function test_createItem_MaxItems_ShouldPass() public {
        marketplaceSetup();

        for (uint256 i = 0; i < marketplace_max_items; i++) {
            uint96 tokenId = clancyERC721.mint();
            clancyERC721.approve(address(marketplace), tokenId);
            vm.expectEmit(true, true, false, false);
            emit MarketplaceItemCreated(
                address(clancyERC721),
                tokenId,
                block.timestamp,
                address(this),
                marketplace.getItemIdCounter() + 1
            );
            marketplace.createItem(address(clancyERC721), tokenId);
        }

        assertEq(clancyERC721.balanceOf(address(marketplace)), 10);
        assertEq(clancyERC721.balanceOf(address(this)), 0);

        console.log("Created", marketplace.getItemIdCounter(), "items.");
    }

    function test_createItem_MaxItemsPlusOne_ShouldRevert() public {
        marketplaceSetup();

        uint96 tokenId = 0;
        for (uint256 i = 0; i < marketplace_max_items; i++) {
            tokenId = clancyERC721.mint();
            clancyERC721.approve(address(marketplace), tokenId);
            marketplace.createItem(address(clancyERC721), tokenId);
        }

        tokenId = clancyERC721.mint();

        clancyERC721.approve(address(marketplace), tokenId);

        vm.expectRevert(
            abi.encodeWithSelector(
                MarketplaceERC721Escrow_v1_MarketplaceFull.selector
            )
        );
        marketplace.createItem(address(clancyERC721), tokenId);
    }

    //#endregion

    //#region getItem

    function test_getItem_DoesNotExist_ShouldReturnZeroes() public {
        marketplaceSetup();

        MarketplaceEscrowItem memory item = marketplace.getItem(
            address(clancyERC721),
            0
        );

        assertEq(item.listedAt, 0);
        assertEq(item.seller, address(0));
        assertEq(item.buyer, address(0));
        assertEq(item.soldAt, 0);
    }

    function test_getItem_ShouldPass() public {
        marketplaceSetup();

        uint96 tokenId = mintAndApprove();
        marketplace.createItem(address(clancyERC721), tokenId);

        MarketplaceEscrowItem memory item = marketplace.getItem(
            address(clancyERC721),
            tokenId
        );

        assertEq(item.listedAt, block.timestamp);
        assertEq(item.seller, address(this));
        assertEq(item.buyer, address(0));
        assertEq(item.soldAt, 0);
    }

    //#endregion

    //#region cancelItem
    function test_cancelItem_ForNonApprovedContract_ShouldRevert() public {
        marketplaceSetup();

        uint96 tokenId = mintAndApprove();
        vm.expectRevert(
            abi.encodeWithSelector(
                MarketplaceERC721Escrow_v1_InputContractInvalid.selector
            )
        );
        marketplace.cancelItem(address(marketplace), tokenId);
    }

    function test_cancelItem_ForNonListedItem_ShouldRevert() public {
        marketplaceSetup();

        uint96 tokenId = mintAndApprove();
        vm.expectRevert(
            abi.encodeWithSelector(
                MarketplaceERC721Escrow_v1_ItemDoesNotExist.selector
            )
        );
        marketplace.cancelItem(address(clancyERC721), tokenId);
    }

    /* The marketplace is approved to transfer the tokens, but cannot cancel the listing
     * from within this contract. It _can_ still use the ERC721 functions to transfer.
     */
    function test_cancelItem_ByApprovedNonSeller_ShouldRevert() public {
        marketplaceSetup();

        uint96 tokenId = mintAndApprovePrank(DEV_WALLET);

        vm.prank(address(DEV_WALLET));
        marketplace.createItem(address(clancyERC721), tokenId);

        vm.prank(address(marketplace));
        vm.expectRevert(
            abi.encodeWithSelector(
                MarketplaceERC721Escrow_v1_NotTokenSeller.selector
            )
        );
        marketplace.cancelItem(address(clancyERC721), tokenId);
    }

    function test_cancelItem_ByApprovedNonSellerThroughAttackerContract_ShouldRevert()
        public
    {
        marketplaceSetup();

        uint96 tokenId = mintAndApprovePrank(DEV_WALLET);

        vm.prank(address(DEV_WALLET));
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
                uint256(tokenId)
            )
        );
        assertEq(success, false);
    }

    function test_cancelItem_AsOwnerButNotSeller_ShouldRevert() public {
        marketplaceSetup();

        uint96 tokenId = mintAndApprove();
        marketplace.createItem(address(clancyERC721), tokenId);

        vm.prank(address(clancyERC721));
        vm.expectRevert(
            abi.encodeWithSelector(
                MarketplaceERC721Escrow_v1_NotTokenSeller.selector
            )
        );
        marketplace.cancelItem(address(clancyERC721), tokenId);
    }

    function test_cancelItem_WhenItemIsSold_ShouldRevert() public {
        marketplaceSetup();

        uint96 tokenId = mintAndApprove();

        marketplace.createItem(address(clancyERC721), tokenId);
        marketplace.createPurchase(
            address(clancyERC721),
            tokenId,
            address(DEV_WALLET)
        );

        vm.expectRevert(
            abi.encodeWithSelector(
                MarketplaceERC721Escrow_v1_ItemIsSold.selector
            )
        );
        marketplace.cancelItem(address(clancyERC721), tokenId);
    }

    function test_cancelItem_ShouldPass() public {
        marketplaceSetup();

        uint96 tokenId = mintAndApprove();

        uint256 itemId = marketplace.createItem(address(clancyERC721), tokenId);
        console.log("Listed item with ID: %s", itemId);
        MarketplaceEscrowItem memory item = marketplace.getItem(
            address(clancyERC721),
            tokenId
        );
        console.log(
            "itemId: %s, listedAt: %s, seller: %s",
            item.itemId,
            item.listedAt,
            item.seller
        );

        vm.expectEmit(true, true, false, false);
        emit MarketplaceItemCancelled(
            itemId,
            address(clancyERC721),
            tokenId,
            block.timestamp
        );
        marketplace.cancelItem(address(clancyERC721), tokenId);

        assertEq(clancyERC721.ownerOf(tokenId), address(this));
        assertEq(clancyERC721.balanceOf(address(marketplace)), 0);
        assertEq(clancyERC721.balanceOf(address(this)), 1);

        console.log("Cancelled item with ID: %s", itemId);

        // GetItem should return 0
        item = marketplace.getItem(address(clancyERC721), tokenId);
        assertEq(item.itemId, 0);
        assertEq(item.listedAt, 0);
        assertEq(item.seller, address(0));
        assertEq(item.buyer, address(0));
        assertEq(item.soldAt, 0);
    }

    //#endregion

    //#region createPurchase
    function test_createPurchase_ForNonApprovedContract_ShouldRevert() public {
        marketplaceSetup();

        uint96 tokenId = mintAndApprove();

        marketplace.createItem(address(clancyERC721), tokenId);

        vm.expectRevert(
            abi.encodeWithSelector(
                MarketplaceERC721Escrow_v1_InputContractInvalid.selector
            )
        );
        marketplace.createPurchase(
            address(marketplace),
            tokenId,
            address(DEV_WALLET)
        );
    }

    function test_createPurchase_AsNonOwner_ShouldRevert() public {
        marketplaceSetup();

        uint96 tokenId = mintAndApprove();

        marketplace.createItem(address(clancyERC721), tokenId);

        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(address(clancyERC721));
        marketplace.createPurchase(
            address(clancyERC721),
            tokenId,
            address(DEV_WALLET)
        );
    }

    function test_createPurchase_SetBuyerToSeller_ShouldRevert() public {
        marketplaceSetup();

        uint96 tokenId = mintAndApprove();

        marketplace.createItem(address(clancyERC721), tokenId);

        vm.expectRevert(
            abi.encodeWithSelector(
                MarketplaceERC721Escrow_v1_ItemBuyerCannotBeSeller.selector
            )
        );
        marketplace.createPurchase(
            address(clancyERC721),
            tokenId,
            address(this)
        );
    }

    function test_createPurchase_Twice_ShouldRevert() public {
        marketplaceSetup();

        uint96 tokenId = mintAndApprove();

        marketplace.createItem(address(clancyERC721), tokenId);

        marketplace.createPurchase(
            address(clancyERC721),
            tokenId,
            address(DEV_WALLET)
        );

        vm.expectRevert(
            abi.encodeWithSelector(
                MarketplaceERC721Escrow_v1_ItemIsSold.selector
            )
        );
        marketplace.createPurchase(
            address(clancyERC721),
            tokenId,
            address(DEV_WALLET)
        );
    }

    function test_createPurchase_ShouldPass() public {
        marketplaceSetup();

        uint96 tokenId = mintAndApprove();

        uint256 itemId = marketplace.createItem(address(clancyERC721), tokenId);

        vm.expectEmit(true, true, false, false);
        emit MarketplaceItemPurchaseCreated(
            itemId,
            address(clancyERC721),
            tokenId,
            block.timestamp,
            address(this),
            address(DEV_WALLET)
        );
        marketplace.createPurchase(
            address(clancyERC721),
            tokenId,
            address(DEV_WALLET)
        );
    }

    //#endregion

    //#region claimItem
    function test_claimItem_ForInvalidId_ShouldRevert() public {
        marketplaceSetup();

        uint96 tokenId = mintAndApprove();

        marketplace.createItem(address(clancyERC721), tokenId);

        vm.expectRevert(
            abi.encodeWithSelector(
                MarketplaceERC721Escrow_v1_ItemDoesNotExist.selector
            )
        );
        marketplace.claimItem(address(clancyERC721), tokenId + 1);
    }

    function test_claimItem_SenderIsNotBuyer_ShouldRevert() public {
        marketplaceSetup();

        uint96 tokenId = mintAndApprove();

        marketplace.createItem(address(clancyERC721), tokenId);
        marketplace.createPurchase(
            address(clancyERC721),
            tokenId,
            address(DEV_WALLET)
        );

        vm.expectRevert(
            abi.encodeWithSelector(
                MarketplaceERC721Escrow_v1_NotTokenBuyer.selector
            )
        );
        marketplace.claimItem(address(clancyERC721), tokenId);
    }

    function test_claimItem_ItemIsNotSold_ShouldRevert() public {
        marketplaceSetup();

        uint96 tokenId = mintAndApprove();

        marketplace.createItem(address(clancyERC721), tokenId);

        vm.expectRevert(
            abi.encodeWithSelector(
                MarketplaceERC721Escrow_v1_ItemIsNotSold.selector
            )
        );
        marketplace.claimItem(address(clancyERC721), tokenId);
    }

    function test_claimItem_WhenContractIsPaused_ShouldRevert() public {
        marketplaceSetup();

        uint96 tokenId = mintAndApprove();

        marketplace.createItem(address(clancyERC721), tokenId);
        marketplace.createPurchase(
            address(clancyERC721),
            tokenId,
            address(DEV_WALLET)
        );

        marketplace.pause();
        vm.expectRevert("Pausable: paused");
        vm.prank(address(DEV_WALLET));
        marketplace.claimItem(address(clancyERC721), tokenId);
    }

    function test_claimItem_ShouldPass() public {
        marketplaceSetup();

        uint96 tokenId = mintAndApprove();

        uint256 itemId = marketplace.createItem(address(clancyERC721), tokenId);
        marketplace.createPurchase(
            address(clancyERC721),
            tokenId,
            address(DEV_WALLET)
        );

        vm.expectEmit(true, true, false, false);
        emit MarketplaceItemClaimed(
            itemId,
            address(clancyERC721),
            tokenId,
            block.timestamp
        );
        vm.prank(address(DEV_WALLET));
        marketplace.claimItem(address(clancyERC721), tokenId);
        assertEq(clancyERC721.ownerOf(tokenId), address(DEV_WALLET));
    }

    function test_resaleFlow_ShouldPass() public {
        marketplaceSetup();

        uint96 tokenId = mintAndApprove();

        uint256 itemId = marketplace.createItem(address(clancyERC721), tokenId);
        marketplace.createPurchase(
            address(clancyERC721),
            tokenId,
            address(DEV_WALLET)
        );

        vm.prank(address(DEV_WALLET));
        marketplace.claimItem(address(clancyERC721), tokenId);
        assertEq(clancyERC721.ownerOf(tokenId), address(DEV_WALLET));

        vm.prank(address(DEV_WALLET));
        clancyERC721.approve(address(marketplace), tokenId);

        vm.prank(address(DEV_WALLET));
        itemId = marketplace.createItem(address(clancyERC721), tokenId);

        marketplace.createPurchase(
            address(clancyERC721),
            tokenId,
            address(this)
        );

        marketplace.claimItem(address(clancyERC721), tokenId);
        assertEq(clancyERC721.ownerOf(tokenId), address(this));
    }

    function test_BuyAndSellFlowMultipleTimes_UnderMaxLimit_ShouldPass()
        public
    {
        marketplaceSetup();
        marketplace_max_items = marketplace.MAX_ITEMS();

        // Mint marketplace_max_items tokens
        uint96[] memory tokenIds = new uint96[](marketplace_max_items);
        for (uint256 i = 0; i < marketplace_max_items; i++) {
            tokenIds[i] = mintAndApprove();
        }

        // Create marketplace_max_items items
        uint256[] memory itemIds = new uint256[](marketplace_max_items);
        for (uint256 i = 0; i < marketplace_max_items; i++) {
            itemIds[i] = marketplace.createItem(
                address(clancyERC721),
                tokenIds[i]
            );
        }

        // Create marketplace_max_items purchases
        for (uint256 i = 0; i < marketplace_max_items; i++) {
            marketplace.createPurchase(
                address(clancyERC721),
                tokenIds[i],
                address(DEV_WALLET)
            );
        }

        // Claim marketplace_max_items items
        for (uint256 i = 0; i < marketplace_max_items; i++) {
            vm.prank(address(DEV_WALLET));
            marketplace.claimItem(address(clancyERC721), tokenIds[i]);
        }

        // List the same marketplace_max_items items again
        for (uint256 i = 0; i < marketplace_max_items; i++) {
            vm.prank(address(DEV_WALLET));
            clancyERC721.approve(address(marketplace), tokenIds[i]);
            vm.prank(address(DEV_WALLET));
            itemIds[i] = marketplace.createItem(
                address(clancyERC721),
                tokenIds[i]
            );
        }

        // Create marketplace_max_items purchases
        for (uint256 i = 0; i < marketplace_max_items; i++) {
            marketplace.createPurchase(
                address(clancyERC721),
                tokenIds[i],
                address(this)
            );
        }

        // Claim marketplace_max_items items
        for (uint256 i = 0; i < marketplace_max_items; i++) {
            vm.prank(address(this));
            marketplace.claimItem(address(clancyERC721), tokenIds[i]);
        }
    }

    //#endregion
    //#region Helpers
    function marketplaceSetup() internal {
        clancyERC721 = new ClancyERC721(NAME, SYMBOL, MAX_SUPPLY, BASE_URI);
        clancyERC721.setPublicMintStatus(true);

        marketplace = new MarketplaceERC721Escrow_v1();
        marketplace.setAllowedContract(address(clancyERC721), true);
    }

    function mintAndApprove() internal returns (uint96) {
        uint96 tokenId = clancyERC721.mint();
        clancyERC721.approve(address(marketplace), tokenId);
        return tokenId;
    }

    function mintAndApprovePrank(address pranker) internal returns (uint96) {
        vm.prank(pranker);
        uint96 tokenId = clancyERC721.mint();
        vm.prank(pranker);
        clancyERC721.approve(address(marketplace), tokenId);
        return tokenId;
    }
    //#endregion
}
