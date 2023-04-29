// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";

import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";

import {IClancyERC721, ClancyERC721} from "clancy/ERC/ERC721/ClancyERC721.sol";

import {IClancyERC721_Test} from "./IClancyERC721.t.sol";

contract ClancyERC721_Test is Test, IClancyERC721_Test {
    using Strings for uint256;

    ClancyERC721 public clancyERC721;

    function setUp() public {
        clancyERC721 = new ClancyERC721(NAME, SYMBOL, MAX_SUPPLY, BASE_URI);
    }

    function test_get_token_id_counter() public {
        uint32 tokenIdCounter = clancyERC721.tokenIdCounter();
        assertEq(tokenIdCounter, 0);
    }

    function test_InheritedContractChangestokenIdCounter() public {
        clancyERC721.setPublicMintEnabled(true);
        clancyERC721.tokenIdCounter();
    }

    //#region Max Supply
    function test_maxSupply() public {
        uint256 maxSupply = clancyERC721.maxSupply();
        assertEq(maxSupply, 100);
    }

    function testFuzz_SetMaxSupply(uint32 amount) public {
        uint32 existingMaxSupply = clancyERC721.maxSupply();
        uint256 currentSupply = clancyERC721.totalSupply();
        uint32 ceiling = clancyERC721.SUPPLY_CEILING();

        // A negative amount, should revert.
        if (amount < 0) {
            vm.expectRevert(IClancyERC721.MaxSupply_Invalid.selector);
            clancyERC721.setMaxSupply(amount);

            uint32 postMaxSupply = clancyERC721.maxSupply();
            assertEq(existingMaxSupply, postMaxSupply);
        }
        // Less than the existing max supply, and less than the current supply, should revert.
        else if (amount < existingMaxSupply && amount < currentSupply) {
            vm.expectRevert(IClancyERC721.MaxSupply_Invalid.selector);
            clancyERC721.setMaxSupply(amount);

            uint32 postMaxSupply = clancyERC721.maxSupply();
            assertEq(existingMaxSupply, postMaxSupply);
        }
        // Greater than the existing max supply and less than ceiling, should pass.
        else if (amount > existingMaxSupply && amount <= ceiling) {
            clancyERC721.setMaxSupply(amount);
            uint32 postMaxSupply = clancyERC721.maxSupply();
            assertEq(amount, postMaxSupply);
        }
        // Greater than the ceiling, should revert.
        else if (amount > ceiling) {
            vm.expectRevert(IClancyERC721.MaxSupply_Invalid.selector);
            clancyERC721.setMaxSupply(amount);

            uint32 postMaxSupply = clancyERC721.maxSupply();
            assertEq(existingMaxSupply, postMaxSupply);
        }
        // Greater than 0 and less than the current supply, should revert.
        else if (amount > 0 && amount < currentSupply) {
            vm.expectRevert(IClancyERC721.MaxSupply_Invalid.selector);
            clancyERC721.setMaxSupply(amount);
            uint32 postMaxSupply = clancyERC721.maxSupply();
            assertEq(existingMaxSupply, postMaxSupply);
        }
        // Equal to zero, should revert.
        else if (amount == 0) {
            vm.expectRevert(IClancyERC721.MaxSupply_Invalid.selector);
            clancyERC721.setMaxSupply(amount);
            uint32 postMaxSupply = clancyERC721.maxSupply();
            assertEq(existingMaxSupply, postMaxSupply);
        } else {
            clancyERC721.setMaxSupply(amount);
            uint32 postMaxSupply = clancyERC721.maxSupply();
            assertEq(amount, postMaxSupply);
        }
    }

    function test_setMaxSupply() public {
        uint32 test_max_supply = 200;

        vm.expectEmit(true, false, false, false, address(clancyERC721));
        emit MaxSupplyChanged(test_max_supply);
        clancyERC721.setMaxSupply(test_max_supply);

        uint32 maxSupply = clancyERC721.maxSupply();
        console.log("maxSupply: %s", uint256(maxSupply).toString());
        assertEq(maxSupply, test_max_supply);
    }

    //#endregion

    //#region URI

    function testFuzz_SetBaseURI(string memory uri) public {
        string memory preBaseURI = clancyERC721.baseURI();
        vm.expectEmit(true, false, false, false);
        emit BaseURIChanged(uri);
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

    //#region setPublicMintEnabled
    function test_setPublicMintEnabled() public {
        bool prepublicMintEnabled = clancyERC721.publicMintEnabled();
        assertEq(prepublicMintEnabled, false);

        clancyERC721.setPublicMintEnabled(true);
        bool postpublicMintEnabled = clancyERC721.publicMintEnabled();
        assertEq(postpublicMintEnabled, true);
    }

    function test_setPublicMintEnabled_asNonOwner() public {
        vm.prank(address(clancyERC721));
        vm.expectRevert("Ownable: caller is not the owner");
        clancyERC721.setPublicMintEnabled(true);
    }

    //#endregion

    //#region mint
    function test_mint_whenPublicMintIsDisabled_andNotPaused() public {
        vm.expectRevert(
            abi.encodeWithSelector(IClancyERC721.PublicMintDisabled.selector)
        );
        clancyERC721.mint();
    }

    function test_mint_whenPublicMintIsEnabled_andPaused() public {
        clancyERC721.pause();
        clancyERC721.setPublicMintEnabled(true);
        vm.expectRevert("Pausable: paused");
        clancyERC721.mint();
    }

    function test_mint_1() public {
        clancyERC721.setPublicMintEnabled(true);
        uint256 tokenId = clancyERC721.mint();
        assertEq(tokenId, 1);
    }

    // function test_mint_100() public {
    //     clancyERC721.setPublicMintEnabled(true);
    //     uint256 totalSupply = clancyERC721.totalSupply();
    //     assertEq(totalSupply, 0);
    //     for (uint256 i; i < 100; i++) {
    //         clancyERC721.mint();
    //         uint256 tokenId = clancyERC721.tokenIdCounter();
    //         string memory tokenURI = clancyERC721.tokenURI(i + 1);
    //         string memory expectedTokenURI = string(
    //             abi.encodePacked(BASE_URI, tokenId.toString())
    //         );
    //         assertEq(tokenURI, expectedTokenURI);
    //     }
    //     totalSupply = clancyERC721.totalSupply();
    //     assertEq(totalSupply, 100);
    // }

    // function test_mint_101() public {
    //     clancyERC721.setPublicMintEnabled(true);
    //     uint256 totalSupply = clancyERC721.totalSupply();
    //     assertEq(totalSupply, 0);
    //     for (uint256 i; i < 100; i++) {
    //         clancyERC721.mint();
    //     }
    //     totalSupply = clancyERC721.totalSupply();
    //     assertEq(totalSupply, 100);
    //     vm.expectRevert(
    //         abi.encodeWithSelector(IClancyERC721.MaxSupply_Invalid.selector)
    //     );
    //     clancyERC721.mint();
    // }

    // function test_mint_supplyCeiling() public {
    //     clancyERC721.setPublicMintEnabled(true);
    //     uint256 ceiling = clancyERC721.SUPPLY_CEILING();
    //     clancyERC721.setMaxSupply(uint256(ceiling));
    //     assertEq(ceiling, 1_000_000);
    //     for (uint256 i; i < ceiling; i++) {
    //         clancyERC721.mint();
    //     }
    //     uint256 totalSupply = clancyERC721.totalSupply();
    //     assertEq(totalSupply, ceiling);
    //     vm.expectRevert("ClancyERC721: Max supply reached.");
    //     clancyERC721.mint();
    // }

    //#endregion

    //#region burn status

    function test_burnEnabled() public {
        bool burnStatus = clancyERC721.burnEnabled();
        assertEq(burnStatus, false);
    }

    function test_setBurnEnabled() public {
        bool preBurnStatus = clancyERC721.burnEnabled();
        assertEq(preBurnStatus, false);

        clancyERC721.setBurnEnabled(true);
        bool postBurnStatus = clancyERC721.burnEnabled();
        assertEq(postBurnStatus, true);
    }

    function test_setBurnEnabled_AsNonOwner() public {
        vm.prank(address(clancyERC721));
        vm.expectRevert("Ownable: caller is not the owner");
        clancyERC721.setBurnEnabled(true);
    }

    //#endregion

    //#region burn

    function test_burn_whenBurnIsDisabled() public {
        vm.expectRevert(
            abi.encodeWithSelector(IClancyERC721.BurnDisabled.selector)
        );
        clancyERC721.burn(1);
    }

    function test_burn_whenBurnIsEnabled_andPaused() public {
        clancyERC721.setBurnEnabled(true);
        clancyERC721.pause();
        vm.expectRevert("Pausable: paused");
        clancyERC721.burn(1);
    }

    function test_burn_whenBurnIsEnabled() public {
        clancyERC721.setBurnEnabled(true);
        clancyERC721.setPublicMintEnabled(true);
        clancyERC721.mint();

        uint256 totalSupply = clancyERC721.totalSupply();
        uint256 token_id_counter = clancyERC721.tokenIdCounter();
        assertEq(totalSupply, 1);
        assertEq(token_id_counter, 1);

        clancyERC721.burn(1);
        token_id_counter = clancyERC721.tokenIdCounter();
        totalSupply = clancyERC721.totalSupply();
        assertEq(totalSupply, 0);
        assertEq(token_id_counter, 1);
    }

    function test_burn_AnotherAccountsToken() public {
        clancyERC721.setBurnEnabled(true);
        clancyERC721.setPublicMintEnabled(true);
        clancyERC721.mint();

        uint256 totalSupply = clancyERC721.totalSupply();
        uint256 token_id_counter = clancyERC721.tokenIdCounter();
        assertEq(totalSupply, 1);
        assertEq(token_id_counter, 1);

        vm.prank(address(clancyERC721));
        vm.expectRevert(
            abi.encodeWithSelector(IClancyERC721.NotApprovedOrOwner.selector)
        );
        clancyERC721.burn(1);
    }

    // function test_burn_100Tokens() public {
    //     clancyERC721.setBurnEnabled(true);
    //     clancyERC721.setPublicMintEnabled(true);
    //     for (uint256 i; i < 100; i++) {
    //         clancyERC721.mint();
    //     }

    //     uint256 totalSupply = clancyERC721.totalSupply();
    //     uint256 token_id_counter = clancyERC721.tokenIdCounter();
    //     assertEq(totalSupply, 100);
    //     assertEq(token_id_counter, 100);

    //     for (uint256 i; i < 100; i++) {
    //         clancyERC721.burn(i + 1);
    //     }

    //     token_id_counter = clancyERC721.tokenIdCounter();
    //     totalSupply = clancyERC721.totalSupply();
    //     assertEq(totalSupply, 0);
    //     assertEq(token_id_counter, 100);
    // }

    //#endregion

    //#region balanceOf

    function test_balanceOf() public {
        clancyERC721.setPublicMintEnabled(true);
        clancyERC721.mint();
        uint256 balance = clancyERC721.balanceOf(address(this));
        assertEq(balance, 1);
    }

    function test_balanceOf_afterTransfer() public {
        clancyERC721.setPublicMintEnabled(true);
        clancyERC721.mint();
        clancyERC721.safeTransferFrom(address(this), w_main, 1);
        uint256 balance = clancyERC721.balanceOf(address(this));
        assertEq(balance, 0);
    }

    //#endregion

    //#region delegate calls

    function test_delegateCall() public {
        (bool success, bytes memory result) = address(clancyERC721)
            .delegatecall(abi.encodeWithSignature("burnEnabled()"));
        require(success, "Delegate call failed");
        bool myResult = abi.decode(result, (bool));
        console.log("myResult %s", myResult);
    }

    //#endregion
    //#region safeTransferFrom

    function test_safeTransferFrom() public {
        clancyERC721.setPublicMintEnabled(true);
        clancyERC721.mint();
        clancyERC721.safeTransferFrom(address(this), w_main, 1);
        uint256 balance = clancyERC721.balanceOf(w_main);
        assertEq(balance, 1);
    }

    function test_safeTransferFrom_MintOneThensafeTransferFrom_CircuitTest()
        public
    {
        clancyERC721.setPublicMintEnabled(true);
        clancyERC721.mint();
        clancyERC721.safeTransferFrom(address(this), w_main, 1);

        // Should not transfer
        vm.expectRevert("ERC721: caller is not token owner or approved");
        clancyERC721.safeTransferFrom(address(this), w_main, 1);

        // Should not transfer as token was already
        vm.expectRevert("ERC721: caller is not token owner or approved");
        clancyERC721.safeTransferFrom(address(this), w_main, 1);

        // Connect as a non-owner, should not be able to transfer
        vm.prank(address(0x1));
        vm.expectRevert("ERC721: caller is not token owner or approved");
        clancyERC721.safeTransferFrom(w_main, address(this), 1);
    }

    function test_safeTransferFrom_asApprovedOrOwner() public {
        clancyERC721.setPublicMintEnabled(true);
        clancyERC721.mint();
        clancyERC721.approve(w_main, 1);
        clancyERC721.safeTransferFrom(address(this), w_main, 1);
        uint256 balance = clancyERC721.balanceOf(w_main);
        assertEq(balance, 1);
    }

    function test_safeTransferFrom_asApprovedOrOwnerForNonApprovedToken()
        public
    {
        clancyERC721.setPublicMintEnabled(true);
        clancyERC721.mint();
        clancyERC721.mint();
        clancyERC721.approve(w_main, 1);
        vm.prank(w_main);
        vm.expectRevert("ERC721: caller is not token owner or approved");
        clancyERC721.safeTransferFrom(address(this), w_main, 2);
    }

    //#endregion
}
