// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

contract ClancyERC721TestHelpers {
    string public constant NAME = "ClancyERC721";
    string public constant SYMBOL = "CERC721";
    uint32 public constant MAX_SUPPLY = 10_000;
    string public constant BASE_URI = "https://clancy.com/";

    receive() external payable {}

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
