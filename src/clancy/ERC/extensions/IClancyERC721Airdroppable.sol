// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

contract IClancyERC721Airdroppable {
    error AirdropRecipientCannotBeZero();
    error AirdropTokenCountCannotBeLTOne();

    struct Airdrop {
        address recipient;
        uint64 tokenCount;
    }

    struct Airdropped {
        address recipient;
        uint64[] tokenIds;
    }

    event AirdropDelivered(Airdropped[] indexed);
}
