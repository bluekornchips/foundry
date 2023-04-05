// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {ERC20Capped} from "openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Capped.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {Pausable} from "openzeppelin-contracts/contracts/security/Pausable.sol";

import {IClancyERC20} from "./IClancyERC20.sol";

contract ClancyERC20 is
    IClancyERC20,
    ERC20,
    ERC20Burnable,
    ERC20Capped,
    Ownable,
    Pausable
{
    /**
     * @notice Constructor to initialize the ClancyERC20 token
     * @param name_ The name of the token
     * @param symbol_ The symbol of the token
     * @param initial_supply_ The initial supply of the token
     * @param cap_ The maximum supply of the token
     */
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 initial_supply_,
        uint256 cap_
    ) ERC20(name_, symbol_) ERC20Capped(cap_) {
        _mint(msg.sender, initial_supply_);
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
     * @notice Mints `amount` tokens to the caller
     * @dev Can only be called when contract is not paused
     * @param amount The amount of tokens to be minted
     */
    function mint(uint256 amount) public virtual override whenNotPaused {
        clancyMint(_msgSender(), amount);
    }

    /**
     * @notice Mints `amount` tokens to the specified `to` address
     * @dev Can only be called by the owner of the contract
     * @param to The address to mint tokens to
     * @param amount The amount of tokens to be minted
     */
    function mintTo(
        address to,
        uint256 amount
    ) public virtual override onlyOwner {
        clancyMint(to, amount);
    }

    /**
     * @notice Internal function to mint `amount` tokens to the specified `to` address
     * @dev Can only be called when contract is not paused and if minting the amount doesn't exceed the cap
     * @param to The address to mint tokens to
     * @param amount The amount of tokens to be minted
     */
    function clancyMint(address to, uint256 amount) internal whenNotPaused {
        if (totalSupply() + amount > cap()) revert Cap_Reached();
        _mint(to, amount);
    }

    function _mint(
        address to,
        uint256 amount
    ) internal virtual override(ERC20, ERC20Capped) {
        ERC20Capped._mint(to, amount);
    }
}
