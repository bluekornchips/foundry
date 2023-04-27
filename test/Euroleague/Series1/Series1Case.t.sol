// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";

import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";

import {IClancyERC721} from "clancy/ERC/ERC721/IClancyERC721.sol";

import {ISeries1Case, Series1Case} from "euroleague/series1/Series1Case.sol";
import {Reels} from "euroleague/series1/Reels.sol";

import {ClancyERC721TestHelpers} from "test-helpers//ClancyERC721TestHelpers.sol";
import {Titan} from "test-helpers/Titan/Titan.sol";

contract Case_Test is Test, ClancyERC721TestHelpers, Titan {
    using Strings for uint256;

    Series1Case public series1Case;
    Reels public reels;

    function setUp() public {
        series1Case = new Series1Case(NAME, SYMBOL, MAX_SUPPLY, BASE_URI);
        reels = new Reels(NAME, SYMBOL, MAX_SUPPLY, BASE_URI);
    }

    //#region getReelsPerCase
    function test_getReelsPerCase() public {
        uint256 reelsPerCase = series1Case.getReelsPerCase();
        assertEq(reelsPerCase, 3);
    }

    //#endregion

    //#region setReelPerCase
    function test_setReelsPerCase() public {
        series1Case.setReelsPerCase(5);
        uint256 reelsPerCase = series1Case.getReelsPerCase();
        assertEq(reelsPerCase, 5);
    }

    function test_setReelsPerCaseAsNonOwner_ShouldRevert() public {
        vm.prank(w_main);
        vm.expectRevert("Ownable: caller is not the owner");
        series1Case.setReelsPerCase(5);
    }

    function testFuzz_setReelsPerCase(uint8 reelsPerCase) public {
        vm.assume(reelsPerCase > 0);
        series1Case.setReelsPerCase(uint8(reelsPerCase));
        assertEq(series1Case.getReelsPerCase(), uint256(reelsPerCase));
    }

    function testFuzz_setReelsPerCaseLTEZero_ShouldRevert(
        uint8 reelsPerCase
    ) public {
        vm.assume(reelsPerCase <= 0);
        vm.expectRevert(
            abi.encodeWithSelector(ISeries1Case.ReelsPerCaseNotValid.selector)
        );
        series1Case.setReelsPerCase(uint8(reelsPerCase));
    }

    //#endregion

    //#region getReelsContract
    function test_getReelsContract() public {
        Reels reelsContract = series1Case.getReelsContract();
        assertEq(address(reelsContract), address(0));
    }

    //#endregion

    //#region setReelsContract
    function test_setReelsContract() public {
        Reels reelsContract = new Reels(NAME, SYMBOL, MAX_SUPPLY, BASE_URI);
        series1Case.setReelsContract(address(reelsContract));
        assertEq(
            address(series1Case.getReelsContract()),
            address(reelsContract)
        );
    }

    function test_setReelsContractAsNonOwner_ShouldRevert() public {
        Reels reelsContract = new Reels(NAME, SYMBOL, MAX_SUPPLY, BASE_URI);

        vm.prank(w_main);
        vm.expectRevert("Ownable: caller is not the owner");
        series1Case.setReelsContract(address(reelsContract));
    }

    function test_setReelsContract_ZeroAddress_ShouldRevert() public {
        vm.expectRevert(
            abi.encodeWithSelector(ISeries1Case.ReelsContractNotValid.selector)
        );
        series1Case.setReelsContract(address(0));
    }

    function test_setReelsContract_ToEOA_ShouldRevert() public {
        vm.expectRevert(
            abi.encodeWithSelector(ISeries1Case.ReelsContractNotValid.selector)
        );
        series1Case.setReelsContract(w_main);
    }

    //#endregion

    //#region openCase
    function reelsSetup() public {
        if (address(reels) == address(0)) {
            return;
        }
        Reels reelsContract = new Reels(NAME, SYMBOL, MAX_SUPPLY, BASE_URI);
        series1Case.setReelsContract(address(reelsContract));
        reels = reelsContract;
        reels.setCaseContract(address(series1Case), true);
        series1Case.setPublicMintEnabled(true);
        series1Case.setBurnEnabled(true);
        reels.setPublicMintEnabled(true);
    }

    function test_openCase_shouldPass() public {
        reelsSetup();

        uint256 reelsPerCase = series1Case.getReelsPerCase();
        uint256 reelsBalanceBefore = reels.balanceOf(w_main);
        console.log("reelsBalanceBefore: ", reelsBalanceBefore.toString());

        vm.startPrank(w_main);

        uint32 tokenId = series1Case.mint();
        series1Case.openCase(tokenId);

        vm.stopPrank();

        uint256 reelsBalanceAfter = reels.balanceOf(w_main);
        console.log("reelsBalanceAfter: ", reelsBalanceAfter.toString());
        assertEq(reelsBalanceAfter, reelsBalanceBefore + reelsPerCase);
        assertEq(reelsBalanceAfter, 3);
    }

    function test_openCase_AsNonOwner_ShouldRevert() public {
        reelsSetup();

        uint32 tokenId = series1Case.mint();

        vm.prank(w_main);
        vm.expectRevert(
            abi.encodeWithSelector(IClancyERC721.NotApprovedOrOwner.selector)
        );
        series1Case.openCase(tokenId);
    }

    function test_openCase_AsApproved_ShouldSucceed() public {
        reelsSetup();

        vm.prank(w_main);
        uint32 tokenId = series1Case.mint();

        vm.prank(w_main);
        series1Case.approve(address(this), tokenId);
        series1Case.openCase(tokenId);
        uint256 reelsBalance = reels.balanceOf(w_main);
        uint256 series1CaseBalance = series1Case.balanceOf(w_main);
        assertEq(reelsBalance, 3);
        assertEq(series1CaseBalance, 0);
    }
}
