// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

contract IClancyERC721Airdroppable {
    error AirdropRecipientCannotBeZero();
    error AirdropTokenCountCannotBeLTOne();

    struct Airdrop {
        address recipient;
        uint32 tokenCount;
    }

    struct Airdropped {
        address recipient;
        uint32[] tokenIds;
    }

    event AirdropDelivered(uint16 indexed, Airdropped[]);
}
