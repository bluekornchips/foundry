// SPDX-License-Identifier: None
pragma solidity ^0.8.19;

import {Address} from "openzeppelin-contracts/contracts/utils/Address.sol";

import {ClancyERC721Airdroppable} from "clancy/ERC/ERC721/extensions/ClancyERC721Airdroppable.sol";

import {Reels} from "./Reels.sol";
import {ISeries1Case} from "./ISeries1Case.sol";

contract Series1Case is ISeries1Case, ClancyERC721Airdroppable {
    using Address for address;

    Reels public reelsContract;
    uint8 public reelsPerCase = 3;

    constructor(
        string memory name_,
        string memory symbol_,
        uint32 maxSupply_,
        string memory base_uri_
    ) ClancyERC721Airdroppable(name_, symbol_, maxSupply_, base_uri_) {}

    /**
     * @dev Opens a Series 1 case.
     *
     * @param tokenId The ID of the token to open.
     * @return An array of the IDs of the reels that were minted.
     */
    function openCase(
        uint32 tokenId
    ) public whenNotPaused returns (uint32[] memory) {
        if (reelsContract == Reels(payable(address(0)))) {
            revert ReelsContractNotSet();
        }
        if (!_isApprovedOrOwner(_msgSender(), tokenId)) {
            revert NotApprovedOrOwner();
        }

        address tokenOwner = ownerOf(tokenId); // Always mint to the owner, not the caller.

        burn(tokenId);

        uint32[] memory minted_reels = new uint32[](reelsPerCase);

        unchecked {
            uint32 i;
            do {
                minted_reels[i] = reelsContract.mintTo(tokenOwner);
                ++i;
            } while (i < reelsPerCase);
        }

        emit CaseOpened(tokenId, _msgSender());

        return minted_reels;
    }

    /**
     * @dev Sets the Reels contract instance.
     *
     * Requirements:
     * - The Reels contract address cannot be the zero address.
     * - The address provided must be a contract address.
     * - Can only be called by the owner of the contract.
     *
     * @param reelsContract_ The address of the Reels contract.
     */
    function setReelsContract(address reelsContract_) public onlyOwner {
        if (reelsContract_ == address(0) || !reelsContract_.isContract()) {
            revert ReelsContractNotValid();
        }
        reelsContract = Reels(payable(reelsContract_));
    }

    /**
     * @dev Sets the number of reels in a case.
     *
     * Requirements:
     * - The number of reels per case must be greater than zero.
     * - Can only be called by the owner of the contract.
     *
     * @param reelsPerCase_ The number of reels to set per case.
     */
    function setReelsPerCase(uint8 reelsPerCase_) public onlyOwner {
        if (reelsPerCase_ < 1) {
            revert ReelsPerCaseNotValid();
        }
        reelsPerCase = reelsPerCase_;
    }
}
