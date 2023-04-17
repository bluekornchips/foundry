// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "ethernaut/Reentrance/Reentrance.sol";
import "forge-std/Test.sol";
import "ethernaut/EthernautTestHelpers.sol";

contract Reentance_script is Test, EthernautTestHelpers {
    function run() public {
        uint256 PKEY = vm.envUint("DEPLOYMENT_KEY");
        vm.startBroadcast(PKEY);
        Attacker attacker = new Attacker();
        attacker.attack{value: 0.0001 ether}();
        vm.stopBroadcast();
    }
}
