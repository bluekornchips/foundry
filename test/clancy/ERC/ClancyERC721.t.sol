// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "clancy/ERC/ClancyERC721.sol";

contract ClancyERC721_Test is Test {
    ClancyERC721 public clancyERC721;

    string public constant NAME = "ClancyERC721";
    string public constant SYMBOL = "CERC721";
    uint96 public constant MAX_SUPPLY = 100;
    string public constant BASE_URI = "https://clancy.com/";

    receive() external payable {}

    event MaxSupplyChanged(uint256 indexed);
    event BaseURIChanged(string indexed, string indexed);

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function setUp() public {
        clancyERC721 = new ClancyERC721(NAME, SYMBOL, MAX_SUPPLY, BASE_URI);
    }

    function test_get_token_id_counterr() public {
        uint256 tokenIdCounter = clancyERC721.getTokenIdCounter();
        assertEq(tokenIdCounter, 0);
    }

    //#region Max Supply
    function test_getMaxSupply() public {
        uint256 maxSupply = clancyERC721.getMaxSupply();
        assertEq(maxSupply, 100);
    }

    function testFuzz_SetMaxSupply(uint96 amount) public {
        uint96 preMaxSupply = clancyERC721.getMaxSupply();
        uint96 ceiling = clancyERC721.SUPPLY_CEILING();
        if (amount < preMaxSupply) {
            vm.expectRevert("ClancyERC721: max supply cannot be decreased");
            clancyERC721.setMaxSupply(amount);
            uint96 postMaxSupply = clancyERC721.getMaxSupply();
            assertEq(preMaxSupply, postMaxSupply);
        }
        if (amount < 0) {
            vm.expectRevert("ClancyERC721: max supply must be greater than 0");
            clancyERC721.setMaxSupply(amount);
            uint96 postMaxSupply = clancyERC721.getMaxSupply();
            assertEq(preMaxSupply, postMaxSupply);
        }
        if (amount > preMaxSupply && amount <= ceiling) {
            clancyERC721.setMaxSupply(amount);
            uint96 postMaxSupply = clancyERC721.getMaxSupply();
            assertEq(amount, postMaxSupply);
        }
        if (amount > ceiling) {
            vm.expectRevert(
                "ClancyERC721: max supply cannot exceed supply ceiling"
            );
            clancyERC721.setMaxSupply(amount);
            uint256 postMaxSupply = clancyERC721.getMaxSupply();
            assertEq(preMaxSupply, postMaxSupply);
        }
    }

    function test_setMaxSupply() public {
        uint96 test_max_supply = 200;

        vm.expectEmit(true, false, false, false);
        emit MaxSupplyChanged(test_max_supply);
        clancyERC721.setMaxSupply(test_max_supply);

        uint96 maxSupply = clancyERC721.getMaxSupply();
        assertEq(maxSupply, test_max_supply);
    }

    //#endregion

    //#region URI

    function testFuzz_SetBaseURI(string memory uri) public {
        string memory preBaseURI = clancyERC721.baseURI();
        if (bytes(uri).length > 0) {
            vm.expectEmit(true, true, false, false);
            emit BaseURIChanged(preBaseURI, uri);
            clancyERC721.setBaseURI(uri);

            string memory postBaseURI = clancyERC721.baseURI();
            assertEq(postBaseURI, uri);
        }
        if (bytes(uri).length == 0) {
            vm.expectRevert("ClancyERC721: base URI must not be empty");
            clancyERC721.setBaseURI(uri);
            string memory postBaseURI = clancyERC721.baseURI();
            assertEq(preBaseURI, postBaseURI);
        }
    }

    function test_baseURI() public {
        string memory uri = clancyERC721.baseURI();
        assertEq(uri, BASE_URI);
    }

    function test_setBaseURI_AsNonOwner() public {
        vm.prank(address(clancyERC721));
        vm.expectRevert("Ownable: caller is not the owner");
        clancyERC721.setBaseURI("https://clancy.com/");
    }

    //#endregion

    //#region setPublicMintStatus
    function test_setPublicMintStatus() public {
        bool prePublicMintStatus = clancyERC721.getPublicMintStatus();
        assertEq(prePublicMintStatus, false);

        clancyERC721.setPublicMintStatus(true);
        bool postPublicMintStatus = clancyERC721.getPublicMintStatus();
        assertEq(postPublicMintStatus, true);
    }

    function test_setPublicMintStatus_asNonOwner() public {
        vm.prank(address(clancyERC721));
        vm.expectRevert("Ownable: caller is not the owner");
        clancyERC721.setPublicMintStatus(true);
    }

    //#endregion

    //#region mint
    function test_mint_whenPublicMintIsDisabled_andNotPaused() public {
        vm.expectRevert("ClancyERC721: Public minting is disabled");
        clancyERC721.mint();
    }

    function test_mint_whenPublicMintIsEnabled_andPaused() public {
        clancyERC721.pause();
        clancyERC721.setPublicMintStatus(true);
        vm.expectRevert("Pausable: paused");
        clancyERC721.mint();
    }

    function test_mint() public {
        clancyERC721.setPublicMintStatus(true);
        uint256 tokenId = clancyERC721.mint();
        assertEq(tokenId, 1);
    }
}
