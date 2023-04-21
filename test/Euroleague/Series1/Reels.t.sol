// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";

import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";

import {IClancyERC721} from "clancy/ERC/ERC721/IClancyERC721.sol";

import {Series1Case} from "euroleague/series1/Series1Case.sol";
import {IReels, Reels} from "euroleague/series1/Reels.sol";

import {ClancyERC721TestHelpers} from "test-helpers//ClancyERC721TestHelpers.sol";
import {Titan} from "test-helpers/Titan/Titan.sol";

contract Reels_Test is Test, ClancyERC721TestHelpers, Titan {
    using Strings for uint256;

    Reels public reels;
    Series1Case public series1Case;

    function setUp() public {
        reels = new Reels(NAME, SYMBOL, MAX_SUPPLY, BASE_URI);
        series1Case = new Series1Case(NAME, SYMBOL, MAX_SUPPLY, BASE_URI);
        series1Case.setReelsContract(address(reels));
    }

    //#region isCaseContract
    function test_isCaseContract() public {
        bool isCaseContract = reels.isCaseContract(address(series1Case));
        assertEq(isCaseContract, false);
    }

    function test_isCaseContract_whenCaseContract() public {
        reels.setCaseContract(address(series1Case), true);
        bool isCaseContract = reels.isCaseContract(address(series1Case));
        assertEq(isCaseContract, true);
    }

    //#endregion

    //#region setCaseContract
    function test_setCaseContract() public {
        // vm.expectEmit(true, true, false, false);
        // emit CaseContractSet(address(series1Case), true);
        reels.setCaseContract(address(series1Case), true);
        bool isCaseContract = reels.isCaseContract(address(series1Case));
        assertEq(isCaseContract, true);
    }

    function test_setCaseContractAsNonOwner_ShouldRevert() public {
        vm.prank(w_main);
        vm.expectRevert("Ownable: caller is not the owner");
        reels.setCaseContract(address(series1Case), true);
    }

    function test_setCaseContract_AsZeroAddress_ShouldRevert() public {
        vm.expectRevert(IReels.CaseContractInvalid.selector);
        reels.setCaseContract(address(0), true);
    }

    function test_setCaseContract_AsEOA_ShouldRevert() public {
        vm.expectRevert(IReels.CaseContractInvalid.selector);
        reels.setCaseContract(w_main, true);
    }

    function test_setCaseContract_setExisingTrueToFalse_ShouldPass() public {
        reels.setCaseContract(address(series1Case), true);
        bool isCaseContract = reels.isCaseContract(address(series1Case));
        assertEq(isCaseContract, true);
        reels.setCaseContract(address(series1Case), false);
        isCaseContract = reels.isCaseContract(address(series1Case));
        assertEq(isCaseContract, false);
    }

    //#endregion

    //#region mint
    function test_mint_whenPublicMintIsDisabledAndNotPaused_ShouldPass()
        public
    {
        reels.setCaseContract(address(series1Case), true);
        vm.expectRevert(
            abi.encodeWithSelector(IClancyERC721.PublicMintDisabled.selector)
        );
        reels.mint();
    }

    function test_mint_whenPublicMintIsEnabledAndPaused_ShouldRevert() public {
        reels.pause();
        reels.setPublicMintStatus(true);
        reels.setCaseContract(address(series1Case), true);

        vm.prank(address(series1Case));
        vm.expectRevert("Pausable: paused");
        reels.mint();
    }

    function test_mint_fromNonOwner_ShouldRevert() public {
        reels.setPublicMintStatus(true);
        vm.prank(w_main);
        vm.expectRevert("Ownable: caller is not the owner");
        reels.mint();
    }

    function test_mint_1_AsOwner_ShouldPass() public {
        reels.setCaseContract(address(series1Case), true);
        reels.setPublicMintStatus(true);

        uint256 tokenId = reels.mint();
        assertEq(tokenId, 1);
    }

    function test_mint_100_AsOwner_ShouldPass() public {
        reels.setCaseContract(address(series1Case), true);
        reels.setPublicMintStatus(true);
        uint256 totalSupply = reels.totalSupply();
        assertEq(totalSupply, 0);
        for (uint256 i = 0; i < 100; i++) {
            reels.mint();
            uint256 tokenId = reels.getTokenIdCounter();
            string memory tokenURI = reels.tokenURI(i + 1);
            string memory expectedTokenURI = string(
                abi.encodePacked(BASE_URI, tokenId.toString())
            );
            assertEq(tokenURI, expectedTokenURI);
        }
        totalSupply = reels.totalSupply();
        assertEq(totalSupply, 100);
    }

    function test_mint_101_AsOwner_ShouldPass() public {
        reels.setCaseContract(address(series1Case), true);
        reels.setPublicMintStatus(true);
        uint256 totalSupply = reels.totalSupply();
        assertEq(totalSupply, 0);
        for (uint256 i = 0; i < 100; i++) {
            reels.mint();
        }
        totalSupply = reels.totalSupply();
        assertEq(totalSupply, 100);
        vm.expectRevert(
            abi.encodeWithSelector(IClancyERC721.MaxSupply_Reached.selector)
        );
        reels.mint();
    }

    // function test_mint_supplyCeiling() public {
    //     reels.setCaseContract(address(series1Case), true);
    //     reels.setPublicMintStatus(true);
    //     uint256 ceiling = reels.SUPPLY_CEILING();
    //     reels.setMaxSupply(uint256(ceiling));
    //     assertEq(ceiling, 1_000_000);
    //     for (uint256 i = 0; i < ceiling; i++) {
    //         vm.prank(address(series1Case));
    //         reels.mint();
    //     }
    //     uint256 totalSupply = reels.totalSupply();
    //     assertEq(totalSupply, ceiling);
    //     vm.expectRevert("ClancyERC721: Max supply reached.");
    //     vm.prank(address(series1Case));
    //     reels.mint();
    // }

    function testFuzz_mint(uint256 seed) public {
        vm.assume(seed < MAX_SUPPLY);

        reels.setCaseContract(address(series1Case), true);
        reels.setPublicMintStatus(true);

        uint256 totalSupply = reels.totalSupply();
        assertEq(totalSupply, 0);
        for (uint256 i = 0; i < seed; i++) {
            reels.mint();
            uint256 tokenId = reels.getTokenIdCounter();
            string memory tokenURI = reels.tokenURI(i + 1);
            string memory expectedTokenURI = string(
                abi.encodePacked(BASE_URI, tokenId.toString())
            );
            assertEq(tokenURI, expectedTokenURI);
        }
        totalSupply = reels.totalSupply();
        assertEq(totalSupply, seed);
    }
    //#endregion
}
