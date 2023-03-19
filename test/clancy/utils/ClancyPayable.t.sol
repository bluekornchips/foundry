// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "clancy/utils/ClancyPayable.sol";

contract ClancyPayable_Test is Test {
    ClancyPayable public clancyPayable;
    event Withdrawn(address indexed, uint256 indexed);

    // Needed so the test contract itself can receive ether when withdrawing
    receive() external payable {}

    function setUp() public {
        clancyPayable = new ClancyPayable();
    }

    function test_withdraw() public {
        payable(address(clancyPayable)).transfer(1 ether);
        uint256 balance = address(clancyPayable).balance;
        assertEq(balance, 1 ether);

        vm.expectEmit(true, true, false, false);
        emit Withdrawn(address(this), 1 ether);
        clancyPayable.withdraw();

        balance = address(clancyPayable).balance;
        assertEq(balance, 0);
    }

    function testFuzz_Withdraw(uint96 amount) public {
        payable(address(clancyPayable)).transfer(amount);
        uint256 preBalance = address(this).balance;
        clancyPayable.withdraw();
        uint256 postBalance = address(this).balance;
        assertEq(preBalance + amount, postBalance);
    }
}
