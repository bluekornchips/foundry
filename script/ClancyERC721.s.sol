// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import {ClancyERC721} from "clancy/ERC/ClancyERC721.sol";

contract ClancyERC721Script is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("WALLET_PRIVATE_KEY_NODE0");

        vm.startBroadcast(deployerPrivateKey);

        ClancyERC721 clancyERC721 = new ClancyERC721(
            "ClancyERC721",
            "CLANCY",
            100,
            "https://clancy.com/"
        );

        vm.stopBroadcast();
    }
}
