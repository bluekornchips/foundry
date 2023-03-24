// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";

contract ClancyPayable is Ownable {
    event Withdrawn(address indexed, uint256 indexed);

    receive() external payable {}

    function withdraw() external onlyOwner {
        emit Withdrawn(msg.sender, address(this).balance);
        payable(msg.sender).transfer(address(this).balance);
    }
}
