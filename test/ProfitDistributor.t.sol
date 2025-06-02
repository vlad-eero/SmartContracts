// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {ProfitDistributor} from "../src/profit-distributor/ProfitDistributor.sol";
import {MockERC20} from "./MockERC20.sol";

contract ProfitDistributorTest is Test {
    // Define events from ProfitDistributor to use in tests
    event ProfitReceived(address indexed from, uint256 amount);
    event ProfitClaimed(address indexed to, uint256 amount);

    ProfitDistributor public profitDistributor;
    MockERC20 public shares;
    MockERC20 public usdc;
    address public owner;
    address public profitDepositor;
    address public user1;
    address public user2;

    function setUp() public {
        owner = makeAddr("owner");
        profitDepositor = makeAddr("profitDepositor");
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");

        // Deploy mock tokens
        shares = new MockERC20("Shares", "SHR", 18);
        usdc = new MockERC20("USDC", "USDC", 6);

        // Deploy ProfitDistributor
        profitDistributor = new ProfitDistributor();
        profitDistributor.initialize(address(shares), address(usdc), profitDepositor, owner);

        // Setup initial balances
        shares.mint(user1, 1000e18);
        shares.mint(user2, 2000e18);
        usdc.mint(profitDepositor, 1000e6);
    }

    function test_Initialization() public {
        assertEq(address(profitDistributor.shares()), address(shares));
        assertEq(address(profitDistributor.usdc()), address(usdc));
        assertEq(profitDistributor.profitDepositor(), profitDepositor);
        assertEq(profitDistributor.owner(), owner);
    }

    function test_DepositProfit() public {
        uint256 amount = 100e6;
        vm.startPrank(profitDepositor);
        usdc.approve(address(profitDistributor), amount);

        vm.expectEmit(true, true, true, true);
        emit ProfitReceived(profitDepositor, amount);
        profitDistributor.depositProfit(amount);

        assertEq(profitDistributor.totalReceived(), amount);
        vm.stopPrank();
    }

    function test_DepositProfitUnauthorized() public {
        vm.startPrank(user1);
        vm.expectRevert("Not authorized to deposit profit");
        profitDistributor.depositProfit(100e6);
        vm.stopPrank();
    }

    function test_ClaimProfit() public {
        // Setup: deposit profit
        uint256 amount = 100e6;
        vm.startPrank(profitDepositor);
        usdc.approve(address(profitDistributor), amount);
        profitDistributor.depositProfit(amount);
        vm.stopPrank();

        // Transfer shares to update rewards
        vm.startPrank(user1);
        shares.transfer(user2, 500e18);
        vm.stopPrank();

        // Claim profit
        vm.startPrank(user1);
        uint256 earned = profitDistributor.earned(user1);
        vm.expectEmit(true, true, true, true);
        emit ProfitClaimed(user1, earned);
        profitDistributor.claim();
        assertEq(usdc.balanceOf(user1), earned);
        vm.stopPrank();
    }

    function test_UpdateReward() public {
        // Setup: deposit profit
        uint256 amount = 100e6;
        vm.startPrank(profitDepositor);
        usdc.approve(address(profitDistributor), amount);
        profitDistributor.depositProfit(amount);
        vm.stopPrank();

        // Transfer shares
        vm.startPrank(user1);
        shares.transfer(user2, 500e18);
        vm.stopPrank();

        // Check rewards
        uint256 user1Reward = profitDistributor.earned(user1);
        uint256 user2Reward = profitDistributor.earned(user2);
        assertTrue(user1Reward > 0);
        assertTrue(user2Reward > 0);
    }

    function test_SetProfitDepositor() public {
        address newDepositor = makeAddr("newDepositor");
        vm.startPrank(owner);
        profitDistributor.setProfitDepositor(newDepositor);
        assertEq(profitDistributor.profitDepositor(), newDepositor);
        vm.stopPrank();
    }

    function test_SetProfitDepositorUnauthorized() public {
        address newDepositor = makeAddr("newDepositor");
        vm.startPrank(user1);
        vm.expectRevert();
        profitDistributor.setProfitDepositor(newDepositor);
        vm.stopPrank();
    }
}
