// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {AssetToken} from "../src/asset-token/AssetToken.sol";
import {AssetTokenPolicy} from "../src/policy/AssetTokenPolicy.sol";
import {ProfitDistributor} from "../src/profit-distributor/ProfitDistributor.sol";
import {MockERC20} from "./MockERC20.sol";

contract AssetTokenIntegrationTest is Test {
    AssetToken public assetToken;
    AssetTokenPolicy public policy;
    ProfitDistributor public profitDistributor;
    MockERC20 public usdc;

    address public owner;
    address public user1;
    address public user2;
    address public profitDepositor;

    function setUp() public {
        owner = makeAddr("owner");
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        profitDepositor = makeAddr("profitDepositor");

        // Deploy contracts
        vm.startPrank(owner);

        // Deploy AssetToken
        assetToken = new AssetToken();
        assetToken.initialize("Asset Token", "AST", owner);

        // Deploy Policy
        policy = new AssetTokenPolicy();

        // Deploy USDC mock
        usdc = new MockERC20("USDC", "USDC", 6);

        // Deploy ProfitDistributor
        profitDistributor = new ProfitDistributor();
        profitDistributor.initialize(address(assetToken), address(usdc), profitDepositor, owner);

        // Connect components
        assetToken.setPolicy(address(policy));
        assetToken.setProfitDistributor(address(profitDistributor));

        // Setup whitelist - CRITICAL: whitelist address(0) for mint/burn operations
        policy.setWhitelist(user1, true);
        policy.setWhitelist(user2, true);
        policy.setWhitelist(address(0), true); // Allow mint/burn operations
        policy.setWhitelist(owner, true); // Allow owner to receive tokens
        policy.setWhitelist(address(profitDistributor), true); // Allow ProfitDistributor interactions

        // Mint initial tokens
        assetToken.mint(user1, 1000 * 10 ** 18);

        // Mint USDC to profit depositor
        usdc.mint(profitDepositor, 10000 * 10 ** 6);

        vm.stopPrank();
    }

    function test_PolicyRestrictsTransfer() public {
        // User not on whitelist
        address nonWhitelisted = makeAddr("nonWhitelisted");

        // Warp past any timelock
        vm.warp(block.timestamp + 25 hours);

        vm.startPrank(user1);
        vm.expectRevert(); // Should revert due to policy restriction
        assetToken.transfer(nonWhitelisted, 100 * 10 ** 18);
        vm.stopPrank();

        // Transfer to whitelisted user should work
        vm.startPrank(user1);
        assetToken.transfer(user2, 100 * 10 ** 18);
        assertEq(assetToken.balanceOf(user2), 100 * 10 ** 18);
        vm.stopPrank();
    }

    // function test_PolicyTimelockRestriction() public {
    //     // First transfer works
    //     vm.startPrank(user1);
    //     assetToken.transfer(user2, 100 * 10**18);
    //     vm.stopPrank();
        
    //     // Second transfer from user2 should fail due to timelock
    //     vm.startPrank(user2);
    //     vm.expectRevert(); // Should revert due to timelock
    //     assetToken.transfer(user1, 50 * 10**18);
    //     vm.stopPrank();
        
    //     // After timelock period, transfer should work
    //     vm.warp(block.timestamp + 25 hours);
    //     vm.startPrank(user2);
    //     assetToken.transfer(user1, 50 * 10**18);
    //     assertEq(assetToken.balanceOf(user1), 950 * 10**18);
    //     vm.stopPrank();
    // }

    // function test_ProfitDistributionAfterTransfer() public {
    //     // Deposit profit
    //     vm.startPrank(profitDepositor);
    //     usdc.approve(address(profitDistributor), 1000 * 10**6);
    //     profitDistributor.depositProfit(1000 * 10**6);
    //     vm.stopPrank();
        
    //     // Check initial earned amounts
    //     uint256 user1InitialEarned = profitDistributor.earned(user1);
    //     uint256 user2InitialEarned = profitDistributor.earned(user2);
        
    //     // Transfer tokens
    //     vm.startPrank(user1);
    //     assetToken.transfer(user2, 400 * 10**18);
    //     vm.stopPrank();
        
    //     // Check updated earned amounts
    //     uint256 user1FinalEarned = profitDistributor.earned(user1);
    //     uint256 user2FinalEarned = profitDistributor.earned(user2);
        
    //     // Verify profit distribution updated correctly
    //     assertTrue(user1FinalEarned > 0);
    //     assertTrue(user2FinalEarned > 0);
    //     assertTrue(user2FinalEarned > user2InitialEarned);
    // }

    // function test_MintWithPolicyLimit() public {
    //     // Set mint limit
    //     vm.startPrank(owner);
    //     policy.setMintLimit(1500 * 10**18);
        
    //     // Track minted amount for user2
    //     policy.resetMinted(user2); // Reset any previous minting
    //     vm.stopPrank();
        
    //     // Mint within limit
    //     vm.startPrank(owner);
    //     assetToken.mint(user2, 500 * 10**18);
    //     vm.stopPrank();
        
    //     // Try to mint exceeding limit
    //     vm.startPrank(owner);
    //     vm.expectRevert("Mint not allowed by policy");
    //     assetToken.mint(user2, 1001 * 10**18);
    //     vm.stopPrank();
    // }

    // function test_BurnWithPolicyLimit() public {
    //     // Set burn limit
    //     vm.startPrank(owner);
    //     policy.setBurnLimit(300 * 10**18);
        
    //     // Track burned amount for user1
    //     policy.resetBurned(user1); // Reset any previous burning
    //     vm.stopPrank();
        
    //     // Burn within limit
    //     vm.startPrank(owner);
    //     assetToken.burn(user1, 300 * 10**18);
    //     vm.stopPrank();
        
    //     // Try to burn exceeding limit
    //     vm.startPrank(owner);
    //     vm.expectRevert("Burn not allowed by policy");
    //     assetToken.burn(user1, 1 * 10**18);
    //     vm.stopPrank();
    // }

    // function test_FullProfitDistributionCycle() public {
    //     // Deposit profit
    //     vm.startPrank(profitDepositor);
    //     usdc.approve(address(profitDistributor), 1000 * 10**6);
    //     profitDistributor.depositProfit(1000 * 10**6);
    //     vm.stopPrank();
        
    //     // Transfer some tokens to distribute ownership
    //     vm.startPrank(user1);
    //     assetToken.transfer(user2, 300 * 10**18);
    //     vm.stopPrank();
        
    //     // Check earned amounts
    //     uint256 user1Earned = profitDistributor.earned(user1);
    //     uint256 user2Earned = profitDistributor.earned(user2);
        
    //     // User1 claims profit
    //     vm.startPrank(user1);
    //     profitDistributor.claim();
    //     vm.stopPrank();
        
    //     // Verify USDC received
    //     assertEq(usdc.balanceOf(user1), user1Earned);
        
    //     // User2 claims profit
    //     vm.startPrank(user2);
    //     profitDistributor.claim();
    //     vm.stopPrank();
        
    //     // Verify USDC received
    //     assertEq(usdc.balanceOf(user2), user2Earned);
        
    //     // Verify total claimed is correct
    //     assertEq(usdc.balanceOf(user1) + usdc.balanceOf(user2), 1000 * 10**6);
    // }
}
