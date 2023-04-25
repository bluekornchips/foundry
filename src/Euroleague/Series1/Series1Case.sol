// SPDX-License-Identifier: None
pragma solidity ^0.8.19;

import {Address} from "openzeppelin-contracts/contracts/utils/Address.sol";

import {ClancyERC721Airdroppable} from "clancy/ERC/ERC721/extensions/ClancyERC721Airdroppable.sol";

import {Reels} from "./Reels.sol";
import {ISeries1Case} from "./ISeries1Case.sol";

contract Series1Case is ISeries1Case, ClancyERC721Airdroppable {
    using Address for address;

    Reels private _reelsContract;
    uint8 private _reelsPerCase = 3;

    constructor(
        string memory name_,
        string memory symbol_,
        uint32 maxSupply_,
        string memory base_uri_
    ) ClancyERC721Airdroppable(name_, symbol_, maxSupply_, base_uri_) {}

    /**
     * @dev Opens a Series 1 case.
     *  safeTransferForm sends to the ownerOfToken, because using _msgSender() could send
     *  to the approved address burning the token. This is unintended behaviour.
     *
     * Requirements:
     * - The contract must not be paused.
     * - The Reels contract must be set.
     * - The caller must own the specified token.
     * - The token must exist.
     * - Burning of the token must be enabled.
     *
     * Emits a {CaseOpened} event.
     *
     * @param tokenId The ID of the token to open.
     * @return An array of the IDs of the reels that were minted.
     */
    function openCase(
        uint32 tokenId
    ) public whenNotPaused returns (uint32[] memory) {
        if (_reelsContract == Reels(payable(address(0))))
            revert ReelsContractNotSet();
        if (!_isApprovedOrOwner(_msgSender(), tokenId))
            revert NotApprovedOrOwner();

        address tokenOwner = ownerOf(tokenId); // Always mint to the owner, not the caller.

        burn(tokenId);

        uint32[] memory minted_reels = new uint32[](_reelsPerCase);
        for (uint32 i; i < _reelsPerCase; i++) {
            minted_reels[i] = _reelsContract.mintTo(tokenOwner);
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
     * @param reelsContract The address of the Reels contract.
     */
    function setReelsContract(address reelsContract) public onlyOwner {
        if (reelsContract == address(0)) revert ReelsContractNotValid();
        if (!reelsContract.isContract()) revert ReelsContractNotValid();
        _reelsContract = Reels(payable(reelsContract));
    }

    /**
     * @dev Sets the number of reels in a case.
     *
     * Requirements:
     * - The number of reels per case must be greater than zero.
     * - Can only be called by the owner of the contract.
     *
     * @param reelsPerCase The number of reels to set per case.
     */
    function setReelsPerCase(uint8 reelsPerCase) public onlyOwner {
        if (reelsPerCase <= 0) revert ReelsPerCaseNotValid();
        _reelsPerCase = reelsPerCase;
    }

    /**
     * @dev Returns the Reels contract.
     *
     * @return A Reels contract instance.
     */
    function getReelsContract() public view returns (Reels) {
        return _reelsContract;
    }

    /**
     * @dev Returns the number of reels in a case.
     *
     * @return A number representing the number of reels in a case.
     */
    function getReelsPerCase() public view returns (uint8) {
        return _reelsPerCase;
    }
}
