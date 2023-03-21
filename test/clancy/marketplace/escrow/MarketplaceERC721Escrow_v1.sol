// SPDX-License-Identifier: None
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "clancy-test/helpers/ClancyERC721TestHelpers.sol";
import "clancy/marketplace/escrow/MarketplaceERC721Escrow_v1.sol";

contract MarketplaceERC721Escrow_v1_Test is Test, ClancyERC721TestHelpers {
    ClancyERC721 clancyERC721;
    MarketplaceERC721Escrow_v1 marketplace;

    function setUp() public {
        clancyERC721 = new ClancyERC721(NAME, SYMBOL, MAX_SUPPLY, BASE_URI);
        clancyERC721.setPublicMintStatus(true);
        marketplace = new MarketplaceERC721Escrow_v1();
    }

    //#region setAllowedContract
    function test_setAllowedContract_shouldFailWhenNotOwner() public {
        vm.prank(DEV_WALLET);
        vm.expectRevert("Ownable: caller is not the owner");
        marketplace.setAllowedContract(address(clancyERC721), true);
    }

    function test_setAllowedContract_shouldFailWhenZeroAddress() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                InputContractInvalid.selector,
                "MarketplaceERC721Escrow_v1: Address is not an ERC721 contract."
            )
        );
        marketplace.setAllowedContract(address(0), true);
    }

    function test_setAllowedContract_shouldFailWhenNotContract() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                InputContractInvalid.selector,
                "MarketplaceERC721Escrow_v1: Address is not an ERC721 contract."
            )
        );
        marketplace.setAllowedContract(DEV_WALLET, true);
    }

    function test_setAllowedContract_NonERC721Contract_ShouldFail() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                InputContractInvalid.selector,
                "MarketplaceERC721Escrow_v1: Address is not an ERC721 contract."
            )
        );
        marketplace.setAllowedContract(address(marketplace), true);
    }

    function test_setAllowedContract_shouldSucceed() public {
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

    function marketplaceSetup() internal {
        clancyERC721 = new ClancyERC721(NAME, SYMBOL, MAX_SUPPLY, BASE_URI);
        clancyERC721.setPublicMintStatus(true);

        marketplace = new MarketplaceERC721Escrow_v1();
        marketplace.setAllowedContract(address(clancyERC721), true);
    }

    //#region createItem
    function test_createItem_shouldFailWhenNotApproved() public {
        marketplaceSetup();

        uint96 tokenId = clancyERC721.mint();
        vm.expectRevert("ERC721: caller is not token owner or approved");
        marketplace.createItem(address(clancyERC721), tokenId, 1 ether);
    }

    function test_createItem_PriceTooHigh_ShouldFail() public {
        marketplaceSetup();

        uint96 tokenId = clancyERC721.mint();
        clancyERC721.approve(address(marketplace), tokenId);
        uint96 totalPrice = marketplace.MAX_PRICE() + uint96(1);
        vm.expectRevert(
            abi.encodeWithSelector(
                PriceTooHigh.selector,
                "MarketplaceERC721Escrow_v1: Price too high."
            )
        );
        marketplace.createItem(address(clancyERC721), tokenId, totalPrice);
    }

    function test_createItem_shouldPass() public {
        marketplaceSetup();

        uint96 tokenId = clancyERC721.mint();

        assertEq(clancyERC721.balanceOf(address(this)), 1);
        assertEq(clancyERC721.ownerOf(tokenId), address(this));
        assertEq(clancyERC721.balanceOf(address(marketplace)), 0);

        clancyERC721.approve(address(marketplace), tokenId);

        marketplace.createItem(address(clancyERC721), tokenId, 1 ether);

        assertEq(clancyERC721.ownerOf(tokenId), address(marketplace));
        assertEq(clancyERC721.balanceOf(address(marketplace)), 1);
        assertEq(clancyERC721.balanceOf(address(this)), 0);
    }

    function test_createItem_ReentrancyAttack_ShouldFail() public {
        marketplaceSetup();

        uint96 tokenId = clancyERC721.mint();

        assertEq(clancyERC721.balanceOf(address(this)), 1);
        assertEq(clancyERC721.ownerOf(tokenId), address(this));
        assertEq(clancyERC721.balanceOf(address(marketplace)), 0);

        clancyERC721.approve(address(marketplace), tokenId);

        marketplace.createItem(address(clancyERC721), tokenId, 1 ether);

        assertEq(clancyERC721.ownerOf(tokenId), address(marketplace));
        assertEq(clancyERC721.balanceOf(address(marketplace)), 1);
        assertEq(clancyERC721.balanceOf(address(this)), 0);
        vm.expectRevert(
            abi.encodeWithSelector(
                NotTokenOwnerOrApproved.selector,
                "MarketplaceERC721Escrow_v1: Not token owner or approved."
            )
        );
        // vm.expectRevert("ERC721: caller is not token owner or approved");
        marketplace.createItem(address(clancyERC721), tokenId, 1 ether);
    }
}
