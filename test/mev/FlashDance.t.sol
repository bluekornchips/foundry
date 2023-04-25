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
import {Forks} from "test-helpers/Titan/Forks.sol";

interface IWETH {
    function deposit() external payable;

    function withdraw(uint256 wad) external;
}

contract FlashDance_Test is Test, Ducky, Titan, Forks {
    using Strings for uint256;

    FlashDance flashDance;

    function setUp() public {
        ppBig("Flash Dance");
        // mapping(string => address) storage polygon = _polygon;
        // flashDance = new FlashDance(
        //     ISwapRouter(polygon["UNISWAP_SWAPROUTER"]),
        //     polygon["POOL_ADDRESS_PROVIDER"]
        // );
    }

    function envSetup(address _swapRouter, address _poolProvider) public {
        flashDance = new FlashDance(ISwapRouter(_swapRouter), _poolProvider);
    }

    function test_requestFlashLoan_Eth() public {
        vm.selectFork(mainnetFork);
        ppSmall("test_requestFlashLoan_Eth");

        /*
         * Start Prank
         */
        vm.startPrank(w_real);

        mapping(string => address) storage chain = _eth;
        envSetup(chain["UNISWAP_SWAPROUTER"], chain["POOL_ADDRESS_PROVIDER"]);

        address WETH = chain["WETH"];
        address PEPE = chain["PEPE"];

        // Decimals
        uint256 wethDecimals = ERC20(WETH).decimals();
        uint256 pepeDecimals = ERC20(PEPE).decimals();

        ppHeader("Balances", "-");
        uint256 initialBalance = payable(w_real).balance;
        uint256 initialWETHBalance = IERC20(WETH).balanceOf(w_real);
        uint256 pepeBalance = IERC20(PEPE).balanceOf(w_real);

        require(initialBalance > 0, "Eth Balance is 0");
        console.log("Eth Balance", initialBalance);
        console.log("WETH Balance", initialWETHBalance);
        console.log("PEPE Balance", pepeBalance);
        console.log("");

        // Deposit eth for weth
        ppHeader("Deposit Eth for WETH", "-");
        uint256 spendableEth = initialBalance - 0.25 ether;
        IWETH(WETH).deposit{value: spendableEth}();
        uint256 wethBalance = IERC20(WETH).balanceOf(w_real);

        // Send all weth to the contract
        IERC20(WETH).transfer(address(flashDance), wethBalance);

        console.log("Eth Balance (Wallet)", payable(w_real).balance);
        console.log("WETH Balance", address(flashDance));
        console.log(
            "PEPE Balance",
            IERC20(PEPE).balanceOf(address(flashDance))
        );
        console.log("");

        // AAVE Pricing
        IPriceOracle oracle = IPriceOracle(flashDance.getPriceOracle());
        uint256 cp_Uni_WETH = oracle.getAssetPrice(WETH);

        // // Uniswap Pricing
        // uint256 cp_Uni_PEPE = oracle.getAssetPrice(PEPE);

        ppHeader("Prices", "-");
        console.log("WETH: %s", cp_Uni_WETH);
        // console.log("PEPE: %s", cp_Uni_PEPE);
        console.log("");

        ppHeader("Swap WETH for PEPE", "-");
        uint24 slippage = 3000;
        // Balance of weth minus slippage as a percentage of the total balance
        uint256 spendableWeth = wethBalance -
            ((wethBalance * slippage) / 10 ** wethDecimals);

        flashDance.swapInput(WETH, PEPE, spendableWeth, slippage);

        pepeBalance = IERC20(PEPE).balanceOf(address(flashDance));
        wethBalance = IERC20(WETH).balanceOf(address(flashDance));

        ppHeader("Balances", "-");
        console.log("Eth Balance", payable(address(flashDance)).balance);
        console.log("WETH Balance", wethBalance);
        console.log("PEPE Balance", pepeBalance);

        // Swap back to WETH
        flashDance.swapInput(PEPE, WETH, pepeBalance, slippage);

        // Withdraw WETH
        flashDance.withdraw(WETH);
        wethBalance = IERC20(WETH).balanceOf(w_real);
        IWETH(WETH).withdraw(wethBalance);

        wethBalance = IERC20(WETH).balanceOf(w_real);
        pepeBalance = IERC20(PEPE).balanceOf(address(flashDance));

        ppHeader("Swapped Back", "-");
        console.log("Eth Balance", payable(w_real).balance);
        console.log("WETH Balance", wethBalance);
        console.log("PEPE Balance", pepeBalance);
        int256 profit = int256(payable(w_real).balance) -
            int256(initialBalance);
        console.log("Profit: ");
        console.logInt(profit);

        /*
         * End Prank
         */
        vm.stopPrank();

        ppSmall("Completed");
    }

    // function test_requestFlashLoan_POLYGON() public {
    //     ppSmall("test_requestFlashLoan_POLYGON");

    //     // Set the addresses with Polygon
    //     mapping(string => address) storage chain = _polygon;
    //     envSetup(chain["UNISWAP_SWAPROUTER"], chain["POOL_ADDRESS_PROVIDER"]);

    //     /*
    //      * Start Prank
    //      */
    //     vm.startPrank(w_real);

    //     address USDC = chain["USDC"];
    //     uint8 usdcDecimals = ERC20(USDC).decimals();
    //     // console.log("USDC Decimals: %s", usdcDecimals);

    //     address DAI = chain["DAI"];
    //     uint8 daiDecimals = ERC20(DAI).decimals();
    //     // console.log("DAI Decimals: %s", daiDecimals);

    //     ppHeader("Balances", "-");
    //     uint256 initialUSDCBalance = IERC20(USDC).balanceOf(w_real);
    //     console.log("USDC Balance", initialUSDCBalance);
    //     require(initialUSDCBalance > 0, "USDC Balance is 0");
    //     console.log("");

    //     // Get the max loan amount possible for the protocol, accounting for the premium
    //     uint128 premium = flashDance.FLASHLOAN_PREMIUM_TO_PROTOCOL();
    //     uint256 sendAmount = initialUSDCBalance;
    //     uint256 maxLoanAmount = (sendAmount * 10 ** usdcDecimals) /
    //         (premium * 1000);

    //     // Fund the FlashLoan contract
    //     IERC20(USDC).transfer(address(flashDance), initialUSDCBalance);

    //     // Get Pricing
    //     IPriceOracle oracle = IPriceOracle(flashDance.getPriceOracle());
    //     uint256 currentPriceUSDC = oracle.getAssetPrice(USDC);
    //     uint256 currentPriceDAI = oracle.getAssetPrice(DAI);

    //     ppHeader("Prices", "-");

    //     console.log("Current Price USDC: %s", currentPriceUSDC);
    //     console.log("Current Price DAI: %s", currentPriceDAI);

    //     console.log("");

    //     // Loan
    //     ppHeader("Loan", "-");

    //     // balance before
    //     uint256 DAIBalanceBefore = IERC20(DAI).balanceOf(address(flashDance));
    //     console.log("DAI Balance, before swap: ", DAIBalanceBefore);
    //     console.log("USDC Balance, before swap: ", initialUSDCBalance);

    //     // Adjust the max loan for slippage
    //     uint24 slippage = 3000;
    //     maxLoanAmount = maxLoanAmount - ((maxLoanAmount / slippage) / 100);

    //     console.log("Max Loan Amount: %s", maxLoanAmount);
    //     flashDance.setupSwap(address(USDC), address(DAI), slippage);
    //     flashDance.requestFlashLoan(USDC, sendAmount / 2);
    //     console.log("Flash Loan Requested successfully.");
    //     console.log("");

    //     // balance after
    //     uint256 DAIBalanceAfter = IERC20(DAI).balanceOf(address(flashDance));
    //     uint256 USDCBalance = IERC20(USDC).balanceOf(address(flashDance));

    //     ppHeader("Balances", "-");
    //     console.log("DAI:", DAIBalanceAfter);
    //     console.log("USDC:", USDCBalance);
    //     console.log("");
    //     ppSubHeader("Normalized", 4);
    //     console.log("DAI", DAIBalanceAfter / 10 ** daiDecimals);
    //     console.log("USDC", USDCBalance / 10 ** usdcDecimals);

    //     /*
    //      * End Prank
    //      */
    //     vm.stopPrank();
    // }
}
