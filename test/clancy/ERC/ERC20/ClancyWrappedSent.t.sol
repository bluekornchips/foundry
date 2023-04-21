// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";

import {ClancyWrappedSent} from "clancy/ERC/ERC20/ClancyWrappedSent.sol";

import {Titan} from "test-helpers/Titan/Titan.sol";

contract ClancyWrappedSent_Test is Test, Titan {
    ClancyWrappedSent clancyWrappedSent;

    function setUp() public {
        clancyWrappedSent = new ClancyWrappedSent("WrappedSent", "WSENT");
    }
}
