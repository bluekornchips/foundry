// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";

contract ClancyPayable is Ownable {
    error WithdrawError();
    event Withdrawn(address indexed, uint256 indexed);

    receive() external payable {}

    function withdraw() external onlyOwner {
        emit Withdrawn(msg.sender, address(this).balance);
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        if (!success) {
            revert WithdrawError();
        }
    }
}
