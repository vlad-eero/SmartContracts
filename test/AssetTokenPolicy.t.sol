// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {AssetTokenPolicy} from "../src/policy/AssetTokenPolicy.sol";
import {AssetToken} from "../src/asset-token/AssetToken.sol";
import {MockERC20} from "./MockERC20.sol";

contract AssetTokenPolicyTest is Test {
    AssetTokenPolicy public policy;
    address public owner;
    address public user1;
    address public user2;
    address public user3;

    // Define events from AssetTokenPolicy to use in tests
    event Whitelisted(address indexed account, bool whitelisted);
    event MintLimitSet(uint256 limit);
    event BurnLimitSet(uint256 limit);
    event TransferTimelockSet(uint256 timelock);

    function setUp() public {
        owner = makeAddr("owner");
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        user3 = makeAddr("user3");

        vm.startPrank(owner);
        policy = new AssetTokenPolicy();

        // Set timelock to 0 for testing
        policy.setTransferTimelock(0);
        vm.stopPrank();
    }

    function test_Initialization() public {
        assertEq(policy.owner(), owner);
        assertEq(policy.mintLimit(), 0);
        assertEq(policy.burnLimit(), 0);
        // Timelock is set to 0 in setUp
        assertEq(policy.transferTimelock(), 0);
    }

    function test_Whitelist() public {
        vm.startPrank(owner);

        vm.expectEmit(true, true, true, true);
        emit Whitelisted(user1, true);
        policy.setWhitelist(user1, true);

        assertTrue(policy.whitelist(user1));
        assertFalse(policy.whitelist(user2));

        vm.stopPrank();
    }

    function test_WhitelistUnauthorized() public {
        vm.startPrank(user1);
        vm.expectRevert();
        policy.setWhitelist(user2, true);
        vm.stopPrank();
    }

    function test_SetMintLimit() public {
        vm.startPrank(owner);

        uint256 limit = 1000;
        vm.expectEmit(true, true, true, true);
        emit MintLimitSet(limit);
        policy.setMintLimit(limit);

        assertEq(policy.mintLimit(), limit);
        vm.stopPrank();
    }

    function test_SetBurnLimit() public {
        vm.startPrank(owner);

        uint256 limit = 500;
        vm.expectEmit(true, true, true, true);
        emit BurnLimitSet(limit);
        policy.setBurnLimit(limit);

        assertEq(policy.burnLimit(), limit);
        vm.stopPrank();
    }

    function test_SetTransferTimelock() public {
        vm.startPrank(owner);

        uint256 timelock = 12 hours;
        vm.expectEmit(true, true, true, true);
        emit TransferTimelockSet(timelock);
        policy.setTransferTimelock(timelock);

        assertEq(policy.transferTimelock(), timelock);
        vm.stopPrank();
    }

    function test_CanTransfer() public {
        // Setup whitelist
        vm.startPrank(owner);
        policy.setWhitelist(user1, true);
        policy.setWhitelist(user2, true);
        vm.stopPrank();

        // Test transfer to whitelisted address
        assertTrue(policy.canTransfer(user1, user2, 100));

        // Test transfer to non-whitelisted address
        assertFalse(policy.canTransfer(user1, user3, 100));

        // Test mint/burn (address(0))
        assertTrue(policy.canTransfer(address(0), user1, 100)); // mint
        assertTrue(policy.canTransfer(user1, address(0), 100)); // burn
    }

    function test_TransferTimelock() public {
        // Setup whitelist
        vm.startPrank(owner);
        policy.setWhitelist(user1, true);
        policy.setWhitelist(user2, true);

        // Set timelock for this test
        policy.setTransferTimelock(24 hours);
        vm.stopPrank();

        // Record a received transfer
        policy.recordReceived(user1, user2);

        // Test transfer within timelock period
        assertFalse(policy.canTransfer(user2, user1, 100));

        // Test transfer after timelock period
        vm.warp(block.timestamp + 25 hours);
        assertTrue(policy.canTransfer(user2, user1, 100));
    }

    function test_CanMint() public {
        // Test with no limit
        assertTrue(policy.canMint(user1, 1000));

        // Set mint limit
        vm.startPrank(owner);
        policy.setMintLimit(500);
        vm.stopPrank();

        // Test within limit
        assertTrue(policy.canMint(user1, 500));

        // Test exceeding limit
        assertFalse(policy.canMint(user1, 501));
    }

    function test_CanBurn() public {
        // Test with no limit
        assertTrue(policy.canBurn(user1, 1000));

        // Set burn limit
        vm.startPrank(owner);
        policy.setBurnLimit(300);
        vm.stopPrank();

        // Test within limit
        assertTrue(policy.canBurn(user1, 300));

        // Test exceeding limit
        assertFalse(policy.canBurn(user1, 301));
    }

    function test_ResetCounters() public {
        vm.startPrank(owner);
        policy.resetMinted(user1);
        policy.resetBurned(user1);
        vm.stopPrank();

        vm.startPrank(user1);
        vm.expectRevert();
        policy.resetMinted(user2);
        vm.stopPrank();
    }
}
