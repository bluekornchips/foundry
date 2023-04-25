// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";

contract Forks is Test {
    // Main Nets
    uint256 public mainnetFork;
    uint256 public polygonFork;

    // Test Nets
    uint256 public sentinelFork;
    uint256 public sepoliaFork;
    uint256 public mumbaiFork;

    constructor() {
        // Main Nets
        mainnetFork = vm.createFork(vm.envString("RPC_URL_MAINNET"));
        polygonFork = vm.createFork(vm.envString("RPC_URL_POLYGON"));

        // Test Nets
        sentinelFork = vm.createFork(vm.envString("RPC_URL_SENTINEL_DEV"));
        sepoliaFork = vm.createFork(vm.envString("RPC_URL_SEPOLIA"));
        mumbaiFork = vm.createFork(vm.envString("RPC_URL_MUMBAI"));
    }
}
