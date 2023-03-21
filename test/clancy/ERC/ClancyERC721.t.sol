// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "clancy/ERC/ClancyERC721.sol";
import "../helpers/ClancyERC721TestHelpers.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";

contract ClancyERC721_Test is Test, ClancyERC721TestHelpers {
    using Strings for uint256;

    ClancyERC721 public clancyERC721;

    // Events
    event MaxSupplyChanged(uint256 indexed);
    event BaseURIChanged(string indexed, string indexed);
    event BurnStatusChanged(bool indexed);

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
        if (amount < 0) {
            vm.expectRevert(
                abi.encodeWithSelector(
                    MaxSupply.selector,
                    "ClancyERC721: max supply must be greater than 0."
                )
            );
            clancyERC721.setMaxSupply(amount);
            uint96 postMaxSupply = clancyERC721.getMaxSupply();
            assertEq(preMaxSupply, postMaxSupply);
        }
        if (amount < preMaxSupply && amount > 0) {
            vm.expectRevert(
                abi.encodeWithSelector(
                    MaxSupply.selector,
                    "ClancyERC721: max supply cannot be decreased."
                )
            );
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
                abi.encodeWithSelector(
                    MaxSupply.selector,
                    "ClancyERC721: max supply cannot exceed supply ceiling."
                )
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
        vm.expectEmit(true, true, false, false);
        emit BaseURIChanged(preBaseURI, uri);
        clancyERC721.setBaseURI(uri);

        string memory postBaseURI = clancyERC721.baseURI();
        assertEq(postBaseURI, uri);
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
        vm.expectRevert(
            abi.encodeWithSelector(
                PublicMintDisabled.selector,
                "ClancyERC721: Public minting is disabled."
            )
        );
        clancyERC721.mint();
    }

    function test_mint_whenPublicMintIsEnabled_andPaused() public {
        clancyERC721.pause();
        clancyERC721.setPublicMintStatus(true);
        vm.expectRevert("Pausable: paused");
        clancyERC721.mint();
    }

    function test_mint_1() public {
        clancyERC721.setPublicMintStatus(true);
        uint256 tokenId = clancyERC721.mint();
        assertEq(tokenId, 1);
    }

    function test_mint_100() public {
        clancyERC721.setPublicMintStatus(true);
        uint256 totalSupply = clancyERC721.totalSupply();
        assertEq(totalSupply, 0);
        for (uint256 i = 0; i < 100; i++) {
            clancyERC721.mint();
            uint256 tokenId = clancyERC721.getTokenIdCounter();
            string memory tokenURI = clancyERC721.tokenURI(i + 1);
            string memory expectedTokenURI = string(
                abi.encodePacked(BASE_URI, tokenId.toString())
            );
            assertEq(tokenURI, expectedTokenURI);
        }
        totalSupply = clancyERC721.totalSupply();
        assertEq(totalSupply, 100);
    }

    function test_mint_101() public {
        clancyERC721.setPublicMintStatus(true);
        uint256 totalSupply = clancyERC721.totalSupply();
        assertEq(totalSupply, 0);
        for (uint256 i = 0; i < 100; i++) {
            clancyERC721.mint();
        }
        totalSupply = clancyERC721.totalSupply();
        assertEq(totalSupply, 100);
        vm.expectRevert(
            abi.encodeWithSelector(
                MaxSupply.selector,
                "ClancyERC721: Max supply reached."
            )
        );
        clancyERC721.mint();
    }

    // function test_mint_supplyCeiling() public {
    //     clancyERC721.setPublicMintStatus(true);
    //     uint256 ceiling = clancyERC721.SUPPLY_CEILING();
    //     clancyERC721.setMaxSupply(uint96(ceiling));
    //     assertEq(ceiling, 1_000_000);
    //     for (uint256 i = 0; i < ceiling; i++) {
    //         clancyERC721.mint();
    //     }
    //     uint256 totalSupply = clancyERC721.totalSupply();
    //     assertEq(totalSupply, ceiling);
    //     vm.expectRevert("ClancyERC721: Max supply reached.");
    //     clancyERC721.mint();
    // }

    //#endregion

    //#region burn status

    function test_getBurnStatus() public {
        bool burnStatus = clancyERC721.getBurnStatus();
        assertEq(burnStatus, false);
    }

    function test_setBurnStatus() public {
        bool preBurnStatus = clancyERC721.getBurnStatus();
        assertEq(preBurnStatus, false);

        clancyERC721.setBurnStatus(true);
        bool postBurnStatus = clancyERC721.getBurnStatus();
        assertEq(postBurnStatus, true);
    }

    function test_setBurnStatus_AsNonOwner() public {
        vm.prank(address(clancyERC721));
        vm.expectRevert("Ownable: caller is not the owner");
        clancyERC721.setBurnStatus(true);
    }

    //#endregion

    //#region burn

    function test_burn_whenBurnIsDisabled() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                BurnDisabled.selector,
                "ClancyERC721: Burning is disabled."
            )
        );
        clancyERC721.burn(1);
    }

    function test_burn_whenBurnIsEnabled_andPaused() public {
        clancyERC721.setBurnStatus(true);
        clancyERC721.pause();
        vm.expectRevert("Pausable: paused");
        clancyERC721.burn(1);
    }

    function test_burn_whenBurnIsEnabled() public {
        clancyERC721.setBurnStatus(true);
        clancyERC721.setPublicMintStatus(true);
        clancyERC721.mint();

        uint256 totalSupply = clancyERC721.totalSupply();
        uint256 token_id_counter = clancyERC721.getTokenIdCounter();
        assertEq(totalSupply, 1);
        assertEq(token_id_counter, 1);

        clancyERC721.burn(1);
        token_id_counter = clancyERC721.getTokenIdCounter();
        totalSupply = clancyERC721.totalSupply();
        assertEq(totalSupply, 0);
        assertEq(token_id_counter, 1);
    }

    function test_burn_AnotherAccountsToken() public {
        clancyERC721.setBurnStatus(true);
        clancyERC721.setPublicMintStatus(true);
        clancyERC721.mint();

        uint256 totalSupply = clancyERC721.totalSupply();
        uint256 token_id_counter = clancyERC721.getTokenIdCounter();
        assertEq(totalSupply, 1);
        assertEq(token_id_counter, 1);

        vm.prank(address(clancyERC721));
        vm.expectRevert(
            abi.encodeWithSelector(
                NotApprovedOrOwner.selector,
                "ClancyERC721: caller is not token owner or approved"
            )
        );
        clancyERC721.burn(1);
    }

    function test_burn_100Tokens() public {
        clancyERC721.setBurnStatus(true);
        clancyERC721.setPublicMintStatus(true);
        for (uint256 i = 0; i < 100; i++) {
            clancyERC721.mint();
        }

        uint256 totalSupply = clancyERC721.totalSupply();
        uint256 token_id_counter = clancyERC721.getTokenIdCounter();
        assertEq(totalSupply, 100);
        assertEq(token_id_counter, 100);

        for (uint96 i = 0; i < 100; i++) {
            clancyERC721.burn(i + 1);
        }

        token_id_counter = clancyERC721.getTokenIdCounter();
        totalSupply = clancyERC721.totalSupply();
        assertEq(totalSupply, 0);
        assertEq(token_id_counter, 100);
    }

    //#endregion

    //#region balanceOf

    function test_balanceOf() public {
        clancyERC721.setPublicMintStatus(true);
        clancyERC721.mint();
        uint256 balance = clancyERC721.balanceOf(address(this));
        assertEq(balance, 1);
    }

    function test_balanceOf_afterTransfer() public {
        clancyERC721.setPublicMintStatus(true);
        clancyERC721.mint();
        clancyERC721.safeTransferFrom(address(this), DEV_WALLET, 1);
        uint256 balance = clancyERC721.balanceOf(address(this));
        assertEq(balance, 0);
    }

    //#endregion

    //#region safeTransferFrom

    function test_safeTransferFrom() public {
        clancyERC721.setPublicMintStatus(true);
        clancyERC721.mint();
        clancyERC721.safeTransferFrom(address(this), DEV_WALLET, 1);
        uint256 balance = clancyERC721.balanceOf(DEV_WALLET);
        assertEq(balance, 1);
    }

    function test_safeTransferFrom_MintOneThensafeTransferFrom_CircuitTest()
        public
    {
        clancyERC721.setPublicMintStatus(true);
        clancyERC721.mint();
        clancyERC721.safeTransferFrom(address(this), DEV_WALLET, 1);

        // Should not transfer
        vm.expectRevert("ERC721: caller is not token owner or approved");
        clancyERC721.safeTransferFrom(address(this), DEV_WALLET, 1);

        // Should not transfer as token was already
        vm.expectRevert("ERC721: caller is not token owner or approved");
        clancyERC721.safeTransferFrom(address(this), DEV_WALLET, 1);

        // Connect as a non-owner, should not be able to transfer
        vm.prank(address(0x1));
        vm.expectRevert("ERC721: caller is not token owner or approved");
        clancyERC721.safeTransferFrom(DEV_WALLET, address(this), 1);
    }

    function test_safeTransferFrom_asApprovedOrOwner() public {
        clancyERC721.setPublicMintStatus(true);
        clancyERC721.mint();
        clancyERC721.approve(DEV_WALLET, 1);
        clancyERC721.safeTransferFrom(address(this), DEV_WALLET, 1);
        uint256 balance = clancyERC721.balanceOf(DEV_WALLET);
        assertEq(balance, 1);
    }

    function test_safeTransferFrom_asApprovedOrOwnerForNonApprovedToken()
        public
    {
        clancyERC721.setPublicMintStatus(true);
        clancyERC721.mint();
        clancyERC721.mint();
        clancyERC721.approve(DEV_WALLET, 1);
        vm.prank(DEV_WALLET);
        vm.expectRevert("ERC721: caller is not token owner or approved");
        clancyERC721.safeTransferFrom(address(this), DEV_WALLET, 2);
    }
    //#endregion
}
