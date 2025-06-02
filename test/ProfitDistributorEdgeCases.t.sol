// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {ProfitDistributor} from "../src/profit-distributor/ProfitDistributor.sol";
import {MockERC20} from "./MockERC20.sol";

contract ProfitDistributorEdgeCasesTest is Test {
    ProfitDistributor public profitDistributor;
    MockERC20 public shares;
    MockERC20 public usdc;
    address public owner;
    address public profitDepositor;
    address public user1;
    address public user2;
    address public user3;

    function setUp() public {
        owner = makeAddr("owner");
        profitDepositor = makeAddr("profitDepositor");
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        user3 = makeAddr("user3");

        // Deploy mock tokens
        shares = new MockERC20("Shares", "SHR", 18);
        usdc = new MockERC20("USDC", "USDC", 6);

        // Deploy ProfitDistributor
        profitDistributor = new ProfitDistributor();
        profitDistributor.initialize(address(shares), address(usdc), profitDepositor, owner);

        // Setup initial balances
        usdc.mint(profitDepositor, 10000e6);
    }

    function test_DepositProfitWithNoShares() public {
        // Try to deposit profit when no shares exist
        vm.startPrank(profitDepositor);
        usdc.approve(address(profitDistributor), 100e6);
        vm.expectRevert("No shares minted");
        profitDistributor.depositProfit(100e6);
        vm.stopPrank();
    }

    function test_DepositZeroAmount() public {
        // Mint some shares first
        shares.mint(user1, 1000e18);

        // Try to deposit zero profit
        vm.startPrank(profitDepositor);
        usdc.approve(address(profitDistributor), 0);
        vm.expectRevert("No USDC sent");
        profitDistributor.depositProfit(0);
        vm.stopPrank();
    }

    function test_ClaimWithNoEarnings() public {
        // Mint some shares
        shares.mint(user1, 1000e18);

        // Try to claim with no profit deposited
        vm.startPrank(user1);
        vm.expectRevert("Nothing to claim");
        profitDistributor.claim();
        vm.stopPrank();
    }

    function test_MultipleDepositAndClaims() public {
        // Mint shares
        shares.mint(user1, 1000e18);
        shares.mint(user2, 2000e18);

        // First deposit
        vm.startPrank(profitDepositor);
        usdc.approve(address(profitDistributor), 300e6);
        profitDistributor.depositProfit(300e6);
        vm.stopPrank();

        // User1 claims
        uint256 user1FirstEarned = profitDistributor.earned(user1);
        vm.startPrank(user1);
        profitDistributor.claim();
        vm.stopPrank();

        // Second deposit
        vm.startPrank(profitDepositor);
        usdc.approve(address(profitDistributor), 600e6);
        profitDistributor.depositProfit(600e6);
        vm.stopPrank();

        // User1 claims again
        uint256 user1SecondEarned = profitDistributor.earned(user1);
        vm.startPrank(user1);
        profitDistributor.claim();
        vm.stopPrank();

        // User2 claims all at once
        uint256 user2TotalEarned = profitDistributor.earned(user2);
        vm.startPrank(user2);
        profitDistributor.claim();
        vm.stopPrank();

        // Verify balances
        assertEq(usdc.balanceOf(user1), user1FirstEarned + user1SecondEarned);
        assertEq(usdc.balanceOf(user2), user2TotalEarned);

        // Verify total distribution
        assertEq(usdc.balanceOf(user1) + usdc.balanceOf(user2), 900e6);
    }

    function test_ShareTransferBetweenDeposits() public {
        // Mint initial shares
        shares.mint(user1, 3000e18);

        // First deposit
        vm.startPrank(profitDepositor);
        usdc.approve(address(profitDistributor), 300e6);
        profitDistributor.depositProfit(300e6);
        vm.stopPrank();

        // Record earned before transfer
        uint256 user1EarnedBefore = profitDistributor.earned(user1);

        // Transfer shares to user2
        vm.startPrank(user1);
        shares.transfer(user2, 1000e18);
        vm.stopPrank();

        // Update rewards manually (simulating a token transfer that calls updateReward)
        profitDistributor.updateReward(user1, user2);

        // Second deposit
        vm.startPrank(profitDepositor);
        usdc.approve(address(profitDistributor), 300e6);
        profitDistributor.depositProfit(300e6);
        vm.stopPrank();

        // Check earned amounts
        uint256 user1EarnedAfter = profitDistributor.earned(user1);
        uint256 user2EarnedAfter = profitDistributor.earned(user2);

        // User1 should have earned from both deposits but proportionally less from second deposit
        assertTrue(user1EarnedAfter > user1EarnedBefore);

        // User2 should have earned only from second deposit
        assertTrue(user2EarnedAfter > 0);

        // Claims
        vm.startPrank(user1);
        profitDistributor.claim();
        vm.stopPrank();

        vm.startPrank(user2);
        profitDistributor.claim();
        vm.stopPrank();

        // Verify total claimed is correct
        assertEq(usdc.balanceOf(user1) + usdc.balanceOf(user2), 600e6);
    }

    function test_ZeroAddressUpdateReward() public {
        // Mint shares
        shares.mint(user1, 1000e18);

        // Deposit profit
        vm.startPrank(profitDepositor);
        usdc.approve(address(profitDistributor), 100e6);
        profitDistributor.depositProfit(100e6);
        vm.stopPrank();

        // Call updateReward with address(0)
        profitDistributor.updateReward(address(0), user1);
        profitDistributor.updateReward(user1, address(0));

        // Should not revert and should update user1's rewards
        uint256 earned = profitDistributor.earned(user1);
        assertTrue(earned > 0);
    }
}
