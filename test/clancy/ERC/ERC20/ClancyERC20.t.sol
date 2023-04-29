// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";

import {ClancyERC20} from "clancy/ERC/ERC20/ClancyERC20.sol";

import {Titan} from "test-helpers/Titan/Titan.sol";

contract ClancyERC20_Test is Test, Titan {
    ClancyERC20 clancyERC20;
    uint256 public constant INITIAL_SUPPLY = 0;
    uint256 public constant CAP = 1_000_000;
    uint256 public constant SAMPLE_SIZE = 1_000;

    function setUp() public {
        clancyERC20 = new ClancyERC20(
            "ClancyCoin",
            "CERC",
            INITIAL_SUPPLY,
            CAP
        );
    }

    function test_Name() external {
        assertEq("ClancyCoin", clancyERC20.name());
    }

    function test_Symbol() external {
        assertEq("CERC", clancyERC20.symbol());
    }

    function test_Mint() public {
        clancyERC20.mint(CAP);
        assertEq(
            clancyERC20.totalSupply(),
            clancyERC20.balanceOf(address(this))
        );
    }

    function test_Burn() public {
        clancyERC20.mint(SAMPLE_SIZE);
        assertEq(clancyERC20.balanceOf(address(this)), SAMPLE_SIZE);

        clancyERC20.burn(100);

        assertEq(clancyERC20.totalSupply(), SAMPLE_SIZE - 100);
        assertEq(clancyERC20.balanceOf(address(this)), SAMPLE_SIZE - 100);
    }

    function test_Approve() public {
        assertTrue(clancyERC20.approve(w_main, SAMPLE_SIZE));
        assertEq(clancyERC20.allowance(address(this), w_main), SAMPLE_SIZE);
    }

    function test_IncreaseAllowance() external {
        assertEq(clancyERC20.allowance(address(this), w_main), 0);
        assertTrue(clancyERC20.increaseAllowance(w_main, SAMPLE_SIZE));
        assertEq(clancyERC20.allowance(address(this), w_main), SAMPLE_SIZE);
    }

    function test_DecreaseAllowance() external {
        vm.startPrank(w_main);

        assertTrue(clancyERC20.approve(address(this), SAMPLE_SIZE));
        assertTrue(clancyERC20.decreaseAllowance(address(this), 1));
        assertEq(clancyERC20.allowance(w_main, address(this)), SAMPLE_SIZE - 1);

        vm.stopPrank();
    }

    function test_Transfer() external {
        vm.startPrank(w_main);

        clancyERC20.mint(SAMPLE_SIZE);
        clancyERC20.transfer(w_one, SAMPLE_SIZE);
        assertEq(clancyERC20.balanceOf(w_one), SAMPLE_SIZE);
        assertEq(clancyERC20.balanceOf(w_main), 0);

        vm.stopPrank();
    }

    function test_TransferFrom() external {
        vm.startPrank(w_main);

        clancyERC20.mint(SAMPLE_SIZE);
        clancyERC20.approve(address(this), SAMPLE_SIZE);

        vm.stopPrank();

        assertTrue(clancyERC20.transferFrom(w_main, w_one, 50));
        assertEq(
            clancyERC20.allowance(w_main, address(this)),
            SAMPLE_SIZE - 50
        );
        assertEq(clancyERC20.balanceOf(w_main), SAMPLE_SIZE - 50);
        assertEq(clancyERC20.balanceOf(w_one), 50);
    }

    function test_MintToZero_ShouldFail() external {
        vm.expectRevert("ERC20: mint to the zero address");
        vm.prank(address(0));
        clancyERC20.mint(SAMPLE_SIZE);
    }

    function test_BurnFromZero_ShouldFail() external {
        vm.prank(address(0));
        vm.expectRevert("ERC20: burn from the zero address");
        clancyERC20.burn(SAMPLE_SIZE);
    }

    function test_BurnInsufficientBalance_ShouldFail() external {
        vm.startPrank(w_main);

        clancyERC20.mint(SAMPLE_SIZE);
        vm.expectRevert("ERC20: burn amount exceeds balance");
        clancyERC20.burn(SAMPLE_SIZE * 2);

        vm.stopPrank();
    }

    function test_ApproveToZeroAddress_ShouldFail() external {
        vm.expectRevert("ERC20: approve to the zero address");
        clancyERC20.approve(address(0), SAMPLE_SIZE);
    }

    function test_ApproveFromZeroAddress_ShouldFail() external {
        vm.prank(address(0));
        vm.expectRevert();
        clancyERC20.approve(w_main, SAMPLE_SIZE);
    }

    function test_TransferToZeroAddress_ShouldFail() external {
        vm.startPrank(w_main);

        clancyERC20.mint(SAMPLE_SIZE);
        vm.expectRevert();
        clancyERC20.transfer(address(0), SAMPLE_SIZE);

        vm.stopPrank();
    }

    function test_TransferFromZeroAddress_ShouldFail() external {
        vm.prank(address(0));
        vm.expectRevert("ERC20: transfer from the zero address");
        clancyERC20.transfer(w_main, SAMPLE_SIZE);
    }

    function test_TransferInsufficientBalance_ShouldFail() external {
        vm.startPrank(w_main);

        clancyERC20.mint(SAMPLE_SIZE);
        clancyERC20.approve(address(this), SAMPLE_SIZE);
        vm.expectRevert();
        clancyERC20.transfer(w_one, SAMPLE_SIZE * 2);

        vm.stopPrank();
    }

    function test_TransferFromInsufficientApprove() external {
        vm.startPrank(w_main);

        clancyERC20.mint(SAMPLE_SIZE);
        clancyERC20.approve(address(this), 1);
        vm.expectRevert("ERC20: insufficient allowance");
        clancyERC20.transferFrom(w_main, w_one, SAMPLE_SIZE);

        vm.stopPrank();
    }

    function test_TransferFromInsufficientBalance_ShouldFail() external {
        vm.startPrank(w_main);

        clancyERC20.mint(SAMPLE_SIZE - 1);
        clancyERC20.approve(address(this), SAMPLE_SIZE);

        vm.stopPrank();

        vm.expectRevert("ERC20: transfer amount exceeds balance");
        clancyERC20.transferFrom(w_main, w_one, SAMPLE_SIZE);
    }

    function testFuzz_Mint(address to, uint256 amount) external {
        vm.assume(to != address(0));
        amount = bound(amount, 0, CAP);
        clancyERC20.mintTo(to, amount);
        assertEq(clancyERC20.totalSupply(), clancyERC20.balanceOf(to));
    }

    //#region Fuzzing

    function testFuzz_Burn(
        address from,
        uint256 mintAmount,
        uint256 burnAmount
    ) external {
        vm.assume(from != address(0));
        mintAmount = bound(mintAmount, 0, CAP);
        burnAmount = bound(burnAmount, 0, mintAmount);

        vm.startPrank(from);

        clancyERC20.mint(mintAmount);
        clancyERC20.approve(address(this), mintAmount);

        vm.stopPrank();

        clancyERC20.burnFrom(from, burnAmount);

        assertEq(clancyERC20.totalSupply(), mintAmount - burnAmount);
        assertEq(clancyERC20.balanceOf(from), mintAmount - burnAmount);
    }

    function testFuzz_Burn_AnotherEOAsTokens_ShouldFail(
        address from,
        uint256 amount
    ) external {
        vm.assume(from != address(0));
        amount = bound(amount, 1, CAP);

        vm.prank(from);
        clancyERC20.mint(amount);

        vm.expectRevert("ERC20: insufficient allowance");
        clancyERC20.burnFrom(from, amount);
    }

    function testFuzz_Approve(address to, uint256 amount) external {
        vm.assume(to != address(0));
        assertTrue(clancyERC20.approve(to, amount));
        assertEq(clancyERC20.allowance(address(this), to), amount);
    }

    function testFuzz_Transfer(address to, uint256 amount) external {
        vm.assume(to != address(0));
        vm.assume(to != address(this));

        amount = bound(amount, 0, CAP);

        clancyERC20.mint(amount);
        assertTrue(clancyERC20.transfer(to, amount));
        assertEq(clancyERC20.balanceOf(address(this)), 0);
        assertEq(clancyERC20.balanceOf(to), amount);
    }

    function testFuzz_TransferFrom(
        address from,
        address to,
        uint256 approval,
        uint256 amount
    ) external {
        vm.assume(from != address(0));
        vm.assume(to != address(0));

        amount = bound(amount, 0, CAP);
        approval = bound(approval, 0, amount);

        clancyERC20.mintTo(from, amount);

        vm.prank(from);
        assertTrue(clancyERC20.approve(address(this), approval));

        assertTrue(clancyERC20.transferFrom(from, to, approval));
        assertEq(clancyERC20.totalSupply(), amount);
        assertEq(clancyERC20.allowance(from, address(this)), 0);

        if (from == to) {
            assertEq(clancyERC20.balanceOf(from), amount);
        } else {
            assertEq(clancyERC20.balanceOf(from), amount - approval);
            assertEq(clancyERC20.balanceOf(to), approval);
        }
    }

    function testFuzz_BurnInsufficientBalance_ShouldFail(
        address to,
        uint256 mintAmount,
        uint256 burnAmount
    ) external {
        vm.assume(to != address(0));

        mintAmount = bound(mintAmount, 0, CAP - 1);
        burnAmount = bound(burnAmount, mintAmount + 1, CAP);

        clancyERC20.mint(mintAmount);

        vm.expectRevert("ERC20: burn amount exceeds balance");
        clancyERC20.burn(burnAmount);
    }

    function testFuzz_TransferInsufficientBalance_ShouldFail(
        address to,
        uint256 mintAmount,
        uint256 sendAmount
    ) external {
        mintAmount = bound(mintAmount, 0, CAP - 1);
        sendAmount = bound(sendAmount, mintAmount + 1, CAP);
        vm.assume(to != address(0));

        clancyERC20.mintTo(address(this), mintAmount);
        vm.expectRevert("ERC20: transfer amount exceeds balance");
        clancyERC20.transfer(to, sendAmount);
    }

    function testFuzz_TransferFromInsufficientApprove_ShouldFail(
        address from,
        address to,
        uint256 approval,
        uint256 amount
    ) external {
        vm.assume(from != address(0));
        vm.assume(to != address(0));

        approval = bound(approval, 0, CAP - 1);
        amount = bound(amount, approval + 1, CAP);

        clancyERC20.mintTo(from, amount);

        vm.prank(from);
        clancyERC20.approve(address(this), approval);

        vm.expectRevert("ERC20: insufficient allowance");
        clancyERC20.transferFrom(from, to, amount);
    }

    function testFuzz_TransferFromInsufficientBalance_ShouldFail(
        address from,
        address to,
        uint256 mintAmount,
        uint256 sentAmount
    ) external {
        vm.assume(to != address(0));
        vm.assume(from != address(0));

        mintAmount = bound(mintAmount, 0, CAP - 1);
        sentAmount = bound(sentAmount, mintAmount + 1, CAP);

        clancyERC20.mintTo(from, mintAmount);

        vm.prank(from);
        clancyERC20.approve(address(this), CAP);

        vm.expectRevert("ERC20: transfer amount exceeds balance");
        clancyERC20.transferFrom(from, to, sentAmount);
    }
}
