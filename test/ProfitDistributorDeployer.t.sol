// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {ProfitDistributorDeployer} from "../src/profit-distributor/ProfitDistributorDeployer.sol";
import {ProfitDistributor} from "../src/profit-distributor/ProfitDistributor.sol";
import {MockERC20} from "./MockERC20.sol";

contract ProfitDistributorDeployerTest is Test {
    ProfitDistributorDeployer public deployer;
    ProfitDistributor public implementation;
    MockERC20 public shares;
    MockERC20 public usdc;
    address public owner;
    address public profitDepositor;

    function setUp() public {
        owner = makeAddr("owner");
        profitDepositor = makeAddr("profitDepositor");

        // Deploy mock tokens
        shares = new MockERC20("Shares", "SHR", 18);
        usdc = new MockERC20("USDC", "USDC", 6);

        // Deploy implementation and deployer
        implementation = new ProfitDistributor();
        deployer = new ProfitDistributorDeployer();
    }

    function test_DeployProfitDistributor() public {
        vm.startPrank(owner);

        // Deploy new ProfitDistributor
        address proxyAddress =
            deployer.deployProfitDistributor(address(implementation), address(shares), address(usdc), profitDepositor);

        // Verify proxy was created correctly
        ProfitDistributor proxy = ProfitDistributor(proxyAddress);
        assertEq(address(proxy.shares()), address(shares));
        assertEq(address(proxy.usdc()), address(usdc));
        assertEq(proxy.profitDepositor(), profitDepositor);
        assertEq(proxy.owner(), owner);
        vm.stopPrank();
    }

    function test_DeployProfitDistributorWithInvalidImplementation() public {
        vm.startPrank(owner);
        vm.expectRevert();
        deployer.deployProfitDistributor(address(0), address(shares), address(usdc), profitDepositor);
        vm.stopPrank();
    }

    function test_DeployProfitDistributorWithInvalidTokens() public {
        vm.startPrank(owner);
        vm.expectRevert();
        deployer.deployProfitDistributor(address(implementation), address(0), address(usdc), profitDepositor);
        vm.stopPrank();
    }

    // Fuzzing tests
    function testFuzz_DeployProfitDistributor(address sharesAddr, address usdcAddr, address depositor) public {
        vm.assume(sharesAddr != address(0));
        vm.assume(usdcAddr != address(0));
        vm.assume(depositor != address(0));

        vm.startPrank(owner);
        address proxyAddress =
            deployer.deployProfitDistributor(address(implementation), sharesAddr, usdcAddr, depositor);

        ProfitDistributor proxy = ProfitDistributor(proxyAddress);
        assertEq(address(proxy.shares()), sharesAddr);
        assertEq(address(proxy.usdc()), usdcAddr);
        assertEq(proxy.profitDepositor(), depositor);
        vm.stopPrank();
    }
}
