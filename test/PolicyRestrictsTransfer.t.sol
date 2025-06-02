// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {AssetToken} from "../src/asset-token/AssetToken.sol";
import {AssetTokenPolicy} from "../src/policy/AssetTokenPolicy.sol";
import {MockERC20} from "./MockERC20.sol";

contract PolicyRestrictsTransferTest is Test {
    AssetToken public assetToken;
    AssetTokenPolicy public policy;

    address public owner;
    address public user1;
    address public user2;
    address public nonWhitelisted;

    function setUp() public {
        owner = makeAddr("owner");
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        nonWhitelisted = makeAddr("nonWhitelisted");

        // Deploy contracts
        vm.startPrank(owner);

        // Deploy AssetToken
        assetToken = new AssetToken();
        assetToken.initialize("Asset Token", "AST", owner);

        // Deploy Policy
        policy = new AssetTokenPolicy();

        // Connect policy to token
        assetToken.setPolicy(address(policy));

        // Setup whitelist
        policy.setWhitelist(user1, true);
        policy.setWhitelist(user2, true);
        policy.setWhitelist(address(0), true); // For mint/burn operations
        policy.setWhitelist(owner, true);

        // Set timelock to 0 for testing
        policy.setTransferTimelock(0);

        // Mint initial tokens
        assetToken.mint(user1, 1000 * 10 ** 18);

        vm.stopPrank();
    }

    function test_PolicyRestrictsTransfer() public {
        // Transfer to whitelisted user should work
        vm.startPrank(user1);
        assetToken.transfer(user2, 100 * 10 ** 18);
        assertEq(assetToken.balanceOf(user2), 100 * 10 ** 18);
        vm.stopPrank();

        // Transfer to non-whitelisted user should fail
        vm.startPrank(user1);
        vm.expectRevert("Transfer not allowed by policy");
        assetToken.transfer(nonWhitelisted, 100 * 10 ** 18);
        vm.stopPrank();

        // Verify balances didn't change
        assertEq(assetToken.balanceOf(user1), 900 * 10 ** 18);
        assertEq(assetToken.balanceOf(nonWhitelisted), 0);
    }

    function test_PolicyTimelockRestriction() public {
        // Set timelock to 24 hours for this test
        vm.startPrank(owner);
        policy.setTransferTimelock(24 hours);

        // Whitelist both users
        policy.setWhitelist(user1, true);
        policy.setWhitelist(user2, true);
        vm.stopPrank();

        // First transfer should fail due to timelock (no previous transfers)
        vm.startPrank(user1);
        vm.expectRevert("Transfer not allowed by policy");
        assetToken.transfer(user2, 100 * 10 ** 18);
        vm.stopPrank();

        // After timelock period, first transfer should work
        vm.warp(block.timestamp + 25 hours);
        vm.startPrank(user1);
        assetToken.transfer(user2, 100 * 10 ** 18);
        vm.stopPrank();

        // Immediate second transfer should fail
        vm.startPrank(user2);
        vm.expectRevert("Transfer not allowed by policy");
        assetToken.transfer(user1, 50 * 10 ** 18);
        vm.stopPrank();

        // After another timelock period, transfer should work
        vm.warp(block.timestamp + 25 hours);
        vm.startPrank(user2);
        assetToken.transfer(user1, 50 * 10 ** 18);
        assertEq(assetToken.balanceOf(user1), 950 * 10 ** 18);
        vm.stopPrank();
    }
}
