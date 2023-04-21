// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

import {FlashDance} from "mev/FlashDance.sol";

import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {IERC20, ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

import {IPriceOracle} from "aave-v3-core/contracts/interfaces/IPriceOracle.sol";

import {ISwapRouter} from "uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

import {Ducky} from "test-helpers/Ducky.sol";
import {Titan} from "test-helpers/Titan/Titan.sol";

contract FlashDance_Test is Test, Ducky, Titan {
    using Strings for uint256;

    FlashDance flashDance;

    function setUp() public {
        ppBig("Flash Dance");
        mapping(string => address) storage polygon = _chains["polygon"];
        flashDance = new FlashDance(
            ISwapRouter(polygon["SWAPROUTER"]),
            polygon["POOL_ADDRESS_PROVIDER"]
        );
    }

    function test_requestFlashLoan_POLYGON() public {
        ppSmall("test_requestFlashLoan_POLYGON");

        // Set the addresses with Polygon
        mapping(string => address) storage polygon = _chains["polygon"];

        /*
         * Start Prank
         */
        vm.startPrank(w_real);

        ppHeader("Decimals", "-", 2);

        address USDC = polygon["USDC"];
        uint8 usdcDecimals = ERC20(USDC).decimals();
        console.log("USDC Decimals: %s", usdcDecimals);

        address DAI = polygon["DAI"];
        uint8 daiDecimals = ERC20(DAI).decimals();
        console.log("DAI Decimals: %s", daiDecimals);

        uint256 initialUSDCBalance = IERC20(USDC).balanceOf(w_real);
        console.log("USDC Balance", initialUSDCBalance);
        require(initialUSDCBalance > 0, "USDC Balance is 0");
        ppLine("", 1);

        uint256 sendAmount = initialUSDCBalance;

        // Fund the FlashLoan contract
        IERC20(USDC).transfer(address(flashDance), initialUSDCBalance);

        // Get Pricing
        IPriceOracle oracle = IPriceOracle(flashDance.getPriceOracle());
        uint256 currentPriceUSDC = oracle.getAssetPrice(USDC);
        uint256 currentPriceDAI = oracle.getAssetPrice(DAI);

        ppHeader("Prices", "-", 2);

        console.log("Current Price USDC: %s", currentPriceUSDC);
        console.log("Current Price DAI: %s", currentPriceDAI);

        ppLine("", 1);

        // Loan
        ppHeader("Loan", "-", 2);

        // Get the max loan amount possible for USDC
        uint256 maxLoanAmount = flashDance.getMaxFlashLoanAmount(USDC);

        flashDance.requestFlashLoan(USDC, initialUSDCBalance * 2);
        console.log("Flash Loan Requested successfully.");
        ppLine("", 1);

        // // balance before
        // uint256 DAIBalanceBefore = IERC20(DAI).balanceOf(address(flashDance));
        // console.log("DAI Balance, before swap: ", DAIBalanceBefore);

        // // Swap
        // flashDance.swapInput(USDC, DAI, sendAmount, 3000);

        // // balance after
        // uint256 DAIBalanceAfter = IERC20(DAI).balanceOf(address(flashDance));
        // uint256 USDCBalance = IERC20(USDC).balanceOf(address(flashDance));
        // console.log("");
        // console.log("DAI Balance, after swap: ", DAIBalanceAfter);
        // console.log("USDC Balance, after swap: ", USDCBalance);

        // // // Profit Check
        // // unchecked {
        // //     ppSmall("Profit Check");
        // //     uint256 DAIProfit = DAIBalanceAfter - DAIBalanceBefore;
        // //     uint256 USDCProfit = initialUSDCBalance - USDCBalance;
        // //     console.log("DAI Profit: %s", DAIProfit / 10 ** 18);
        // //     console.log("USDC Profit: -%s", USDCProfit / 10 ** 6);
        // //     console.log(
        // //         "Profit Difference: -%s",
        // //         USDCProfit / 10 ** 6 - DAIProfit / 10 ** 18
        // //     );
        // // }

        /*
         * End Prank
         */
        vm.stopPrank();
    }
}
