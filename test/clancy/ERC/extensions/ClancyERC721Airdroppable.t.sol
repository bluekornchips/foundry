// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";

import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";

import {ClancyERC721Airdroppable} from "clancy/ERC/extensions/ClancyERC721Airdroppable.sol";
import {IClancyERC721Airdroppable} from "clancy/ERC/extensions/IClancyERC721Airdroppable.sol";
import {ClancyERC721TestHelpers} from "test-helpers//ClancyERC721TestHelpers.sol";

import {TEST_CONSTANTS} from "test-helpers//TEST_CONSTANTS.sol";

contract ClancyERC721Airdroppable_Test is
    Test,
    IClancyERC721Airdroppable,
    ClancyERC721TestHelpers,
    TEST_CONSTANTS
{
    using Strings for uint256;

    ClancyERC721Airdroppable public clancyERC721Airdroppable;

    function setUp() public {
        clancyERC721Airdroppable = new ClancyERC721Airdroppable(
            NAME,
            SYMBOL,
            MAX_SUPPLY,
            BASE_URI
        );
    }

    function test_deliverDrop() public {
        uint8 tokenCount = 1;

        Airdrop[] memory airdrops = new Airdrop[](3);
        airdrops[0] = Airdrop({
            recipient: TEST_WALLET_MAIN,
            tokenCount: tokenCount
        });
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

        vm.expectEmit(true, false, false, false);
        emit AirdropDelivered(airdropped);
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

    function testFuzz_deliverDrop(address[] calldata tos, uint8 seed) public {
        uint8 maxDrops = 10;

        vm.assume(tos.length > 0);
        vm.assume(tos.length < 100);
        vm.assume(seed > 0);
        // vm.assume(seed < maxDrops);

        // Assume each address is not the zero address
        for (uint256 i = 0; i < tos.length; i++) {
            vm.assume(tos[i] != address(0));
        }

        clancyERC721Airdroppable.setMaxSupply(
            tos.length * MAX_SUPPLY * maxDrops
        );

        Airdrop[] memory airdrops = new Airdrop[](tos.length);
        for (uint256 i = 0; i < airdrops.length; i++) {
            airdrops[i] = Airdrop({recipient: tos[i], tokenCount: seed});
        }

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
