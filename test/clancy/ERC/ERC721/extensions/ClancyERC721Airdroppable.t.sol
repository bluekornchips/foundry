// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";

import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {Address} from "openzeppelin-contracts/contracts/utils/Address.sol";
import {IERC721Receiver} from "openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";

import {ClancyERC721Airdroppable, IClancyERC721Airdroppable} from "clancy/ERC/ERC721/extensions/ClancyERC721Airdroppable.sol";
import {ClancyERC721TestHelpers} from "test-helpers//ClancyERC721TestHelpers.sol";

import {TEST_CONSTANTS} from "test-helpers//TEST_CONSTANTS.sol";

contract ClancyERC721Airdroppable_Test is
    Test,
    IClancyERC721Airdroppable,
    ClancyERC721TestHelpers,
    TEST_CONSTANTS
{
    using Strings for uint256;
    using Address for address;
    ClancyERC721Airdroppable public clancyERC721Airdroppable;

    function setUp() public {
        clancyERC721Airdroppable = new ClancyERC721Airdroppable(
            NAME,
            SYMBOL,
            1_000_000,
            BASE_URI
        );
    }

    function run() public {
        uint256 PKEY = vm.envUint("DEPLOYMENT_KEY");
        vm.startBroadcast(PKEY);
        setUp();
        test_deliverDrop_ManyAddress_ShouldPass();
        // test_deliverDrop();
        vm.stopBroadcast();
    }

    function test_deliverDrop() public {
        uint8 tokenCount = 1;

        Airdrop[] memory airdrops = new Airdrop[](3);
        airdrops[0] = Airdrop({
            recipient: TEST_WALLET_MAIN,
            tokenCount: tokenCount
        });
        // console.log("airdrop: %s", airdrops[0]);

        airdrops[1] = Airdrop({
            recipient: TEST_WALLET_1,
            tokenCount: tokenCount
        });
        airdrops[2] = Airdrop({
            recipient: address(this),
            tokenCount: tokenCount
        });
        Airdropped[] memory airdropped = new Airdropped[](airdrops.length);
        airdropped[0] = Airdropped({
            recipient: TEST_WALLET_MAIN,
            tokenIds: new uint64[](tokenCount)
        });
        airdropped[0].tokenIds[0] = 1;
        airdropped[1] = Airdropped({
            recipient: TEST_WALLET_1,
            tokenIds: new uint64[](tokenCount)
        });
        airdropped[1].tokenIds[0] = 2;
        airdropped[2] = Airdropped({
            recipient: address(this),
            tokenIds: new uint64[](tokenCount)
        });
        airdropped[2].tokenIds[0] = 3;
        uint8 airDropCounter = clancyERC721Airdroppable.getAirdropCount();
        vm.expectEmit(true, false, false, false);
        emit AirdropDelivered(airDropCounter + 1, airdropped);
        clancyERC721Airdroppable.deliverDrop(airdrops);

        uint256 counter = 1;
        for (uint256 i = 0; i < airdrops.length; i++) {
            Airdrop memory airdrop = airdrops[i];
            for (uint256 j = 0; j < airdrop.tokenCount; j++) {
                assertEq(
                    clancyERC721Airdroppable.ownerOf(counter++),
                    airdrop.recipient
                );
            }
        }
    }

    function test_deliverDrop_ManyAddress_ShouldPass() public {
        uint128 addressCount = 1_000;
        address[] memory tos = new address[](addressCount);
        for (uint256 i = 0; i < addressCount; i++) {
            tos[i] = address(TEST_WALLET_MAIN);
        }

        uint8 tokenCount = 10;

        Airdrop[] memory airdrops = new Airdrop[](tos.length);
        for (uint256 i = 0; i < airdrops.length; i++) {
            airdrops[i] = Airdrop({recipient: tos[i], tokenCount: tokenCount});
        }

        //Count up how many tokens are to be minted
        uint256 totalTokens = 0;
        for (uint256 i = 0; i < airdrops.length; i++) {
            totalTokens += airdrops[i].tokenCount;
        }

        console.log("totalTokens: %s", totalTokens);
        clancyERC721Airdroppable.setMaxSupply(totalTokens);

        clancyERC721Airdroppable.deliverDrop(airdrops);

        uint256 counter = 1;
        for (uint256 i = 0; i < airdrops.length; i++) {
            Airdrop memory airdrop = airdrops[i];
            for (uint256 j = 0; j < airdrop.tokenCount; j++) {
                assertEq(
                    clancyERC721Airdroppable.ownerOf(counter++),
                    airdrop.recipient
                );
            }
        }
    }

    function testFuzz_deliverDrop(address[] calldata tos) public {
        vm.assume(tos.length > 100);
        // vm.assume(tos.length <= 100);

        // Assume each address is not the zero address
        for (uint256 i = 0; i < tos.length; i++) {
            vm.assume(tos[i] != address(0));
            // Assume each address implements the IERC721Receiver interface
            vm.assume(
                IERC721Receiver(tos[i]).onERC721Received.selector != bytes4(0)
            );
            vm.assume(!tos[i].isContract());
        }

        uint8 tokenCount = 1;

        Airdrop[] memory airdrops = new Airdrop[](tos.length);
        for (uint256 i = 0; i < airdrops.length; i++) {
            // // Random number between 1 and 10
            // tokenCount = uint8(uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % maxDrops) + 1;
            airdrops[i] = Airdrop({recipient: tos[i], tokenCount: tokenCount});
        }

        //Count up how many tokens are to be minted
        uint256 totalTokens = 0;
        for (uint256 i = 0; i < airdrops.length; i++) {
            totalTokens += airdrops[i].tokenCount;
        }

        clancyERC721Airdroppable.setMaxSupply(totalTokens);

        clancyERC721Airdroppable.deliverDrop(airdrops);

        uint256 counter = 1;
        for (uint256 i = 0; i < airdrops.length; i++) {
            Airdrop memory airdrop = airdrops[i];
            for (uint256 j = 0; j < airdrop.tokenCount; j++) {
                assertEq(
                    clancyERC721Airdroppable.ownerOf(counter++),
                    airdrop.recipient
                );
            }
        }
    }
}
