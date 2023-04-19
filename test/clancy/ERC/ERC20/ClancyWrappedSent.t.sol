// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";

import {ClancyWrappedSent} from "clancy/ERC/ERC20/ClancyWrappedSent.sol";

import {TEST_CONSTANTS} from "test-helpers//TEST_CONSTANTS.sol";

contract ClancyWrappedSent_Test is Test, TEST_CONSTANTS {
    ClancyWrappedSent clancyWrappedSent;

    function setUp() public {
        clancyWrappedSent = new ClancyWrappedSent("WrappedSent", "WSENT");
    }
}
