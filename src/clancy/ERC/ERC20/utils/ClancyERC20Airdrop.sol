// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {IClancyERC20} from "clancy/ERC/ERC20/IClancyERC20.sol";
import {IClancyERC20Airdrop} from "clancy/ERC/ERC20/utils/IClancyERC20Airdrop.sol";

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract ClancyERC20Airdrop is IClancyERC20Airdrop {
    /**
     *  @dev Limit size to prevent overflow. Uint256 used to prevent overflow if greater than length is
     *       passed in during runtime.
     */
    uint256 public constant MAX_DROPS = type(uint16).max;

    /**
     * @dev  Deliver airdrops to an array of addresses.
     */
    function airdrop(IERC20 token, ERC20Package[] calldata airdrops) external {
        if (airdrops.length < 1 || airdrops.length > MAX_DROPS) {
            revert AirdropLengthInvalid();
        }

        uint16 airdropCount = uint16(airdrops.length);
        uint256 total;
        uint16 index;

        unchecked {
            do {
                if (airdrops[index].value == 0) {
                    revert ZeroBalanceTransfer();
                }
                total += airdrops[index].value;
                ++index;
            } while (index < airdropCount);
        }

        token.transferFrom(msg.sender, address(this), total); // Will revert if not enough tokens

        index = 0;

        unchecked {
            do {
                if (
                    !token.transfer(
                        airdrops[index].recipient,
                        airdrops[index].value
                    )
                ) {
                    revert TransferFailed();
                }
                ++index;
            } while (index < airdropCount);
        }
    }
}
