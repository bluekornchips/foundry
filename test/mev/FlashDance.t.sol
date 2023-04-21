// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

import {FlashDance} from "mev/FlashDance.sol";

import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

import {IPriceOracle} from "aave-v3-core/contracts/interfaces/IPriceOracle.sol";

import {ISwapRouter} from "uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

import {Ducky} from "test-helpers/Ducky.sol";
import {TEST_CONSTANTS} from "test-helpers/TEST_CONSTANTS.sol";

contract FlashDance_Test is Test, Ducky, TEST_CONSTANTS {
    using Strings for uint256;

    FlashDance flashDance;

    // // Sepolia
    // address private constant POOL_ADDRESS_PROVIDER_SEPOLIA =
    //     0x0496275d34753A48320CA58103d5220d394FF77F;
    // address private constant USDC_SEPOLIA =
    //     address(0xda9d4f9b69ac6C22e444eD9aF0CfC043b7a7f53f);
    // address private constant DAI_SEPOLIA =
    //     address(0x68194a729C2450ad26072b3D33ADaCbcef39D574);

    // Polygon
    address private constant POOL_ADDRESS_PROVIDER_POLYGON =
        0xa97684ead0e402dC232d5A977953DF7ECBaB3CDb;
    address private constant SWAPROUTER_POLYGON =
        0xE592427A0AEce92De3Edee1F18E0157C05861564;
    address private constant USDC_POLYGON =
        0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;
    address private constant DAI_POLYGON =
        0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063;

    function setUp() public {
        ppBig("Flash Dance Test");
        flashDance = new FlashDance(
            ISwapRouter(SWAPROUTER_POLYGON),
            POOL_ADDRESS_PROVIDER_POLYGON
        );
    }

    function test_requestFlashLoan_POLYGON() public {
        ppSmall("test_requestFlashLoan");

        console.log("Test Address: %s", address(this));
        console.log("FlashDance Address: %s", address(flashDance));

        vm.startPrank(REAL_WALLET);

        uint256 initialUSDCBalance = IERC20(USDC_POLYGON).balanceOf(
            address(REAL_WALLET)
        );
        console.log("USDC Balance", initialUSDCBalance);
        require(initialUSDCBalance > 0, "USDC Balance is 0");

        uint256 sendAmount = initialUSDCBalance / 2;

        // Fund the FlashLoan contract
        IERC20(USDC_POLYGON).transfer(address(flashDance), initialUSDCBalance);
        address(flashDance).call{value: 1 ether}("");

        // Pricing
        IPriceOracle oracle = IPriceOracle(flashDance.getPriceOracle());
        uint256 currentPriceUSDC = oracle.getAssetPrice(USDC_POLYGON);
        uint256 currentPriceDAI = oracle.getAssetPrice(DAI_POLYGON);
        console.log("Current Price USDC: %s", currentPriceUSDC);
        console.log("Current Price DAI: %s", currentPriceDAI);

        uint256 largerOfTwo = currentPriceUSDC > currentPriceDAI
            ? currentPriceUSDC
            : currentPriceDAI;
        uint256 smallerofTwo = currentPriceUSDC < currentPriceDAI
            ? currentPriceUSDC
            : currentPriceDAI;
        unchecked {
            console.log("Price Difference: %s ", largerOfTwo - smallerofTwo);
        }
        console.log("");

        // Loan
        flashDance.requestFlashLoan(USDC_POLYGON, sendAmount);
        ppIndent("Flash Loan Requested successfully.", 0, " ");

        // balance before
        uint256 daiBalanceBefore = IERC20(DAI_POLYGON).balanceOf(
            address(flashDance)
        );
        console.log("DAI Balance, before swap: ", daiBalanceBefore);

        // Swap
        flashDance.swapInput(USDC_POLYGON, DAI_POLYGON, sendAmount, 3000);

        // balance after
        uint256 daiBalanceAfter = IERC20(DAI_POLYGON).balanceOf(
            address(flashDance)
        );
        uint256 usdcBalance = IERC20(USDC_POLYGON).balanceOf(
            address(flashDance)
        );
        console.log("");
        console.log("DAI Balance, after swap: ", daiBalanceAfter);
        console.log("USDC Balance, after swap: ", usdcBalance);

        // Profit Check
        unchecked {
            ppSmall("Profit Check");
            uint256 daiProfit = daiBalanceAfter - daiBalanceBefore;
            uint256 usdcProfit = initialUSDCBalance - usdcBalance;
            console.log("DAI Profit: %s", daiProfit / 10 ** 18);
            console.log("USDC Profit: -%s", usdcProfit / 10 ** 6);
            console.log(
                "Profit Difference: -%s",
                usdcProfit / 10 ** 6 - daiProfit / 10 ** 18
            );
        }

        vm.stopPrank();
    }
}
