// SPDX-License-Identifier: None
pragma solidity ^0.8.19;

import {IClancyERC20, ClancyERC20} from "clancy/ERC/ERC20/ClancyERC20.sol";
import {IClancyERC20Airdrop} from "clancy/ERC/ERC20/utils/IClancyERC20Airdrop.sol";

import {Titan} from "test-helpers/Titan/Titan.sol";

import {ClancyERC20TestHelpers} from "test-helpers//ClancyERC20TestHelpers.sol";

abstract contract IClancyERC20Airdrop_Test is
    IClancyERC20,
    IClancyERC20Airdrop,
    ClancyERC20TestHelpers,
    Titan
{}
