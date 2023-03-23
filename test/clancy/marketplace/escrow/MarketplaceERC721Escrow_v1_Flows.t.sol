// SPDX-License-Identifier: None
pragma solidity ^0.8.17;

import "./IMarketplaceERC721Escrow_v1.t.sol";

contract MarketplaceERC721Escrow_v1_Test is IMarketplaceERC721Escrow_v1_Test {
    ClancyERC721 clancyERC721;
    MarketplaceERC721Escrow_v1 marketplace;

    uint256 public marketplace_max_items;

    function setUp() public {
        clancyERC721 = new ClancyERC721(NAME, SYMBOL, MAX_SUPPLY, BASE_URI);
        clancyERC721.setPublicMintStatus(true);

        marketplace.setAllowedContract(address(clancyERC721), true);
        marketplace = new MarketplaceERC721Escrow_v1();
        marketplace_max_items = marketplace.MAX_ITEMS();
    }

    function test_resaleFlow_ShouldPass() public {
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
