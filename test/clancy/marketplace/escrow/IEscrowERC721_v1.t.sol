// SPDX-License-Identifier: None
pragma solidity ^0.8.19;

import {Titan} from "test-helpers/Titan/Titan.sol";
import {ClancyERC721TestHelpers} from "test-helpers//ClancyERC721TestHelpers.sol";
import {IEscrowERC721_v1} from "clancy/marketplace/escrow/IEscrowERC721_v1.sol";

abstract contract IEscrowERC721_v1_Test is
    ClancyERC721TestHelpers,
    IEscrowERC721_v1,
    Titan
{}
