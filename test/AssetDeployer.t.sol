// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {AssetDeployer} from "../src/asset-token/AssetDeployer.sol";
import {AssetToken} from "../src/asset-token/AssetToken.sol";

// Importăm evenimentul
import {AssetDeployer} from "../src/asset-token/AssetDeployer.sol";

contract AssetDeployerTest is Test {
    AssetDeployer public assetDeployer;
    AssetToken public assetTokenImplementation;
    address public owner;
    address public addr1;
    uint256 public constant INITIAL_SUPPLY = 1_000_000; // 1 million tokens

    function setUp() public {
        // Setăm adresele de test
        owner = makeAddr("owner");
        addr1 = makeAddr("addr1");

        // Deployăm implementarea AssetToken
        assetTokenImplementation = new AssetToken();

        // Deployăm AssetDeployer ca owner
        vm.startPrank(owner);
        assetDeployer = new AssetDeployer();
        vm.stopPrank();
    }

    // Test pentru deployment
    function test_Deployment() public {
        assertEq(assetDeployer.owner(), owner);
    }

    // Test pentru deployAssetToken
    function test_DeployAssetToken() public {
        vm.startPrank(owner);

        // Deployăm un nou token
        address proxyAddress = assetDeployer.deployAssetToken(address(assetTokenImplementation), "Test Token", "TEST");

        // Verificăm că proxy-ul a fost creat corect
        AssetToken proxy = AssetToken(proxyAddress);
        assertEq(proxy.name(), "Test Token");
        assertEq(proxy.symbol(), "TEST");
        console2.log("balanceOf", proxy.balanceOf(owner));
        assertEq(proxy.balanceOf(owner), 0);
        vm.stopPrank();
    }

    // Test pentru deployAssetToken ca non-owner
    function test_DeployAssetTokenAsNonOwner() public {
        vm.startPrank(addr1);
        vm.expectRevert();
        assetDeployer.deployAssetToken(address(assetTokenImplementation), "Test Token", "TEST");
        vm.stopPrank();
    }

    // Test pentru deployAssetToken cu implementare invalidă
    function test_DeployAssetTokenWithInvalidImplementation() public {
        vm.startPrank(owner);
        vm.expectRevert();
        assetDeployer.deployAssetToken(address(0), "Test Token", "TEST");
        vm.stopPrank();
    }
}
