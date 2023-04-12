// SPDX-License-Identifier: None
pragma solidity ^0.8.19;

import {TEST_CONSTANTS} from "test-helpers//TEST_CONSTANTS.sol";
import {ClancyERC721TestHelpers} from "test-helpers//ClancyERC721TestHelpers.sol";
import {IOffersERC721_v1} from "clancy/marketplace/offers/OffersERC721_v1.sol";

abstract contract IOffersERC721_v1_Test is
    ClancyERC721TestHelpers,
    TEST_CONSTANTS,
    IOffersERC721_v1
{}
