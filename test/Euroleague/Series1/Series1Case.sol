// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "clancy-test/helpers/ClancyERC721TestHelpers.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";
import "euroleague/series1/Series1Case.sol";
import "euroleague/series1/Moments.sol";

contract Case_Test is Test, ClancyERC721TestHelpers {
    using Strings for uint256;

    Series1Case public series1Case;
    Moments public moments;

    function setUp() public {
        series1Case = new Series1Case(NAME, SYMBOL, MAX_SUPPLY, BASE_URI);
        moments = new Moments(NAME, SYMBOL, MAX_SUPPLY, BASE_URI);
    }

    //#region getMomentsPerCase
    function test_getMomentsPerCase() public {
        uint256 momentsPerCase = series1Case.getMomentsPerCase();
        assertEq(momentsPerCase, 3);
    }

    //#endregion

    //#region setMomentPerCase
    function test_setMomentsPerCase() public {
        series1Case.setMomentsPerCase(5);
        uint256 momentsPerCase = series1Case.getMomentsPerCase();
        assertEq(momentsPerCase, 5);
    }

    function test_setMomentsPerCaseAsNonOwner_ShouldRevert() public {
        vm.prank(DEV_WALLET);
        vm.expectRevert("Ownable: caller is not the owner");
        series1Case.setMomentsPerCase(5);
    }

    function testFuzz_setMomentsPerCase(uint8 momentsPerCase) public {
        vm.assume(momentsPerCase > 0);
        series1Case.setMomentsPerCase(uint8(momentsPerCase));
        assertEq(series1Case.getMomentsPerCase(), uint256(momentsPerCase));
    }

    function testFuzz_setMomentsPerCaseLTEZero_ShouldRevert(
        uint8 momentsPerCase
    ) public {
        vm.assume(momentsPerCase <= 0);
        vm.expectRevert(
            abi.encodeWithSelector(ISeries1Case.MomentsPerCaseNotValid.selector)
        );
        series1Case.setMomentsPerCase(uint8(momentsPerCase));
    }

    //#endregion

    //#region getMomentsContract
    function test_getMomentsContract() public {
        Moments momentsContract = series1Case.getMomentsContract();
        assertEq(address(momentsContract), address(0));
    }

    //#endregion

    //#region setMomentsContract
    function test_setMomentsContract() public {
        Moments momentsContract = new Moments(
            NAME,
            SYMBOL,
            MAX_SUPPLY,
            BASE_URI
        );
        series1Case.setMomentsContract(address(momentsContract));
        assertEq(
            address(series1Case.getMomentsContract()),
            address(momentsContract)
        );
    }

    function test_setMomentsContractAsNonOwner_ShouldRevert() public {
        Moments momentsContract = new Moments(
            NAME,
            SYMBOL,
            MAX_SUPPLY,
            BASE_URI
        );

        vm.prank(DEV_WALLET);
        vm.expectRevert("Ownable: caller is not the owner");
        series1Case.setMomentsContract(address(momentsContract));
    }

    function test_setMomentsContract_ZeroAddress_ShouldRevert() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                ISeries1Case.MomentsContractNotValid.selector
            )
        );
        series1Case.setMomentsContract(address(0));
    }

    function test_setMomentsContract_ToEOA_ShouldRevert() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                ISeries1Case.MomentsContractNotValid.selector
            )
        );
        series1Case.setMomentsContract(DEV_WALLET);
    }

    //#endregion

    //#region openCase
    function momentsSetup() public {
        if (address(moments) == address(0)) {
            return;
        }
        Moments momentsContract = new Moments(
            NAME,
            SYMBOL,
            MAX_SUPPLY,
            BASE_URI
        );
        series1Case.setMomentsContract(address(momentsContract));
        moments = momentsContract;
        moments.setCaseContract(address(series1Case), true);
        series1Case.setPublicMintStatus(true);
        series1Case.setBurnStatus(true);
        moments.setPublicMintStatus(true);
    }

    function test_openCase() public {
        momentsSetup();

        uint256 momentsPerCase = series1Case.getMomentsPerCase();
        uint256 momentsBalanceBefore = moments.balanceOf(DEV_WALLET);

        vm.prank(DEV_WALLET);
        uint96 tokenId = series1Case.mint();

        vm.prank(DEV_WALLET);
        series1Case.openCase(tokenId);

        uint256 momentsBalanceAfter = moments.balanceOf(DEV_WALLET);
        assertEq(momentsBalanceAfter, momentsBalanceBefore + momentsPerCase);
        assertEq(momentsBalanceAfter, 3);
    }

    function test_openCase_AsNonOwner_ShouldRevert() public {
        momentsSetup();

        uint96 tokenId = series1Case.mint();

        vm.prank(DEV_WALLET);
        vm.expectRevert(
            abi.encodeWithSelector(IClancyERC721.NotApprovedOrOwner.selector)
        );
        series1Case.openCase(tokenId);
    }

    function test_openCase_AsApproved_ShouldSucceed() public {
        momentsSetup();

        vm.prank(DEV_WALLET);
        uint96 tokenId = series1Case.mint();

        vm.prank(DEV_WALLET);
        series1Case.approve(address(this), tokenId);
        series1Case.openCase(tokenId);
        uint256 momentsBalance = moments.balanceOf(DEV_WALLET);
        uint256 series1CaseBalance = series1Case.balanceOf(DEV_WALLET);
        assertEq(momentsBalance, 3);
        assertEq(series1CaseBalance, 0);
    }
}
