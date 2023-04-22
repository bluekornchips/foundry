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

        address USDC = polygon["USDC"];
        uint8 usdcDecimals = ERC20(USDC).decimals();
        // console.log("USDC Decimals: %s", usdcDecimals);

        address DAI = polygon["DAI"];
        uint8 daiDecimals = ERC20(DAI).decimals();
        // console.log("DAI Decimals: %s", daiDecimals);

        ppHeader("Balances", "-", 2);
        uint256 initialUSDCBalance = IERC20(USDC).balanceOf(w_real);
        console.log("USDC Balance", initialUSDCBalance);
        require(initialUSDCBalance > 0, "USDC Balance is 0");
        console.log("");

        // Get the max loan amount possible for the protocol, accounting for the premium
        uint128 premium = flashDance.FLASHLOAN_PREMIUM_TO_PROTOCOL();
        uint256 sendAmount = initialUSDCBalance;
        uint256 maxLoanAmount = (sendAmount * 10 ** usdcDecimals) /
            (premium * 1000);

        // Fund the FlashLoan contract
        IERC20(USDC).transfer(address(flashDance), initialUSDCBalance);

        // Get Pricing
        IPriceOracle oracle = IPriceOracle(flashDance.getPriceOracle());
        uint256 currentPriceUSDC = oracle.getAssetPrice(USDC);
        uint256 currentPriceDAI = oracle.getAssetPrice(DAI);

        ppHeader("Prices", "-", 2);

        console.log("Current Price USDC: %s", currentPriceUSDC);
        console.log("Current Price DAI: %s", currentPriceDAI);

        console.log("");

        // Loan
        ppHeader("Loan", "-", 2);

        // balance before
        uint256 DAIBalanceBefore = IERC20(DAI).balanceOf(address(flashDance));
        console.log("DAI Balance, before swap: ", DAIBalanceBefore);
        console.log("USDC Balance, before swap: ", initialUSDCBalance);

        // Adjust the max loan for slippage
        uint24 slippage = 3000;
        maxLoanAmount = maxLoanAmount - ((maxLoanAmount / slippage) / 100);

        console.log("Max Loan Amount: %s", maxLoanAmount);
        flashDance.setupSwap(address(USDC), address(DAI), slippage);
        flashDance.requestFlashLoan(USDC, sendAmount / 2);
        console.log("Flash Loan Requested successfully.");
        console.log("");

        // balance after
        uint256 DAIBalanceAfter = IERC20(DAI).balanceOf(address(flashDance));
        uint256 USDCBalance = IERC20(USDC).balanceOf(address(flashDance));

        ppHeader("Balances", "-", 2);
        console.log("DAI:", DAIBalanceAfter);
        console.log("USDC:", USDCBalance);
        console.log("");
        ppSubHeader("Normalized", 4);
        console.log("DAI", DAIBalanceAfter / 10 ** daiDecimals);
        console.log("USDC", USDCBalance / 10 ** usdcDecimals);

        /*
         * End Prank
         */
        vm.stopPrank();
    }
}
