// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";

import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";

import {IClancyERC20, ClancyERC20} from "clancy/ERC/ERC20/ClancyERC20.sol";
import {ClancyERC20Airdrop} from "clancy/ERC/ERC20/utils/ClancyERC20Airdrop.sol";

import {IClancyERC20Airdrop_Test} from "./IClancyERC20Airdrop.t.sol";

contract ClancyERC20Airdrop_Test is Test, IClancyERC20Airdrop_Test {
    ClancyERC20 public clancyERC20;
    ClancyERC20Airdrop public airdropper;

    uint256 airdropAmount = 100_000;

    function setUp() public {
        clancyERC20 = new ClancyERC20(NAME, SYMBOL, INITIAL_SUPPLY, CAP);
        airdropper = new ClancyERC20Airdrop();
    }

    /**
     * An empty array.
     * Should revert.
     */
    function test_airdrop_EmptyAirdropArray_ShouldRevert() public {
        ERC20Package[] memory values = new ERC20Package[](0);
        vm.expectRevert(AirdropLengthInvalid.selector);
        airdropper.airdrop(clancyERC20, values);
    }

    /**
     * An array larger than the MAX_DROPS permits.
     * Should revert.
     */
    function test_airdrop_ArrayLargerThanMaxDrops_ShouldRevert() public {
        ERC20Package[] memory values = new ERC20Package[](
            airdropper.MAX_DROPS() + 1
        );
        vm.expectRevert(AirdropLengthInvalid.selector);
        airdropper.airdrop(clancyERC20, values);
    }

    /**
     * An insufficient allowance.
     * Should revert.
     */
    function test_airdrop_InsufficientAllowance_ShouldRevert() public {
        ERC20Package[] memory values = new ERC20Package[](1);
        values[0] = ERC20Package(w_main, airdropAmount);
        vm.expectRevert("ERC20: insufficient allowance");
        airdropper.airdrop(clancyERC20, values);
    }

    /**
     * An array with a zero address.
     * Should revert.
     */
    function test_airdrop_ArrayWithZeroAddress_ShouldRevert() public {
        ERC20Package[] memory values = new ERC20Package[](1);
        values[0] = ERC20Package(address(0), airdropAmount);
        clancyERC20.increaseAllowance(
            address(airdropper),
            airdropAmount * values.length
        );
        vm.expectRevert("ERC20: transfer to the zero address");
        airdropper.airdrop(clancyERC20, values);
    }

    /**
     * An array with a zero value.
     * Should revert.
     */
    function test_airdrop_ArrayWithZeroValue_ShouldRevert() public {
        ERC20Package[] memory values = new ERC20Package[](1);
        values[0] = ERC20Package(w_main, 0);
        clancyERC20.increaseAllowance(
            address(airdropper),
            airdropAmount * values.length
        );
        vm.expectRevert(ZeroBalanceTransfer.selector);
        airdropper.airdrop(clancyERC20, values);
    }

    function test_airdrop_shouldPass() public {
        uint256 totalAirdroppedValue;
        ERC20Package[] memory values = new ERC20Package[](addrs.length);
        for (uint256 i; i < addrs.length; i++) {
            values[i] = ERC20Package(addrs[i], airdropAmount);
            totalAirdroppedValue += airdropAmount;
        }

        if (
            !clancyERC20.increaseAllowance(
                address(airdropper),
                totalAirdroppedValue
            )
        ) {
            revert();
        }

        // Execute drop.

        airdropper.airdrop(clancyERC20, values);

        // Asserts
        assertEq(
            clancyERC20.balanceOf(address(this)),
            INITIAL_SUPPLY - totalAirdroppedValue
        );

        for (uint256 i; i < addrs.length; i++) {
            assertEq(clancyERC20.balanceOf(addrs[i]), airdropAmount);
        }
    }

    function testFuzz_airdrop(address[] calldata recipients) public {
        ERC20Package[] memory package = new ERC20Package[](recipients.length);

        vm.assume(recipients.length > 0);
        vm.assume(recipients.length <= airdropper.MAX_DROPS());

        // Assume none are zero address
        for (uint256 i; i < recipients.length; i++) {
            vm.assume(recipients[i] != address(0));
            // Assume no repeats
            for (uint256 j; j < i; j++) {
                vm.assume(recipients[i] != recipients[j]);
            }
        }

        uint256 totalAirdroppedValue;

        for (uint256 i = 0; i < recipients.length; i++) {
            package[i] = ERC20Package(recipients[i], airdropAmount);
            totalAirdroppedValue += airdropAmount;
        }

        clancyERC20.increaseAllowance(
            address(airdropper),
            totalAirdroppedValue
        );

        airdropper.airdrop(clancyERC20, package);

        assertEq(
            clancyERC20.balanceOf(address(this)),
            INITIAL_SUPPLY - totalAirdroppedValue
        );

        for (uint256 i; i < package.length; i++) {
            assertEq(
                clancyERC20.balanceOf(package[i].recipient),
                package[i].value
            );
        }
    }
}
