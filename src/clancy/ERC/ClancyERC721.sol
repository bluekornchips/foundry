// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "openzeppelin-contracts/contracts/utils/Counters.sol";
import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/contracts/security/Pausable.sol";
import "clancy/utils/ClancyPayable.sol";
import "./IClancyERC721.sol";

contract ClancyERC721 is ClancyPayable, ERC721, Pausable, IClancyERC721 {
    using Counters for Counters.Counter;

    Counters.Counter internal _token_id_counter;
    string internal _base_uri_local;
    uint96 internal _max_supply;
    uint96 public constant SUPPLY_CEILING = 1_000_000;
    bool private _public_mint_status = false;
    bool private _burn_enabled = false;

    // Events
    event MaxSupplyChanged(uint256 indexed);
    event BaseURIChanged(string indexed, string indexed);

    constructor(
        string memory name,
        string memory symbol,
        uint96 max_supply,
        string memory baseURILocal
    ) ERC721(name, symbol) {
        _max_supply = max_supply;
        _base_uri_local = baseURILocal;
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
     * @dev Mints a new token and assigns it to the caller's address.
     *
     * Requirements:
     * - Public minting must be enabled.
     * - The contract must not be paused.
     *
     * @return The id of the newly minted token.
     */
    function mint() public virtual override returns (uint256) {
        require(
            _public_mint_status,
            "ClancyERC721: Public minting is disabled"
        );
        return clancyMint(_msgSender());
    }

    /**
     * @dev Sets the public minting status of the Clancy ERC721 token.
     *
     * Requirements:
     * - The caller must be the owner of the contract.
     *
     * @param status The new public minting status.
     */
    function setPublicMintStatus(bool status) public onlyOwner {
        _public_mint_status = status;
    }

    /**
     * @dev Sets the maximum supply of the Clancy ERC721 token.
     *
     * Requirements:
     * - The caller must be the owner of the contract.
     * - The increased supply must be greater than 0.
     * - The increased supply must be greater than the current maximum supply.
     * - The increased supply must not exceed the supply ceiling.
     *
     * Emits a {MaxSupplyChanged} event indicating the updated maximum supply.
     *
     * @param increased_supply The new maximum supply.
     */
    function setMaxSupply(uint96 increased_supply) public onlyOwner {
        require(
            increased_supply >= 0,
            "ClancyERC721: max supply must be greater than 0"
        );
        require(
            increased_supply > _max_supply,
            "ClancyERC721: max supply cannot be decreased"
        );
        require(
            increased_supply <= SUPPLY_CEILING,
            "ClancyERC721: max supply cannot exceed supply ceiling"
        );

        _max_supply = increased_supply;

        emit MaxSupplyChanged(increased_supply);
    }

    /**
     * @dev Sets the base URI for the Clancy ERC721 token metadata.
     *
     * Requirements:
     * - The caller must be the owner of the contract.
     * - The base URI string must not be empty.
     *
     * Emits a {BaseURIChanged} event indicating the updated base URI.
     *
     * @param base_uri_ The new base URI for the token metadata.
     */
    function setBaseURI(string calldata base_uri_) public onlyOwner {
        require(
            bytes(base_uri_).length > 0,
            "ClancyERC721: base URI must not be empty"
        );
        string memory existing_base_uri = _base_uri_local;
        _base_uri_local = base_uri_;
        emit BaseURIChanged(existing_base_uri, _base_uri_local);
    }

    /**
     * @dev Returns the public mint status of this contract.
     * @return A boolean indicating whether public minting is currently enabled or disabled.
     */
    function getPublicMintStatus() public view returns (bool) {
        return _public_mint_status;
    }

    /**
     * @dev Returns the base URI for all tokens.
     * @return A string representing the base URI.
     */
    function baseURI() public view returns (string memory) {
        return _baseURI();
    }

    /**
     * @dev Returns the maximum supply for this token.
     * @return An unsigned integer representing the maximum supply.
     */
    function getMaxSupply() public view returns (uint96) {
        return _max_supply;
    }

    /**
     * @dev Returns the base URI for this contract.
     * @return A string representing the base URI.
     */
    function _baseURI() internal view override returns (string memory) {
        return _base_uri_local;
    }

    /**
     * @dev Returns the total number of tokens in existence.
     *      Burned tokens will not reduce this number, it will only increase.
     * @return uint256 representing the total number of tokens in existence.
     */
    function getTokenIdCounter() public view returns (uint256) {
        return _token_id_counter.current();
    }

    /**
     * @dev Mints a new Clancy ERC721 token and assigns it to the specified address.
     *
     * Requirements:
     * - The contract must not be paused.
     * - The maximum supply has not been reached.
     *
     * @param to The address to assign the newly minted token to.
     * @return tokenId - The ID of the newly minted token.
     */
    function clancyMint(
        address to
    ) internal whenNotPaused returns (uint256 tokenId) {
        require(
            _token_id_counter.current() < _max_supply,
            "ClancyERC721: Max supply reached."
        );
        _token_id_counter.increment();
        tokenId = _token_id_counter.current();
        _safeMint(to, tokenId);
        return tokenId;
    }
}
