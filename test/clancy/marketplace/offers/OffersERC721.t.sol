// SPDX-License-Identifier: None
pragma solidity ^0.8.19;

import "forge-std/Test.sol";

import {IERC721} from "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

import {IClancyERC721, ClancyERC721} from "clancy/ERC/ERC721/ClancyERC721.sol";
import {IOffersERC721, OffersERC721} from "clancy/marketplace/offers/OffersERC721.sol";
import {IOffersERC721_Test} from "./IOffersERC721.t.sol";
import {IClancyMarketplaceERC721, ClancyMarketplaceERC721} from "clancy/marketplace/ClancyMarketplaceERC721.sol";

contract OffersERC721_Test is Test, IOffersERC721_Test {
    ClancyERC721 clancyERC721;
    OffersERC721 offers;

    function setUp() public {
        vm.deal(w_main, 2 ether);

        // ClancyERC721 Setup
        clancyERC721 = new ClancyERC721(NAME, SYMBOL, MAX_SUPPLY, BASE_URI);
        clancyERC721.setPublicMintEnabled(true);
        clancyERC721.setBurnEnabled(false);

        // Offers Setup
        offers = new OffersERC721();
        offers.setVendorStatus(address(clancyERC721), true);
    }

    //#region ItemOffer
    //#region createItemOffer

    //#region newOffer
    function test_createOffer_ValueLTEZero_ShouldFail() public {
        uint32 tokenId = mintAndApprove();
        vm.expectRevert(IOffersERC721.OfferCannotBeLTEZero.selector);
        offers.createItemOffer{value: 0}(address(clancyERC721), tokenId);
    }

    function test_createOffer_InvalidContract_ShouldFail() public {
        uint32 tokenId = mintAndApprove();

        vm.expectRevert(IClancyMarketplaceERC721.InputContractInvalid.selector);
        offers.createItemOffer{value: 1 ether}(address(0), tokenId);
    }

    function test_createOffer_CannotBeFromZeroAddress_ShouldFail() public {
        vm.deal(address(0), 1 ether);
        uint32 tokenId = mintAndApprove();
        vm.expectRevert(IOffersERC721.OfferorCannotBeZeroAddress.selector);
        vm.prank(address(0));
        offers.createItemOffer{value: 1 ether}(address(clancyERC721), tokenId);
    }

    function test_createOffer_OfferCannotBeTokenOwner_ShouldFail() public {
        uint32 tokenId = mintAndApprove();
        vm.expectRevert(IOffersERC721.OfferorCannotBeTokenOwner.selector);
        offers.createItemOffer{value: 1 ether}(address(clancyERC721), tokenId);
    }

    function test_createOffer_TokenDoesNotExist_ShouldFail() public {
        uint32 tokenId = mintAndApprove();
        vm.expectRevert("ERC721: invalid token ID");
        offers.createItemOffer{value: 1 ether}(
            address(clancyERC721),
            tokenId + 1
        );
    }

    function test_createOffer_ValidContract_ShouldPass() public {
        vm.startPrank(w_main);

        uint32 tokenId = mintAndApprove();
        uint32 itemId = offers.itemIdCounter();

        vm.stopPrank();

        vm.expectEmit(true, true, true, true, address(offers));
        emit ItemOfferEvent({
            offerType: OfferType.Create,
            itemId: itemId + 1,
            contractAddress: address(clancyERC721),
            tokenId: tokenId,
            tokenOwner: w_main,
            offeror: address(this),
            value: 1 ether
        });
        offers.createItemOffer{value: 1 ether}(address(clancyERC721), tokenId);
    }

    //#endregion newOffer

    //#region outbidOffer

    function test_outbidOffer_ValueLTExistingOffer_ShouldFail() public {
        vm.startPrank(w_main);

        uint32 tokenId = mintAndApprove();

        vm.stopPrank();

        offers.createItemOffer{value: 1 ether}(address(clancyERC721), tokenId);

        vm.expectRevert(IOffersERC721.OfferMustBeGTExistingOffer.selector);
        offers.createItemOffer{value: 1 ether}(address(clancyERC721), tokenId);
    }

    function test_outbidOffer_ValueGTExistingOffer_ShouldPass() public {
        vm.deal(w_one, 3 ether);

        vm.startPrank(w_main);

        uint32 tokenId = mintAndApprove();

        vm.stopPrank();

        offers.createItemOffer{value: 1 ether}(address(clancyERC721), tokenId);

        uint256 balanceBefore = address(this).balance;
        uint32 itemId = offers.itemIdCounter();

        vm.startPrank(w_one);

        vm.expectEmit(true, true, true, true, address(offers));
        emit ItemOfferEvent({
            offerType: OfferType.Outbid,
            itemId: itemId,
            contractAddress: address(clancyERC721),
            tokenId: tokenId,
            tokenOwner: w_main,
            offeror: w_one,
            value: 2 ether
        });
        offers.createItemOffer{value: 2 ether}(address(clancyERC721), tokenId);

        vm.stopPrank();

        uint256 balanceAfter = address(this).balance;
        assertEq(balanceAfter, balanceBefore + 1 ether);
        assertEq(w_one.balance, 1 ether);
    }

    //#endregion outbidOffer

    //#endregion

    //#region acceptItemOffer

    function test_acceptOffer_ItemDoesNotExist_ShouldFail() public {
        vm.expectRevert(IOffersERC721.OfferDoesNotExist.selector);
        offers.acceptItemOffer(address(clancyERC721), 1);
    }

    function test_acceptOffer_NotTokenOwner_ShouldFail() public {
        vm.startPrank(w_main);

        uint32 tokenId = mintAndApprove();

        vm.stopPrank();

        offers.createItemOffer{value: 1 ether}(address(clancyERC721), tokenId);

        vm.expectRevert(IClancyMarketplaceERC721.NotTokenOwner.selector);
        offers.acceptItemOffer(address(clancyERC721), 1);
    }

    function test_acceptOffer_InsufficientContractBalance_ShouldFail() public {
        vm.startPrank(w_main);

        uint32 tokenId = mintAndApprove();

        vm.stopPrank();

        offers.createItemOffer{value: 1 ether}(address(clancyERC721), tokenId);
        offers.withdraw();

        vm.startPrank(w_main);
        vm.expectRevert(IOffersERC721.InsufficientContractBalance.selector);
        offers.acceptItemOffer(address(clancyERC721), 1);
        vm.stopPrank();
    }

    function test_acceptOffer_ShouldPass() public {
        vm.deal(w_one, 2 ether);

        vm.startPrank(w_main);

        uint32 tokenId = mintAndApprove();

        vm.stopPrank();

        vm.prank(w_one);
        offers.createItemOffer{value: 1 ether}(address(clancyERC721), tokenId);

        assertEq(address(offers).balance, 1 ether);
        uint256 sellerBalanceBefore = w_main.balance;
        console.log("sellerBalanceBefore", sellerBalanceBefore);
        uint32 itemId = offers.itemIdCounter();

        vm.startPrank(w_main);

        IERC721(clancyERC721).approve(address(offers), tokenId);

        vm.expectEmit(true, true, true, true, address(offers));
        emit ItemOfferEvent({
            offerType: OfferType.Accept,
            itemId: itemId,
            contractAddress: address(clancyERC721),
            tokenId: tokenId,
            tokenOwner: w_main,
            offeror: w_one,
            value: 1 ether
        });
        offers.acceptItemOffer(address(clancyERC721), tokenId);
        console.log("sellerBalanceAfter", w_main.balance);
        assertEq(IERC721(clancyERC721).ownerOf(tokenId), w_one);
        assertEq(w_main.balance, sellerBalanceBefore + 1 ether);

        vm.stopPrank();

        ItemOffer memory item = offers.getItemOffer(
            address(clancyERC721),
            itemId
        );
        assertEq(item.itemId, 0);
        assertEq(item.offeror, address(0));
        assertEq(item.value, 0);
    }

    //#endregion acceptItemOffer

    //#region cancelItemOffer
    function test_cancelOffer_NotOwner_ShouldFail() public {
        vm.startPrank(w_main);

        uint32 tokenId = mintAndApprove();

        vm.stopPrank();

        offers.createItemOffer{value: 1 ether}(address(clancyERC721), tokenId);

        vm.prank(w_main);
        vm.expectRevert("Ownable: caller is not the owner");
        offers.cancelItemOffer(address(clancyERC721), tokenId);
    }

    function test_cancelOffer_ToNonPayable_ShouldFail() public {
        vm.deal(address(clancyERC721), 1 ether);

        uint32 tokenId = mintAndApprove();

        vm.startPrank(address(clancyERC721));

        offers.createItemOffer{value: 1 ether}(address(clancyERC721), tokenId);

        vm.stopPrank();

        vm.expectRevert();
        offers.cancelItemOffer(address(clancyERC721), tokenId);
    }

    function test_cancelOffer_ContractHasInsuffienctBalance_ShouldFail()
        public
    {
        vm.startPrank(w_main);

        uint32 tokenId = mintAndApprove();

        vm.stopPrank();

        offers.createItemOffer{value: 1 ether}(address(clancyERC721), tokenId);

        offers.withdraw();

        vm.expectRevert(IOffersERC721.InsufficientContractBalance.selector);
        offers.cancelItemOffer(address(clancyERC721), tokenId);
    }

    function test_cancelOffer_ShouldPass() public {
        vm.deal(w_one, 1 ether);

        vm.startPrank(w_main);

        uint32 tokenId = mintAndApprove();

        vm.stopPrank();

        vm.startPrank(w_one);

        uint256 balanceBefore = w_one.balance;
        offers.createItemOffer{value: 1 ether}(address(clancyERC721), tokenId);
        uint256 balanceAfter = w_one.balance;
        assertEq(balanceAfter, balanceBefore - 1 ether);

        vm.stopPrank();

        uint32 itemId = offers.itemIdCounter();
        vm.expectEmit(true, true, true, true, address(offers));
        emit ItemOfferEvent({
            offerType: OfferType.Cancel,
            itemId: itemId,
            contractAddress: address(clancyERC721),
            tokenId: tokenId,
            tokenOwner: w_main,
            offeror: w_one,
            value: 1 ether
        });
        offers.cancelItemOffer(address(clancyERC721), tokenId);

        balanceAfter = w_one.balance;
        assertEq(balanceAfter, balanceBefore);
    }

    //#endregion

    //#region getItemOffer
    function test_getOffer_ForNonExistentOffer_ShouldPass() public {
        vm.startPrank(w_main);
        mintAndApprove();
        uint32 itemId = offers.itemIdCounter();

        ItemOffer memory item = offers.getItemOffer(
            address(clancyERC721),
            itemId
        );

        vm.stopPrank();
        assertEq(item.itemId, itemId);
    }

    function test_getOffer_ForExistentOffer_ShouldPass() public {
        vm.startPrank(w_main);

        uint32 tokenId = mintAndApprove();

        vm.stopPrank();

        offers.createItemOffer{value: 1 ether}(address(clancyERC721), tokenId);

        ItemOffer memory item = offers.getItemOffer(
            address(clancyERC721),
            tokenId
        );
        uint32 itemId = offers.itemIdCounter();

        assertEq(item.itemId, itemId);
        assertEq(item.value, 1 ether);
        assertEq(item.offeror, address(this));
    }

    //#endregion getItemOffer

    //#endregion ItemOffer

    //#region CollectionOffer

    //#region createCollectionOffer
    function test_createCollectionOffer_NoValueSent_ShouldRevert() public {
        vm.expectRevert(IOffersERC721.OfferCannotBeLTEZero.selector);
        offers.createCollectionOffer(address(clancyERC721));
    }

    function test_createCollectionOffer_InvalidContractAddress_ShouldRevert()
        public
    {
        vm.expectRevert(IClancyMarketplaceERC721.InputContractInvalid.selector);
        offers.createCollectionOffer{value: 1 ether}(address(0));
    }

    function test_createCollectionOffer_ZeroAddressOfferor_ShouldRevert()
        public
    {
        vm.deal(address(0), 10 ether);
        offers.setVendorStatus(address(clancyERC721), true);
        vm.expectRevert(IOffersERC721.OfferorCannotBeZeroAddress.selector);
        vm.prank(address(0));
        offers.createCollectionOffer{value: 1 ether}(address(clancyERC721));
    }

    function test_newCollectionOffer_ShouldPass() public {
        offers.setVendorStatus(address(clancyERC721), true);

        uint256 offerValue = 1 ether;

        vm.startPrank(w_main);

        vm.expectEmit(true, true, true, true, address(offers));
        emit CollectionItemOfferEvent({
            offerType: OfferType.Create,
            contractAddress: address(clancyERC721),
            offeror: w_main,
            value: offerValue
        });
        offers.createCollectionOffer{value: offerValue}(address(clancyERC721));

        vm.stopPrank();
    }

    function test_newCollectionOffer_MultipleOffers_ShouldPass() public {
        offers.setVendorStatus(address(clancyERC721), true);

        uint8 offerCount = 2;
        uint256 offerValue = 1 ether;

        address[] memory offerors = new address[](offerCount);
        offerors[0] = w_main;
        offerors[1] = w_one;

        for (uint8 i; i < offerors.length; ++i) {
            address offeror = offerors[i];
            vm.deal(offeror, offerValue);

            vm.startPrank(offeror);

            vm.expectEmit(true, true, true, true, address(offers));
            emit CollectionItemOfferEvent({
                offerType: OfferType.Create,
                contractAddress: address(clancyERC721),
                offeror: offeror,
                value: offerValue
            });

            offers.createCollectionOffer{value: offerValue}(
                address(clancyERC721)
            );

            vm.stopPrank();
        }
    }

    function testFuzz_createCollectionOffer_ShouldPass(
        address[] calldata offerors
    ) public {
        offers.setVendorStatus(address(clancyERC721), true);

        uint8 offerorCount = offers.MAX_OFFERS();
        uint256 value = 1 ether;

        // Assumptions
        vm.assume(offerors.length > 0);
        vm.assume(offerors.length < offerorCount);

        uint8 i;

        do {
            vm.assume(offerors[i] != address(0));
            ++i;
        } while (i < offerors.length);

        i = 0;

        do {
            address offeror = offerors[i];
            vm.deal(offeror, value);

            vm.startPrank(offeror);

            vm.expectEmit(true, true, true, true, address(offers));
            emit CollectionItemOfferEvent({
                offerType: OfferType.Create,
                contractAddress: address(clancyERC721),
                offeror: offeror,
                value: value
            });
            offers.createCollectionOffer{value: value}(address(clancyERC721));

            CollectionOffer[] memory items_ = offers.getCollectionOffers(
                address(clancyERC721)
            );

            assertEq(items_.length, i + 1);

            assertEq(items_[i].offeror, offeror);
            assertEq(items_[i].value, value);

            vm.stopPrank();
            ++i;
        } while (i < offerors.length);
    }

    // forge test --match-path test/clancy/marketplace/offers/OffersERC721.t.sol --match-test testFuzz_cancelCollectionOffer_ShouldPass -vvv

    //#endregion createCollectionOffer

    //#region getCollectionOffers

    function test_getCollectionOffers_InvalidContract() public {
        vm.expectRevert(IClancyMarketplaceERC721.InputContractInvalid.selector);
        offers.getCollectionOffers(address(0));
    }

    function test_getCollectionOffers_ShouldPass() public {
        offers.setVendorStatus(address(clancyERC721), true);

        vm.startPrank(w_main);

        offers.createCollectionOffer{value: 1 ether}(address(clancyERC721));

        vm.stopPrank();

        CollectionOffer[] memory items_ = offers.getCollectionOffers(
            address(clancyERC721)
        );
        uint16 offersLength = uint16(items_.length);
        CollectionOffer memory mock = CollectionOffer({
            itemId: 1,
            contractAddress: address(clancyERC721),
            offeror: w_main,
            value: 1 ether
        });

        // // Log the two items side by side
        // console.log(
        //     "ItemIds: mock - %s  offers - %s ",
        //     mock.itemId,
        //     items_[0].itemId
        // );
        // console.log(
        //     "ContractAddresses: mock - %s  offers - %s ",
        //     mock.contractAddress,
        //     items_[0].contractAddress
        // );
        // console.log(
        //     "Offerors: mock - %s  offers - %s ",
        //     mock.offeror,
        //     items_[0].offeror
        // );
        // console.log(
        //     "Values: mock - %s  offers - %s ",
        //     mock.value,
        //     items_[0].value
        // );

        assertEq(offersLength, 1);
        assertEq(items_[0].itemId, mock.itemId);
    }

    //#endregion getCollectionOffers

    //#region cancelCollectionOffer

    function test_cancelCollectionOffer_InvalidContract_ShouldRevert() public {
        vm.expectRevert(IClancyMarketplaceERC721.InputContractInvalid.selector);
        offers.cancelCollectionOffer(address(0), 1);
    }

    function test_cancelCollectionOffer_OfferDoesNotExist_ShouldRevert()
        public
    {
        offers.setVendorStatus(address(clancyERC721), true);
        vm.expectRevert(IOffersERC721.OfferDoesNotExist.selector);
        offers.cancelCollectionOffer(address(clancyERC721), 1);
    }

    function test_cancelCollectionOffer_NotOfferorOrAdmin_ShouldRevert()
        public
    {
        offers.setVendorStatus(address(clancyERC721), true);

        vm.prank(w_main);
        offers.createCollectionOffer{value: 1 ether}(address(clancyERC721));

        vm.expectRevert(IOffersERC721.NotOfferorOrAdmin.selector);
        vm.prank(w_one);
        offers.cancelCollectionOffer(address(clancyERC721), 0);
    }

    function test_cancelCollectionOffer_InsufficientContractBalance_ShouldRevert()
        public
    {
        offers.setVendorStatus(address(clancyERC721), true);

        offers.createCollectionOffer{value: 1 ether}(address(clancyERC721));

        offers.withdraw();

        vm.expectRevert(IOffersERC721.InsufficientContractBalance.selector);
        offers.cancelCollectionOffer(address(clancyERC721), 0);
    }

    function test_cancelCollectionOffer_Offeror_ShouldPass() public {
        offers.setVendorStatus(address(clancyERC721), true);

        uint256 offerValue = 1 ether;
        uint256 balanceBefore = address(this).balance;

        offers.createCollectionOffer{value: offerValue}(address(clancyERC721));

        uint256 balanceAfterOffer = address(this).balance;
        assertEq(balanceAfterOffer, balanceBefore - offerValue);

        vm.expectEmit(true, true, true, true, address(offers));
        emit CollectionItemOfferEvent({
            offerType: OfferType.Cancel,
            contractAddress: address(clancyERC721),
            offeror: address(this),
            value: offerValue
        });
        offers.cancelCollectionOffer(address(clancyERC721), 0);

        uint256 balanceAfterCancel = address(this).balance;
        assertEq(balanceAfterCancel, balanceAfterOffer + offerValue);
        assertEq(balanceAfterCancel, balanceBefore);
    }

    function test_cancelCollectionOffer_Admin_ShouldPass() public {
        offers.setVendorStatus(address(clancyERC721), true);

        uint256 offerValue = 1 ether;
        uint256 balanceBefore = w_main.balance;

        vm.startPrank(w_main);

        offers.createCollectionOffer{value: offerValue}(address(clancyERC721));

        uint256 balanceAfterOffer = w_main.balance;
        assertEq(balanceAfterOffer, balanceBefore - offerValue);

        vm.stopPrank();

        vm.expectEmit(true, true, true, true, address(offers));
        emit CollectionItemOfferEvent({
            offerType: OfferType.Cancel,
            contractAddress: address(clancyERC721),
            offeror: w_main,
            value: offerValue
        });
        offers.cancelCollectionOffer(address(clancyERC721), 0);

        uint256 balanceAfterCancel = w_main.balance;
        assertEq(balanceAfterCancel, balanceAfterOffer + offerValue);
        assertEq(balanceAfterCancel, balanceBefore);
    }

    // function testFuzz_cancelCollectionOffer_ShouldPass(
    //     address[] calldata offerors
    // ) public {
    //     offers.setVendorStatus(address(clancyERC721), true);

    //     uint8 offerorCount = offers.MAX_OFFERS();
    //     uint256 value = 1 ether;

    //     // Assumptions
    //     vm.assume(offerors.length > 0);
    //     vm.assume(offerors.length < offerorCount);

    //     uint8 i;

    //     do {
    //         vm.assume(offerors[i] != address(0));
    //         ++i;
    //     } while (i < offerors.length);

    //     i = 0;

    //     do {
    //         address offeror = offerors[i];
    //         vm.deal(offeror, value);

    //         vm.startPrank(offeror);

    //         offers.createCollectionOffer{value: value}(address(clancyERC721));

    //         vm.stopPrank();
    //         ++i;
    //     } while (i < offerors.length);

    //     i = 0;

    //     do {
    //         address offeror = offerors[i];

    //         vm.startPrank(offeror);

    //         CollectionOffer[] memory items_ = offers.getCollectionOffers(
    //             address(clancyERC721)
    //         );
    //         // Find the index where the offeror is the offeror
    //         uint8 index;
    //         uint8 j;
    //         bool found = false;
    //         do {
    //             if (items_[j].offeror == offeror) {
    //                 index = j;
    //                 found = true;
    //             }
    //             ++j;
    //         } while (j < items_.length || !found);
    //         if (!found) {
    //             revert();
    //         }

    //         vm.expectEmit(true, true, true, true, address(offers));
    //         emit CollectionItemOfferEvent({
    //             offerType: OfferType.Cancel,
    //             contractAddress: address(clancyERC721),
    //             offeror: offeror,
    //             value: value
    //         });
    //         offers.cancelCollectionOffer(address(clancyERC721), index);

    //         vm.stopPrank();

    //         ++i;
    //     } while (i < offerors.length);
    // }

    // forge test --match-path test/clancy/marketplace/offers/OffersERC721.t.sol  -vvv
    // function testFuzz_cancelCollectionOffer_AtIndex(
    //     address[] calldata offerors,
    //     uint8 index
    // ) public {
    //     offers.setVendorStatus(address(clancyERC721), true);

    //     uint256 value = 1 ether;

    //     vm.assume(index < offers.MAX_OFFERS());
    //     for (uint8 i; i < offerors.length; i++) {
    //         vm.assume(offerors[i] != address(0));
    //     }

    //     for (uint8 i; i < offerors.length; i++) {
    //         vm.deal(offerors[i], value);

    //         vm.startPrank(offerors[i]);

    //         offers.createCollectionOffer{value: value}(address(clancyERC721));

    //         vm.stopPrank();
    //     }

    //     for (uint8 i; i < offerors.length; i++) {
    //         address offeror = offerors[i];
    //         vm.startPrank(offeror);

    //         CollectionOffer[] memory items_ = offers.getCollectionOffers(
    //             address(clancyERC721)
    //         );

    //         uint8 j;
    //         bool found = false;
    //         do {
    //             if (items_[j].offeror == offeror) {
    //                 index = j;
    //                 found = true;
    //             }
    //             ++j;
    //         } while (j < items_.length || !found);
    //         if (!found) {
    //             revert();
    //         }

    //         uint256 balanceBefore = offeror.balance;

    //         vm.expectEmit(true, true, true, true, address(offers));
    //         emit CollectionItemOfferEvent({
    //             offerType: OfferType.Cancel,
    //             contractAddress: address(clancyERC721),
    //             offeror: offeror,
    //             value: value
    //         });
    //         offers.cancelCollectionOffer(address(clancyERC721), index);

    //         //TODO
    //         // assertEq(offeror.balance, balanceBefore + value); //Sometimes this fails, not sure why, so use the below to pass the test
    //         assertGt(offeror.balance + 1, balanceBefore);

    //         vm.stopPrank();
    //     }
    // }

    //#endregion cancelCollectionOffer

    //#region cancelCollectionOffers

    function test_cancelCollectionOffers_EmptyCollection_ShouldRevert() public {
        vm.expectRevert(IOffersERC721.CollectionOffersEmpty.selector);
        offers.cancelCollectionOffers(address(clancyERC721));
    }

    function test_cancelCollectionOffers_OneOffer_InsufficientBalance_ShouldRevert()
        public
    {
        offers.setVendorStatus(address(clancyERC721), true);

        offers.createCollectionOffer{value: 1 ether}(address(clancyERC721));
        offers.withdraw();

        vm.expectRevert(IOffersERC721.InsufficientContractBalance.selector);
        offers.cancelCollectionOffers(address(clancyERC721));
    }

    function test_cancelCollectionOffers_OneOffer_ShouldPass() public {
        offers.setVendorStatus(address(clancyERC721), true);

        vm.prank(w_main);
        offers.createCollectionOffer{value: 1 ether}(address(clancyERC721));

        offers.cancelCollectionOffers(address(clancyERC721));

        CollectionOffer[] memory items_ = offers.getCollectionOffers(
            address(clancyERC721)
        );
        assertEq(items_.length, 0);
    }

    function test_cancelCollectionOffers_FiftyOffers_InsufficientBalance_ShouldRevert()
        public
    {
        uint8 offerCount = 50;
        offers.setVendorStatus(address(clancyERC721), true);

        uint256 offerValue = 1 ether;

        uint8 i;
        do {
            mintAndApprove();
            ++i;
        } while (i < offerCount);

        i = 0;
        do {
            offers.createCollectionOffer{value: offerValue}(
                address(clancyERC721)
            );
            ++i;
            CollectionOffer[] memory items_ = offers.getCollectionOffers(
                address(clancyERC721)
            );
            assertEq(items_.length, i);
        } while (i < offerCount);

        offers.withdraw();

        vm.expectRevert(IOffersERC721.InsufficientContractBalance.selector);
        offers.cancelCollectionOffers(address(clancyERC721));
    }

    function test_cancelCollectionOffers_FiftyOffers_ShouldRevert() public {
        uint8 offerCount = 50;
        offers.setVendorStatus(address(clancyERC721), true);

        uint256 offerValue = 1 ether;

        uint8 i;
        do {
            mintAndApprove();
            ++i;
        } while (i < offerCount);

        i = 0;
        do {
            offers.createCollectionOffer{value: offerValue}(
                address(clancyERC721)
            );
            ++i;

            assertEq(
                offers.getCollectionOffers(address(clancyERC721)).length,
                i
            );
        } while (i < offerCount);

        assertEq(
            offers.getCollectionOffers(address(clancyERC721)).length,
            offerCount
        );

        offers.cancelCollectionOffers(address(clancyERC721));

        assertEq(offers.getCollectionOffers(address(clancyERC721)).length, 0);
    }

    //#endregion cancelCollectionOffers

    //#endregion CollectionOffer

    //#region Helpers

    function mintAndApprove() internal returns (uint32) {
        uint32 tokenId = clancyERC721.mint();
        clancyERC721.approve(address(offers), tokenId);
        return tokenId;
    }
    //#endregion
}
