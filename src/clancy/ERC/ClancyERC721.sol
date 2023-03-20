// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "openzeppelin-contracts/contracts/utils/Counters.sol";
import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "openzeppelin-contracts/contracts/security/Pausable.sol";
import "openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";
import "clancy/utils/ClancyPayable.sol";
import "./IClancyERC721.sol";

contract ClancyERC721 is
    ClancyPayable,
    ERC721Enumerable,
    Pausable,
    IClancyERC721,
    IERC721Receiver
{
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
    event BurnStatusChanged(bool indexed);

    constructor(
        string memory name_,
        string memory symbol_,
        uint96 max_supply_,
        string memory baseURILocal_
    ) ERC721(name_, symbol_) {
        _max_supply = max_supply_;
        _base_uri_local = baseURILocal_;
    }

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
            "ClancyERC721: Public minting is disabled."
        );
        return clancyMint(_msgSender());
    }

    /**
     * @dev Sets the burn status of the contract.
     *
     * Requirements:
     * - Can only be called by the owner of the contract.
     *
     * @param status A boolean indicating whether or not burning is enabled.
     */
    function setBurnStatus(bool status) public onlyOwner {
        _burn_enabled = status;
        emit BurnStatusChanged(status);
    }

    /**
     * @dev Burns a token.
     *
     * Requirements:
     * - Burning must be enabled.
     * - The token must exist.
     * - The caller must either own the token or be approved to burn it.
     * - The contract must not be paused.
     *
     * @param tokenId The ID of the token to be burned.
     */
    function burn(uint96 tokenId) public virtual whenNotPaused {
        require(_burn_enabled, "ClancyERC721: Burning is disabled.");
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ClancyERC721: caller is not token owner or approved"
        );
        _burn(tokenId);
    }

    /**
     * @dev Returns the burn status of the contract.
     *
     * @return A boolean indicating whether or not burning is currently enabled.
     */
    function getBurnStatus() public view returns (bool) {
        return _burn_enabled;
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
            "ClancyERC721: max supply must be greater than 0."
        );
        require(
            increased_supply > _max_supply,
            "ClancyERC721: max supply cannot be decreased."
        );
        require(
            increased_supply <= SUPPLY_CEILING,
            "ClancyERC721: max supply cannot exceed supply ceiling."
        );

        _max_supply = increased_supply;

        emit MaxSupplyChanged(increased_supply);
    }

    /**
     * @dev Sets the base URI for the Clancy ERC721 token metadata.
     *
     * Requirements:
     * - The caller must be the owner of the contract.
     *
     * Emits a {BaseURIChanged} event indicating the updated base URI.
     *
     * @param base_uri_ The new base URI for the token metadata.
     */
    function setBaseURI(string calldata base_uri_) public onlyOwner {
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
    function baseURI() public view virtual returns (string memory) {
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
    function _baseURI() internal view virtual override returns (string memory) {
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
