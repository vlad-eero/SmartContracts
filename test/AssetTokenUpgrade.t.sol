// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {AssetToken} from "../src/asset-token/AssetToken.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

// Mock upgraded version of AssetToken with new functionality
contract AssetTokenV2 is AssetToken {
    uint256 public newVariable;

    function setNewVariable(uint256 _value) external onlyOwner {
        newVariable = _value;
    }

    function version() external pure returns (string memory) {
        return "V2";
    }
}

contract AssetTokenUpgradeTest is Test {
    AssetToken public implementation;
    AssetToken public proxy;
    AssetTokenV2 public implementationV2;

    address public owner;
    address public user1;

    function setUp() public {
        owner = makeAddr("owner");
        user1 = makeAddr("user1");

        // Deploy implementation
        implementation = new AssetToken();

        // Deploy proxy
        bytes memory initData = abi.encodeWithSelector(AssetToken.initialize.selector, "Asset Token", "AST", owner);

        ERC1967Proxy proxy_ = new ERC1967Proxy(address(implementation), initData);

        // Cast proxy to AssetToken
        proxy = AssetToken(address(proxy_));

        // Deploy V2 implementation
        implementationV2 = new AssetTokenV2();
    }

    function test_ProxyInitialization() public {
        assertEq(proxy.name(), "Asset Token");
        assertEq(proxy.symbol(), "AST");
        assertEq(proxy.owner(), owner);
    }

    function test_UpgradeToV2() public {
        // Mint some tokens before upgrade
        vm.startPrank(owner);
        proxy.mint(user1, 1000 * 10 ** 18);
        vm.stopPrank();

        // Upgrade to V2
        vm.startPrank(owner);
        proxy.upgradeToAndCall(address(implementationV2), "");
        vm.stopPrank();

        // Cast to V2 to access new functionality
        AssetTokenV2 proxyV2 = AssetTokenV2(address(proxy));

        // Test new functionality
        vm.startPrank(owner);
        proxyV2.setNewVariable(42);
        vm.stopPrank();

        // Verify new functionality works
        assertEq(proxyV2.newVariable(), 42);
        assertEq(proxyV2.version(), "V2");

        // Verify existing state is preserved
        assertEq(proxyV2.balanceOf(user1), 1000 * 10 ** 18);
        assertEq(proxyV2.name(), "Asset Token");
        assertEq(proxyV2.symbol(), "AST");
    }

    function test_UpgradeUnauthorized() public {
        // Try to upgrade from non-owner
        vm.startPrank(user1);
        vm.expectRevert();
        proxy.upgradeToAndCall(address(implementationV2), "");
        vm.stopPrank();
    }
}
