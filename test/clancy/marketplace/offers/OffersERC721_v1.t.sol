// SPDX-License-Identifier: None
pragma solidity ^0.8.19;

import "forge-std/Test.sol";

import {IERC721} from "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

import {IClancyERC721, ClancyERC721} from "clancy/ERC/ERC721/ClancyERC721.sol";
import {IOffersERC721_v1, OffersERC721_v1} from "clancy/marketplace/offers/OffersERC721_v1.sol";
import {IOffersERC721_v1_Test} from "./IOffersERC721_v1.t.sol";
import {IClancyMarketplaceERC721_v1, ClancyMarketplaceERC721_v1} from "clancy/marketplace/ClancyMarketplaceERC721_v1.sol";

contract OffersERC721_Test is Test, IOffersERC721_v1_Test {
    ClancyERC721 clancyERC721;
    OffersERC721_v1 offers;

    function setUp() public {
        vm.deal(w_main, 2 ether);

        // ClancyERC721 Setup
        clancyERC721 = new ClancyERC721(NAME, SYMBOL, MAX_SUPPLY, BASE_URI);
        clancyERC721.setPublicMintStatus(true);
        clancyERC721.setBurnStatus(false);

        // Offers Setup
        offers = new OffersERC721_v1();
        offers.setAllowedContract(address(clancyERC721), true);
    }

    //#region createOffer

    //#region newOffer
    function test_createOffer_ValueLTEZero_ShouldFail() public {
        uint32 tokenId = mintAndApprove();
        vm.expectRevert(IOffersERC721_v1.OfferCannotBeLTEZero.selector);
        offers.createOffer{value: 0}(address(clancyERC721), tokenId);
    }

    function test_createOffer_InvalidContract_ShouldFail() public {
        uint32 tokenId = mintAndApprove();

        vm.expectRevert(
            IClancyMarketplaceERC721_v1.InputContractInvalid.selector
        );
        offers.createOffer{value: 1 ether}(address(0), tokenId);
    }

    function test_createOffer_CannotBeFromZeroAddress_ShouldFail() public {
        vm.deal(address(0), 1 ether);
        uint32 tokenId = mintAndApprove();
        vm.expectRevert(IOffersERC721_v1.OfferorCannotBeZeroAddress.selector);
        vm.prank(address(0));
        offers.createOffer{value: 1 ether}(address(clancyERC721), tokenId);
    }

    function test_createOffer_OfferCannotBeTokenOwner_ShouldFail() public {
        uint32 tokenId = mintAndApprove();
        vm.expectRevert(IOffersERC721_v1.OfferorCannotBeTokenOwner.selector);
        offers.createOffer{value: 1 ether}(address(clancyERC721), tokenId);
    }

    function test_createOffer_TokenDoesNotExist_ShouldFail() public {
        uint32 tokenId = mintAndApprove();
        vm.expectRevert("ERC721: invalid token ID");
        offers.createOffer{value: 1 ether}(address(clancyERC721), tokenId + 1);
    }

    function test_createOffer_ValidContract_ShouldPass() public {
        vm.startPrank(w_main);

        uint32 tokenId = mintAndApprove();
        uint32 itemId = offers.getItemIdCounter();

        vm.stopPrank();

        vm.expectEmit(true, true, true, true, address(offers));
        emit OfferEvent({
            offerType: OfferType.Create,
            itemId: itemId + 1,
            contractAddress: address(clancyERC721),
            tokenId: tokenId,
            tokenOwner: w_main,
            offeror: address(this),
            value: 1 ether
        });
        offers.createOffer{value: 1 ether}(address(clancyERC721), tokenId);
    }

    //#endregion newOffer

    //#region outbidOffer

    function test_outbidOffer_ValueLTExistingOffer_ShouldFail() public {
        vm.startPrank(w_main);

        uint32 tokenId = mintAndApprove();

        vm.stopPrank();

        offers.createOffer{value: 1 ether}(address(clancyERC721), tokenId);

        vm.expectRevert(IOffersERC721_v1.OfferMustBeGTExistingOffer.selector);
        offers.createOffer{value: 1 ether}(address(clancyERC721), tokenId);
    }

    function test_outbidOffer_ValueGTExistingOffer_ShouldPass() public {
        vm.deal(w_one, 3 ether);
        vm.startPrank(w_main);

        uint32 tokenId = mintAndApprove();

        vm.stopPrank();

        offers.createOffer{value: 1 ether}(address(clancyERC721), tokenId);

        uint256 balanceBefore = address(this).balance;
        uint32 itemId = offers.getItemIdCounter();

        vm.startPrank(w_one);

        vm.expectEmit(true, true, true, true, address(offers));
        emit OfferEvent({
            offerType: OfferType.Outbid,
            itemId: itemId,
            contractAddress: address(clancyERC721),
            tokenId: tokenId,
            tokenOwner: w_main,
            offeror: w_one,
            value: 2 ether
        });
        offers.createOffer{value: 2 ether}(address(clancyERC721), tokenId);

        vm.stopPrank();

        uint256 balanceAfter = address(this).balance;
        assertEq(balanceAfter, balanceBefore + 1 ether);
        assertEq(w_one.balance, 1 ether);
    }

    //#endregion outbidOffer

    //#endregion

    //#region acceptOffer

    function test_acceptOffer_ItemDoesNotExist_ShouldFail() public {
        vm.expectRevert(IOffersERC721_v1.OfferDoesNotExist.selector);
        offers.acceptOffer(address(clancyERC721), 1);
    }

    function test_acceptOffer_NotTokenOwner_ShouldFail() public {
        vm.startPrank(w_main);

        uint32 tokenId = mintAndApprove();

        vm.stopPrank();

        offers.createOffer{value: 1 ether}(address(clancyERC721), tokenId);

        vm.expectRevert(IClancyMarketplaceERC721_v1.NotTokenOwner.selector);
        offers.acceptOffer(address(clancyERC721), 1);
    }

    function test_acceptOffer_InsufficientContractBalance_ShouldFail() public {
        vm.startPrank(w_main);

        uint32 tokenId = mintAndApprove();

        vm.stopPrank();

        offers.createOffer{value: 1 ether}(address(clancyERC721), tokenId);
        offers.withdraw();

        vm.startPrank(w_main);
        vm.expectRevert(IOffersERC721_v1.InsufficientContractBalance.selector);
        offers.acceptOffer(address(clancyERC721), 1);
        vm.stopPrank();
    }

    function test_acceptOffer_ShouldPass() public {
        vm.deal(w_one, 2 ether);

        vm.startPrank(w_main);

        uint32 tokenId = mintAndApprove();

        vm.stopPrank();

        vm.prank(w_one);

        offers.createOffer{value: 1 ether}(address(clancyERC721), tokenId);
        assertEq(address(offers).balance, 1 ether);
        uint256 sellerBalanceBefore = w_main.balance;
        // console.log("sellerBalanceBefore", sellerBalanceBefore);
        uint32 itemId = offers.getItemIdCounter();

        vm.startPrank(w_main);

        IERC721(clancyERC721).approve(address(offers), tokenId);

        vm.expectEmit(true, true, true, true, address(offers));
        emit OfferEvent({
            offerType: OfferType.Accept,
            itemId: itemId,
            contractAddress: address(clancyERC721),
            tokenId: tokenId,
            tokenOwner: w_main,
            offeror: w_one,
            value: 1 ether
        });
        offers.acceptOffer(address(clancyERC721), tokenId);
        // console.log("sellerBalanceAfter", w_main.balance);
        assertEq(IERC721(clancyERC721).ownerOf(tokenId), w_one);
        assertEq(w_main.balance, sellerBalanceBefore + 1 ether);

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
        vm.startPrank(w_main);

        uint32 tokenId = mintAndApprove();

        vm.stopPrank();

        offers.createOffer{value: 1 ether}(address(clancyERC721), tokenId);

        vm.prank(w_main);
        vm.expectRevert("Ownable: caller is not the owner");
        offers.cancelOffer(address(clancyERC721), tokenId);
    }

    function test_cancelOffer_ToNonPayable_ShouldFail() public {
        vm.deal(address(clancyERC721), 1 ether);

        uint32 tokenId = mintAndApprove();

        vm.startPrank(address(clancyERC721));

        offers.createOffer{value: 1 ether}(address(clancyERC721), tokenId);

        vm.stopPrank();

        vm.expectRevert();
        offers.cancelOffer(address(clancyERC721), tokenId);
    }

    function test_cancelOffer_ContractHasInsuffienctBalance_ShouldFail()
        public
    {
        vm.startPrank(w_main);

        uint32 tokenId = mintAndApprove();

        vm.stopPrank();

        offers.createOffer{value: 1 ether}(address(clancyERC721), tokenId);

        offers.withdraw();

        vm.expectRevert(IOffersERC721_v1.InsufficientContractBalance.selector);
        offers.cancelOffer(address(clancyERC721), tokenId);
    }

    function test_cancelOffer_ShouldPass() public {
        vm.deal(w_one, 1 ether);

        vm.startPrank(w_main);

        uint32 tokenId = mintAndApprove();

        vm.stopPrank();

        vm.startPrank(w_one);

        uint256 balanceBefore = w_one.balance;
        offers.createOffer{value: 1 ether}(address(clancyERC721), tokenId);
        uint256 balanceAfter = w_one.balance;
        assertEq(balanceAfter, balanceBefore - 1 ether);

        vm.stopPrank();

        uint32 itemId = offers.getItemIdCounter();
        vm.expectEmit(true, true, true, true, address(offers));
        emit OfferEvent({
            offerType: OfferType.Cancel,
            itemId: itemId,
            contractAddress: address(clancyERC721),
            tokenId: tokenId,
            tokenOwner: w_main,
            offeror: w_one,
            value: 1 ether
        });
        offers.cancelOffer(address(clancyERC721), tokenId);

        balanceAfter = w_one.balance;
        assertEq(balanceAfter, balanceBefore);
    }

    //#endregion

    //#region getOffer
    function test_getOffer_ForNonExistentOffer_ShouldPass() public {
        vm.startPrank(w_main);
        uint32 tokenId = mintAndApprove();
        uint32 itemId = offers.getItemIdCounter();

        OfferItem memory offer = offers.getOffer(
            address(clancyERC721),
            tokenId
        );
        vm.stopPrank();
        assertEq(offer.itemId, itemId);
    }

    function test_getOffer_ForExistentOffer_ShouldPass() public {
        vm.startPrank(w_main);

        uint32 tokenId = mintAndApprove();

        vm.stopPrank();

        offers.createOffer{value: 1 ether}(address(clancyERC721), tokenId);
        OfferItem memory offer = offers.getOffer(
            address(clancyERC721),
            tokenId
        );

        uint32 itemId = offers.getItemIdCounter();

        assertEq(offer.itemId, itemId);
        assertEq(offer.offerAmount, 1 ether);
        assertEq(offer.offeror, address(this));
    }

    //#endregion getOffer

    //#region createCollectionOffer
    function test_createCollectionOffer_NoValueSent_ShouldRevert() public {
        vm.expectRevert(IOffersERC721_v1.OfferCannotBeLTEZero.selector);
        offers.createCollectionOffer(address(clancyERC721));
    }

    function test_createCollectionOffer_InvalidContractAddress_ShouldRevert()
        public
    {
        vm.expectRevert(
            IClancyMarketplaceERC721_v1.InputContractInvalid.selector
        );
        offers.createCollectionOffer{value: 1 ether}(address(0));
    }

    function test_createCollectionOffer_ZeroAddressOfferor_ShouldRevert()
        public
    {
        vm.deal(address(0), 10 ether);
        offers.setAllowedContract(address(clancyERC721), true);
        vm.expectRevert(IOffersERC721_v1.OfferorCannotBeZeroAddress.selector);
        vm.prank(address(0));
        offers.createCollectionOffer{value: 1 ether}(address(clancyERC721));
    }

    function test_newCollectionOffer_ShouldPass() public {
        offers.setAllowedContract(address(clancyERC721), true);

        uint256 offerValue = 1 ether;

        vm.startPrank(w_main);

        vm.expectEmit(true, true, true, true, address(offers));
        emit CollectionOfferEvent({
            offerType: OfferType.Create,
            contractAddress: address(clancyERC721),
            offeror: w_main,
            value: offerValue
        });
        offers.createCollectionOffer{value: offerValue}(address(clancyERC721));

        vm.stopPrank();
    }

    function test_newCollectionOffer_MultipleOffers_ShouldPass() public {
        offers.setAllowedContract(address(clancyERC721), true);

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
            emit CollectionOfferEvent({
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
        offers.setAllowedContract(address(clancyERC721), true);

        uint8 offerorCount = uint8(offerors.length);
        uint256 offerAmount = 1 ether;

        // Assumptions
        vm.assume(offerors.length > 0);
        vm.assume(offerors.length <= offerorCount);
        for (uint i; i < offerors.length; ++i) {
            vm.assume(offerors[i] != address(0));
        }

        for (uint8 i; i < offerorCount; ++i) {
            address offeror = offerors[i];
            vm.deal(offeror, offerAmount);

            vm.startPrank(offeror);

            vm.expectEmit(true, true, true, true, address(offers));
            emit CollectionOfferEvent({
                offerType: OfferType.Create,
                contractAddress: address(clancyERC721),
                offeror: offeror,
                value: offerAmount
            });
            offers.createCollectionOffer{value: offerAmount}(
                address(clancyERC721)
            );

            CollectionOfferItem[] memory offers_ = offers.getCollectionOffers(
                address(clancyERC721)
            );

            assertEq(offers_.length, i + 1);

            assertEq(offers_[i].offeror, offeror);
            assertEq(offers_[i].value, offerAmount);

            vm.stopPrank();
        }
    }

    // forge test --match-path test/clancy/marketplace/offers/OffersERC721_v1.t.sol --match-test testFuzz_cancelCollectionOffer_ShouldPass -vvv

    //#endregion createCollectionOffer

    //#region getCollectionOffers

    function test_getCollectionOffers_InvalidContract() public {
        vm.expectRevert(
            IClancyMarketplaceERC721_v1.InputContractInvalid.selector
        );
        offers.getCollectionOffers(address(0));
    }

    function test_getCollectionOffers_ShouldPass() public {
        offers.setAllowedContract(address(clancyERC721), true);

        vm.startPrank(w_main);

        offers.createCollectionOffer{value: 1 ether}(address(clancyERC721));

        vm.stopPrank();

        CollectionOfferItem[] memory offers_ = offers.getCollectionOffers(
            address(clancyERC721)
        );
        uint16 offersLength = uint16(offers_.length);
        CollectionOfferItem memory mock = CollectionOfferItem({
            itemId: 1,
            contractAddress: address(clancyERC721),
            offeror: w_main,
            value: 1 ether
        });

        // // Log the two items side by side
        // console.log(
        //     "ItemIds: mock - %s  offers - %s ",
        //     mock.itemId,
        //     offers_[0].itemId
        // );
        // console.log(
        //     "ContractAddresses: mock - %s  offers - %s ",
        //     mock.contractAddress,
        //     offers_[0].contractAddress
        // );
        // console.log(
        //     "Offerors: mock - %s  offers - %s ",
        //     mock.offeror,
        //     offers_[0].offeror
        // );
        // console.log(
        //     "Values: mock - %s  offers - %s ",
        //     mock.value,
        //     offers_[0].value
        // );

        assertEq(offersLength, 1);
        assertEq(offers_[0].itemId, mock.itemId);
    }

    //#endregion getCollectionOffers

    //#region cancelCollectionOffer

    function test_cancelCollectionOffer_InvalidContract_ShouldRevert() public {
        vm.expectRevert(
            IClancyMarketplaceERC721_v1.InputContractInvalid.selector
        );
        offers.cancelCollectionOffer(address(0), 1);
    }

    function test_cancelCollectionOffer_OfferDoesNotExist_ShouldRevert()
        public
    {
        offers.setAllowedContract(address(clancyERC721), true);
        vm.expectRevert(IOffersERC721_v1.OfferDoesNotExist.selector);
        offers.cancelCollectionOffer(address(clancyERC721), 1);
    }

    function test_cancelCollectionOffer_NotOfferor_ShouldRevert() public {
        offers.setAllowedContract(address(clancyERC721), true);

        vm.prank(w_main);
        offers.createCollectionOffer{value: 1 ether}(address(clancyERC721));

        vm.expectRevert(IOffersERC721_v1.NotOfferor.selector);
        offers.cancelCollectionOffer(address(clancyERC721), 0);
    }

    function test_cancelCollectionOffer_ContractBalanceBelowOffer_ShouldRevert()
        public
    {
        offers.setAllowedContract(address(clancyERC721), true);

        offers.createCollectionOffer{value: 1 ether}(address(clancyERC721));

        offers.withdraw();

        vm.expectRevert(
            abi.encodeWithSelector(
                IOffersERC721_v1.TransferFailed.selector,
                "OffersERC721_v1: Cancelled Offer refund failed."
            )
        );
        offers.cancelCollectionOffer(address(clancyERC721), 0);
    }

    function test_cancelCollectionOffer_ShouldPass() public {
        offers.setAllowedContract(address(clancyERC721), true);

        uint256 offerValue = 1 ether;
        uint256 balanceBefore = address(this).balance;

        offers.createCollectionOffer{value: offerValue}(address(clancyERC721));

        uint256 balanceAfterOffer = address(this).balance;
        assertEq(balanceAfterOffer, balanceBefore - offerValue);

        vm.expectEmit(true, true, true, true, address(offers));
        emit CollectionOfferEvent({
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

    function testFuzz_cancelCollectionOffer_ShouldPass(
        address[] calldata offerors
    ) public {
        offers.setAllowedContract(address(clancyERC721), true);

        uint8 offerorCount = uint8(offerors.length);
        uint256 offerAmount = 1 ether;

        // Assumptions
        vm.assume(offerors.length > 0);
        vm.assume(offerors.length <= offerorCount);
        for (uint8 i; i < offerors.length; ++i) {
            vm.assume(offerors[i] != address(0));
        }

        for (uint8 i; i < offerorCount; ++i) {
            address offeror = offerors[i];
            vm.deal(offeror, offerAmount);

            vm.startPrank(offeror);

            vm.expectEmit(true, true, true, true, address(offers));
            emit CollectionOfferEvent({
                offerType: OfferType.Create,
                contractAddress: address(clancyERC721),
                offeror: offeror,
                value: offerAmount
            });
            offers.createCollectionOffer{value: offerAmount}(
                address(clancyERC721)
            );

            CollectionOfferItem[] memory offers_ = offers.getCollectionOffers(
                address(clancyERC721)
            );

            assertEq(offers_.length, i + 1);

            assertEq(offers_[i].offeror, offeror);
            assertEq(offers_[i].value, offerAmount);

            vm.stopPrank();
        }

        for (uint8 i; i < offerorCount; ++i) {
            address offeror = offerors[i];

            vm.startPrank(offeror);

            CollectionOfferItem[] memory offers_ = offers.getCollectionOffers(
                address(clancyERC721)
            );
            console.log("offers_.length: %s", offers_.length);
            // Find the index where the offeror is the offeror
            uint8 index;
            for (uint8 j; j < offers_.length; ++j) {
                if (offers_[j].offeror == offeror) {
                    index = j;
                    console.log("Found offeror at index: %s", index);
                    break;
                }
            }
            // vm.expectEmit(true, true, true, true, address(offers));
            // emit CollectionOfferEvent({
            //     offerType: "cancel",
            //     contractAddress: address(clancyERC721),
            //     offeror: offeror,
            //     value: offerAmount
            // });
            // offers.cancelCollectionOffer(address(clancyERC721), index);

            vm.stopPrank();
        }
    }

    //#endregion cancelCollectionOffer

    //#region Helpers
    function mintAndApprove() internal returns (uint32) {
        uint32 tokenId = clancyERC721.mint();
        clancyERC721.approve(address(offers), tokenId);
        return tokenId;
    }
    //#endregion
}
