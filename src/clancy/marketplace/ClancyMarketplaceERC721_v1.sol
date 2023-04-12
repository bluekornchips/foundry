// SPDX-License-Identifier: None
pragma solidity ^0.8.19;

import {Counters} from "openzeppelin-contracts/contracts/utils/Counters.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {Pausable} from "openzeppelin-contracts/contracts/security/Pausable.sol";
import {ReentrancyGuard} from "openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";
import {IERC721Receiver} from "openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";
import {ERC165Checker} from "openzeppelin-contracts/contracts/utils/introspection/ERC165Checker.sol";

import {IClancyMarketplaceERC721_v1} from "./IClancyMarketplaceERC721_v1.sol";

abstract contract ClancyMarketplaceERC721_v1 is
    IClancyMarketplaceERC721_v1,
    IERC721Receiver,
    Ownable,
    Pausable,
    ReentrancyGuard
{
    using Counters for Counters.Counter;

    /**
     * @dev Counter to keep track of item IDs
     */
    Counters.Counter internal _itemIdCounter;

    /**
     * @dev Mapping of token contract addresses to booleans indicating whether the contract is allowed or not
     */
    mapping(address => bool) internal _contracts;

    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual returns (bytes4) {
        return this.onERC721Received.selector;
    }

    /**
     * @dev Retrieves the current value of the item ID counter.
     * @return Returns the current value of the item ID counter as a uint256.
     */
    function getItemIdCounter() public view returns (uint256) {
        return _itemIdCounter.current();
    }

    /**
     * @dev Pauses the contract.
     *
     * Requirements:
     * - The contract must not already be paused.
     * - Can only be called by the owner of the contract.
     */
    function pause() public onlyOwner {
        _pause();
    }

    /**
     * @dev Unpauses the contract.
     *
     * Requirements:
     * - The contract must be paused.
     * - Can only be called by the owner of the contract.
     */
    function unpause() public onlyOwner {
        _unpause();
    }

    /**
     * @dev Allows the owner to set whether a particular token contract is allowed to participate in the marketplace.
     * @param tokenContract The address of the token contract to set the allowed status for.
     * @param allowed The allowed status to set for the token contract.
     *
     * Requirements:
     * - Only the owner can call this function.
     * - The token contract must implement the ERC721 standard.
     */
    function setAllowedContract(
        address tokenContract,
        bool allowed
    ) public onlyOwner {
        if (!ERC165Checker.supportsERC165(tokenContract))
            revert InputContractInvalid();
        _contracts[tokenContract] = allowed;
    }

    /**
     * @dev Returns whether a particular token contract is allowed to participate in the marketplace.
     * @param tokenContract The address of the token contract to get the allowed status for.
     * @return A boolean indicating whether the token contract is allowed to participate in the marketplace.
     */
    function getAllowedContract(
        address tokenContract
    ) public view returns (bool) {
        return _contracts[tokenContract];
    }
}
