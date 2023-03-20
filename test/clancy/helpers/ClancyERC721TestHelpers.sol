// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

contract ClancyERC721TestHelpers {
    string public constant NAME = "ClancyERC721";
    string public constant SYMBOL = "CERC721";
    uint96 public constant MAX_SUPPLY = 100;
    string public constant BASE_URI = "https://clancy.com/";

    address public constant DEV_WALLET =
        0x62643f6CAC3E8e8bA332A3D753A0Ce751e1E3C93;

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
