// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";
import "clancy-test/helpers/ClancyERC721TestHelpers.sol";
import "euroleague/series1/Series1Case.sol";
import "euroleague/series1/Moments.sol";

contract Moments_Test is Test, ClancyERC721TestHelpers {
    using Strings for uint256;

    Moments public moments;
    Series1Case public series1Case;

    // Errors ClancyERC721
    error PublicMintDisabled(string message);
    error MaxSupply(string message);

    // Errors Moments
    error NotCaseContract(string message);
    error CaseContractNotValid(string message);

    function setUp() public {
        moments = new Moments(NAME, SYMBOL, MAX_SUPPLY, BASE_URI);
        series1Case = new Series1Case(NAME, SYMBOL, MAX_SUPPLY, BASE_URI);
        series1Case.setMomentsContract(address(moments));
    }

    //#region isCaseContract
    function test_isCaseContract() public {
        bool isCaseContract = moments.isCaseContract(address(series1Case));
        assertEq(isCaseContract, false);
    }

    function test_isCaseContract_whenCaseContract() public {
        moments.setCaseContract(address(series1Case), true);
        bool isCaseContract = moments.isCaseContract(address(series1Case));
        assertEq(isCaseContract, true);
    }

    //#endregion

    //#region setCaseContract
    function test_setCaseContract() public {
        moments.setCaseContract(address(series1Case), true);
        bool isCaseContract = moments.isCaseContract(address(series1Case));
        assertEq(isCaseContract, true);
    }

    function test_setCaseContractAsNonOwner_ShouldRevert() public {
        vm.prank(DEV_WALLET);
        vm.expectRevert("Ownable: caller is not the owner");
        moments.setCaseContract(address(series1Case), true);
    }

    function test_setCaseContract_AsZeroAddress_ShouldRevert() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                CaseContractNotValid.selector,
                "Case contract cannot be the zero address."
            )
        );
        moments.setCaseContract(address(0), true);
    }

    function test_setCaseContract_setExisingTrueToFalse() public {
        moments.setCaseContract(address(series1Case), true);
        bool isCaseContract = moments.isCaseContract(address(series1Case));
        assertEq(isCaseContract, true);
        moments.setCaseContract(address(series1Case), false);
        isCaseContract = moments.isCaseContract(address(series1Case));
        assertEq(isCaseContract, false);
    }

    //#endregion

    //#region mint
    function test_mint_whenPublicMintIsDisabled_andNotPaused() public {
        moments.setCaseContract(address(series1Case), true);

        vm.prank(address(series1Case));
        vm.expectRevert(
            abi.encodeWithSelector(
                PublicMintDisabled.selector,
                "ClancyERC721: Public minting is disabled."
            )
        );
        moments.mint();
    }

    function test_mint_whenPublicMintIsEnabled_andPaused() public {
        moments.pause();
        moments.setPublicMintStatus(true);
        moments.setCaseContract(address(series1Case), true);

        vm.prank(address(series1Case));
        vm.expectRevert("Pausable: paused");
        moments.mint();
    }

    function test_mint_1() public {
        moments.setCaseContract(address(series1Case), true);
        moments.setPublicMintStatus(true);

        vm.prank(address(series1Case));
        uint256 tokenId = moments.mint();
        assertEq(tokenId, 1);
    }

    function test_mint_100() public {
        moments.setCaseContract(address(series1Case), true);
        moments.setPublicMintStatus(true);
        uint256 totalSupply = moments.totalSupply();
        assertEq(totalSupply, 0);
        for (uint256 i = 0; i < 100; i++) {
            vm.prank(address(series1Case));
            moments.mint();
            uint256 tokenId = moments.getTokenIdCounter();
            string memory tokenURI = moments.tokenURI(i + 1);
            string memory expectedTokenURI = string(
                abi.encodePacked(BASE_URI, tokenId.toString())
            );
            assertEq(tokenURI, expectedTokenURI);
        }
        totalSupply = moments.totalSupply();
        assertEq(totalSupply, 100);
    }

    function test_mint_101() public {
        moments.setCaseContract(address(series1Case), true);
        moments.setPublicMintStatus(true);
        uint256 totalSupply = moments.totalSupply();
        assertEq(totalSupply, 0);
        for (uint256 i = 0; i < 100; i++) {
            vm.prank(address(series1Case));
            moments.mint();
        }
        totalSupply = moments.totalSupply();
        assertEq(totalSupply, 100);
        vm.expectRevert(
            abi.encodeWithSelector(
                MaxSupply.selector,
                "ClancyERC721: Max supply reached."
            )
        );
        vm.prank(address(series1Case));
        moments.mint();
    }

    // function test_mint_supplyCeiling() public {
    //     moments.setCaseContract(address(series1Case), true);
    //     moments.setPublicMintStatus(true);
    //     uint256 ceiling = moments.SUPPLY_CEILING();
    //     moments.setMaxSupply(uint96(ceiling));
    //     assertEq(ceiling, 1_000_000);
    //     for (uint256 i = 0; i < ceiling; i++) {
    //         vm.prank(address(series1Case));
    //         moments.mint();
    //     }
    //     uint256 totalSupply = moments.totalSupply();
    //     assertEq(totalSupply, ceiling);
    //     vm.expectRevert("ClancyERC721: Max supply reached.");
    //     vm.prank(address(series1Case));
    //     moments.mint();
    // }

    function testFuzz_mint(uint256 seed) public {
        vm.assume(seed < MAX_SUPPLY);
        moments.setCaseContract(address(series1Case), true);
        moments.setPublicMintStatus(true);
        uint256 totalSupply = moments.totalSupply();
        assertEq(totalSupply, 0);
        for (uint256 i = 0; i < seed; i++) {
            vm.prank(address(series1Case));
            moments.mint();
            uint256 tokenId = moments.getTokenIdCounter();
            string memory tokenURI = moments.tokenURI(i + 1);
            string memory expectedTokenURI = string(
                abi.encodePacked(BASE_URI, tokenId.toString())
            );
            assertEq(tokenURI, expectedTokenURI);
        }
        totalSupply = moments.totalSupply();
        assertEq(totalSupply, seed);
    }
    //#endregion
}
