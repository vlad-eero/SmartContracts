// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {AssetTokenPolicy} from "../src/policy/AssetTokenPolicy.sol";

contract DeployPolicyScript is Script {
    function setUp() public {}

    function run() public {
        address deployer = vm.addr(uint256(vm.envBytes32("PRIVATE_KEY")));
        console.log("Deployer address:", deployer);
        vm.chainId(5777);

        vm.startBroadcast(deployer);

        // Deploy Policy
        console.log("Deploying AssetTokenPolicy...");
        AssetTokenPolicy policy = new AssetTokenPolicy();
        console.log("AssetTokenPolicy deployed at:", address(policy));

        vm.stopBroadcast();
    }
} 