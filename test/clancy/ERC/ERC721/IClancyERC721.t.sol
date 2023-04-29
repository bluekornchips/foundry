// SPDX-License-Identifier: None
pragma solidity ^0.8.19;

import {IClancyERC721, ClancyERC721} from "clancy/ERC/ERC721/ClancyERC721.sol";

import {ClancyERC721TestHelpers} from "test-helpers//ClancyERC721TestHelpers.sol";
import {Titan} from "test-helpers/Titan/Titan.sol";

contract IClancyERC721_Test is ClancyERC721TestHelpers, IClancyERC721, Titan {}
