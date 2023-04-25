// SPDX-License-Identifier: None
pragma solidity ^0.8.19;

import {Address} from "openzeppelin-contracts/contracts/utils/Address.sol";

import {ClancyERC721Airdroppable} from "clancy/ERC/ERC721/extensions/ClancyERC721Airdroppable.sol";

import {IReels} from "./IReels.sol";

contract Reels is IReels, ClancyERC721Airdroppable {
    using Address for address;

    mapping(address => bool) internal _caseContracts;

    /**
     * @dev Modifier to allow only calls from a Case contract.
     *
     * Requirements:
     * - The caller must be a Case contract.
     */
    modifier onlyCaseContract() {
        if (!_caseContracts[_msgSender()]) revert NotCaseContract();
        _;
    }

    constructor(
        string memory name_,
        string memory symbol_,
        uint32 max_supply_,
        string memory base_uri_
    ) ClancyERC721Airdroppable(name_, symbol_, max_supply_, base_uri_) {}

    /**
     * @dev Sets the validity of a Case contract.
     *
     * Requirements:
     * - The Case contract address cannot be the zero address.
     * - The address provided must be a contract address.
     * - Can only be called by the owner of the contract.
     *
     * @param caseContract The address of the Case contract to set.
     * @param isValid A boolean value indicating the validity of the Case contract.
     */
    function setCaseContract(
        address caseContract,
        bool isValid
    ) public onlyOwner {
        if (caseContract == address(0)) revert CaseContractInvalid();
        if (!caseContract.isContract()) revert CaseContractInvalid();
        _caseContracts[caseContract] = isValid;
        emit CaseContractSet(caseContract, isValid);
    }

    /**
     * @dev Checks if an address is a Case contract.
     *
     * @param caseContract The address to check.
     * @return True if the address is a Case contract, false otherwise.
     */
    function isCaseContract(address caseContract) public view returns (bool) {
        return _caseContracts[caseContract];
    }

    /**
     * @dev Mints a new Series 1 case.
     *
     * Requirements:
     * - The contract must not be paused.
     * - The function can only be called by the Case contract.
     * - Is NOT user callable. This is for owner intervention.
     * @return The ID of the token that was minted.
     */
    function mint() public override whenNotPaused onlyOwner returns (uint32) {
        return super.mint();
    }

    /**
     * @notice Mints a new ERC721 token to the specified `to` address
     * @dev Can only be called when contract is not paused and by the case contract
     * @param to The address to mint the token to
     * @return tokenId The ID of the newly minted token
     */
    function mintTo(
        address to
    ) public whenNotPaused onlyCaseContract returns (uint32) {
        return clancyMint(to);
    }
}
