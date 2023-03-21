// SPDX-License-Identifier: None
pragma solidity ^0.8.17;

import "clancy/ERC/ClancyERC721.sol";
import "./Moments.sol";

contract Series1Case is ClancyERC721 {
    using Address for address;

    Moments private _momentsContract;
    uint8 private _momentsPerCase = 3;

    event CaseOpened(uint96 indexed token_id, address indexed case_address);

    error MomentsContractNotSet(string message);
    error MomentsContractNotValid(string message);
    error MomentsPerCaseNotValid(string message);

    constructor(
        string memory name_,
        string memory symbol_,
        uint96 maxSupply,
        string memory base_uri_
    ) ClancyERC721(name_, symbol_, maxSupply, base_uri_) {}

    /**
     * @dev Opens a Series 1 case.
     *  safeTransferForm sends to the ownerOfToken, because using _msgSender() could send
     *  to the approved address burning the token. This is unintended behaviour.
     *
     * Requirements:
     * - The contract must not be paused.
     * - The Moments contract must be set.
     * - The caller must own the specified token.
     * - The token must exist.
     * - Burning of the token must be enabled.
     *
     * Emits a {CaseOpened} event.
     *
     * @param tokenId The ID of the token to open.
     * @return An array of the IDs of the moments that were minted.
     */
    function openCase(
        uint96 tokenId
    ) public whenNotPaused returns (uint96[] memory) {
        if (_momentsContract == Moments(payable(address(0))))
            revert MomentsContractNotSet({message: "Moments contract not set"});

        address ownerOfToken = this.ownerOf(tokenId);

        burn(tokenId);

        uint96[] memory minted_moments = new uint96[](_momentsPerCase);
        for (uint96 i = 0; i < _momentsPerCase; i++) {
            minted_moments[i] = _momentsContract.mint();
            _momentsContract.safeTransferFrom(
                address(this),
                ownerOfToken,
                minted_moments[i]
            );
        }

        emit CaseOpened(tokenId, _msgSender());

        return minted_moments;
    }

    /**
     * @dev Sets the Moments contract instance.
     *
     * Requirements:
     * - The Moments contract address cannot be the zero address.
     * - The address provided must be a contract address.
     * - Can only be called by the owner of the contract.
     *
     * @param momentsContract The address of the Moments contract.
     */
    function setMomentsContract(address momentsContract) public onlyOwner {
        if (momentsContract == address(0))
            revert MomentsContractNotValid({
                message: "Series1Case: Moments contract cannot be the zero address"
            });
        if (!momentsContract.isContract())
            revert MomentsContractNotValid({
                message: "Series1Case: Address is not a contract"
            });
        _momentsContract = Moments(payable(momentsContract));
    }

    /**
     * @dev Sets the number of moments in a case.
     *
     * Requirements:
     * - The number of moments per case must be greater than zero.
     * - Can only be called by the owner of the contract.
     *
     * @param momentsPerCase The number of moments to set per case.
     */
    function setMomentsPerCase(uint8 momentsPerCase) public onlyOwner {
        if (momentsPerCase <= 0)
            revert MomentsPerCaseNotValid({
                message: "Series1Case: Moments per case must be greater than zero"
            });
        _momentsPerCase = momentsPerCase;
    }

    /**
     * @dev Returns the Moments contract.
     *
     * @return A Moments contract instance.
     */
    function getMomentsContract() public view returns (Moments) {
        return _momentsContract;
    }

    /**
     * @dev Returns the number of moments in a case.
     *
     * @return A number representing the number of moments in a case.
     */
    function getMomentsPerCase() public view returns (uint8) {
        return _momentsPerCase;
    }
}
