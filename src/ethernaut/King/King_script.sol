// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "ethernaut/King/King.sol";
import "forge-std/Test.sol";
import "ethernaut/EthernautTestHelpers.sol";

contract King_script is Test, EthernautTestHelpers {
    function run() public {
        uint256 PKEY = vm.envUint("DEPLOYMENT_KEY");
        vm.startBroadcast(PKEY);
        King instance = King(
            payable(0x41cF6F5987db828810935789be53a99267754926)
        );
        address king = instance._king();
        console.log("king", king);
        uint activePrize = instance.prize();
        console.log("activePrize", activePrize);

        // KingTrapper trapper = new KingTrapper{
        //     value: activePrize + 0.000001 ether
        // }();
        king = instance._king();
        console.log("king", king);
        activePrize = instance.prize();
        console.log("activePrize", activePrize);

        vm.stopBroadcast();
    }
}
