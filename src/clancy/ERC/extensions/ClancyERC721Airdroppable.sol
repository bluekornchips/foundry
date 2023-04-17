// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Counters} from "openzeppelin-contracts/contracts/utils/Counters.sol";

import {ClancyERC721} from "clancy/ERC/ClancyERC721.sol";
import {IClancyERC721Airdroppable} from "./IClancyERC721Airdroppable.sol";

contract ClancyERC721Airdroppable is IClancyERC721Airdroppable, ClancyERC721 {
    using Counters for Counters.Counter;

    /// @dev A counter for tracking the token ID
    Counters.Counter internal _airDropCounter;

    /**
     * @notice Constructor to initialize the ClancyERC721Airdroppable contract
     * @param name_ The name of the ERC721 token
     * @param symbol_ The symbol of the ERC721 token
     * @param max_supply_ The maximum supply of ERC721 tokens
     * @param baseURILocal_ The base URI for the metadata of the ERC721 tokens
     */
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 max_supply_,
        string memory baseURILocal_
    ) ClancyERC721(name_, symbol_, max_supply_, baseURILocal_) {}

    /**
     * @notice Mints and distributes ERC721 tokens as airdrops to the specified recipients
     * @dev Can only be called by the owner of the contract
     * @param airdrops_ An array of Airdrop structs containing the recipient address and token count
     */
    function deliverDrop(Airdrop[] memory airdrops_) public onlyOwner {
        // Check that the amount of tokens to be minted is not greater than the max supply
        uint256 tokenCount = 0;
        for (uint256 i = 0; i < airdrops_.length; i++) {
            tokenCount += airdrops_[i].tokenCount;
            if (tokenCount > _maxSupply) revert MaxSupply_Reached();
            if (airdrops_[i].recipient == address(0))
                revert AirdropRecipientCannotBeZero();
            if (airdrops_[i].tokenCount < 1)
                revert AirdropTokenCountCannotBeLTOne();
        }

        Airdropped[] memory airdropped = new Airdropped[](airdrops_.length);
        for (uint256 i = 0; i < airdrops_.length; i++) {
            Airdrop memory airdrop = airdrops_[i];

            airdropped[i].recipient = airdrop.recipient;
            airdropped[i].tokenIds = new uint64[](airdrop.tokenCount);

            for (uint256 j = 0; j < airdrop.tokenCount; j++) {
                uint256 tokenId = clancyMint(airdrop.recipient);
                airdropped[i].tokenIds[j] = (uint64(tokenId));
            }
        }
        _airDropCounter.increment();
        emit AirdropDelivered(uint8(_airDropCounter.current()), airdropped);
    }

    function getAirdropCount() public view returns (uint8) {
        return uint8(_airDropCounter.current());
    }
}
