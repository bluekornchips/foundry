// SPDX-License-Identifier: None
pragma solidity ^0.8.19;

import "forge-std/Test.sol";

import {IERC721} from "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

import {IClancyERC721, ClancyERC721} from "clancy/ERC/ClancyERC721.sol";

import {IMarketplaceERC721Offers_v1_Test} from "./IMarketplaceERC721Offers_v1.t.sol";

contract MarketplaceOffersERC721_Test is
    Test,
    IMarketplaceERC721Offers_v1_Test
{
    ClancyERC721 clancyERC721;

    function setUp() public {
        clancyERC721 = new ClancyERC721(NAME, SYMBOL, MAX_SUPPLY, BASE_URI);
    }
}
