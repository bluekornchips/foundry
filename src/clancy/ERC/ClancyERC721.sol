// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "openzeppelin-contracts/contracts/utils/Counters.sol";
import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "openzeppelin-contracts/contracts/security/Pausable.sol";
import "openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";
import "clancy/utils/ClancyPayable.sol";
import "./IClancyERC721.sol";

error PublicMintDisabled(string message);
error BurnDisabled(string message);
error NotApprovedOrOwner(string message);
error MaxSupply(string message);

contract ClancyERC721 is
    ClancyPayable,
    ERC721Enumerable,
    Pausable,
    IClancyERC721,
    IERC721Receiver
{
    using Counters for Counters.Counter;

    Counters.Counter internal _tokenIdCounter;
    string internal _baseURILocal;
    uint96 internal _maxSupply;
    uint96 public constant SUPPLY_CEILING = 1_000_000;
    bool private _publicMintStatus = false;
    bool private _burnEnabled = false;

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
        _maxSupply = max_supply_;
        _baseURILocal = baseURILocal_;
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
    function mint() public virtual override returns (uint96) {
        if (!_publicMintStatus)
            revert PublicMintDisabled({
                message: "ClancyERC721: Public minting is disabled."
            });
        return uint96(clancyMint(_msgSender()));
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
        _burnEnabled = status;
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
        if (!_burnEnabled)
            revert BurnDisabled({
                message: "ClancyERC721: Burning is disabled."
            });
        if (!_isApprovedOrOwner(_msgSender(), tokenId))
            revert NotApprovedOrOwner({
                message: "ClancyERC721: caller is not token owner or approved"
            });
        _burn(tokenId);
    }

    /**
     * @dev Returns the burn status of the contract.
     *
     * @return A boolean indicating whether or not burning is currently enabled.
     */
    function getBurnStatus() public view returns (bool) {
        return _burnEnabled;
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
        _publicMintStatus = status;
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
     * @param increasedSupply The new maximum supply.
     */
    function setMaxSupply(uint96 increasedSupply) public onlyOwner {
        if (increasedSupply <= 0)
            revert MaxSupply({
                message: "ClancyERC721: max supply must be greater than 0."
            });
        if (increasedSupply <= _maxSupply)
            revert MaxSupply({
                message: "ClancyERC721: max supply cannot be decreased."
            });
        if (increasedSupply > SUPPLY_CEILING)
            revert MaxSupply({
                message: "ClancyERC721: max supply cannot exceed supply ceiling."
            });

        _maxSupply = increasedSupply;

        emit MaxSupplyChanged(increasedSupply);
    }

    /**
     * @dev Sets the base URI for the Clancy ERC721 token metadata.
     *
     * Requirements:
     * - The caller must be the owner of the contract.
     *
     * Emits a {BaseURIChanged} event indicating the updated base URI.
     *
     * @param baseURI_ The new base URI for the token metadata.
     */
    function setBaseURI(string calldata baseURI_) public onlyOwner {
        string memory existingBaseURI = _baseURILocal;
        _baseURILocal = baseURI_;
        emit BaseURIChanged(existingBaseURI, _baseURILocal);
    }

    /**
     * @dev Returns the public mint status of this contract.
     * @return A boolean indicating whether public minting is currently enabled or disabled.
     */
    function getPublicMintStatus() public view returns (bool) {
        return _publicMintStatus;
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
        return _maxSupply;
    }

    /**
     * @dev Returns the base URI for this contract.
     * @return A string representing the base URI.
     */
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseURILocal;
    }

    /**
     * @dev Returns the total number of tokens in existence.
     *      Burned tokens will not reduce this number, it will only increase.
     * @return uint256 representing the total number of tokens in existence.
     */
    function getTokenIdCounter() public view returns (uint256) {
        return _tokenIdCounter.current();
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
        if (_tokenIdCounter.current() >= _maxSupply) {
            revert MaxSupply({message: "ClancyERC721: Max supply reached."});
        }
        _tokenIdCounter.increment();
        tokenId = _tokenIdCounter.current();
        _safeMint(to, tokenId);
        return tokenId;
    }
}
