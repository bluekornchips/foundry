// SPDX-License-Identifier: None
pragma solidity ^0.8.19;

import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {Pausable} from "openzeppelin-contracts/contracts/security/Pausable.sol";
import {ReentrancyGuard} from "openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";
import {IERC721Receiver} from "openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";
import {ERC165Checker} from "openzeppelin-contracts/contracts/utils/introspection/ERC165Checker.sol";

import {IClancyMarketplaceERC721} from "./IClancyMarketplaceERC721.sol";

abstract contract ClancyMarketplaceERC721 is
    Ownable,
    Pausable,
    IERC721Receiver,
    ReentrancyGuard,
    IClancyMarketplaceERC721
{
    /// @dev A counter for tracking the item ID.
    uint32 public itemIdCounter;

    /// @dev A mapping of ERC721 Addresses to their allowed sale status.
    mapping(address => bool) public vendors;

    /// @dev See {IERC721Receiver-onERC721Received}.
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual returns (bytes4) {
        return this.onERC721Received.selector;
    }

    /// @dev See {Pausable-_pause}.
    function pause() public onlyOwner {
        _pause();
    }

    /// @dev See {Pausable-_unpause}.
    function unpause() public onlyOwner {
        _unpause();
    }

    /**
     * @dev Sets the vendor status for a given token contract.
     * @param tokenContract The address of the ERC721 token contract.
     * @param allowed Allowed status.
     *
     * Requirements:
     * - The token contract must implement the ERC721 standard.
     */
    function setVendorStatus(
        address tokenContract,
        bool allowed
    ) public onlyOwner {
        if (!ERC165Checker.supportsERC165(tokenContract)) {
            revert InputContractInvalid();
        }
        vendors[tokenContract] = allowed;
    }
}
