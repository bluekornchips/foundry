// SPDX-License-Identifier: None
pragma solidity ^0.8.19;

import {Titan} from "test-helpers/Titan/Titan.sol";
import {ClancyERC721TestHelpers} from "test-helpers//ClancyERC721TestHelpers.sol";
import {IOffersERC721} from "clancy/marketplace/offers/OffersERC721.sol";

abstract contract IOffersERC721_Test is
    ClancyERC721TestHelpers,
    Titan,
    IOffersERC721
{}
