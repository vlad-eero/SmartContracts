// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {AssetTokenPolicy} from "../src/policy/AssetTokenPolicy.sol";

contract ConfigurePolicyScript is Script {
    function setUp() public {}

    function run() public {
        address deployer = vm.addr(uint256(vm.envBytes32("PRIVATE_KEY")));
        console.log("Deployer address:", deployer);
        vm.chainId(5777);

        // Get policy address from environment
        address policyAddress = vm.envAddress("POLICY");
        require(policyAddress != address(0), "Policy address not set");

        vm.startBroadcast(deployer);

        // Configure policy to allow minting and burning
        AssetTokenPolicy policy = AssetTokenPolicy(policyAddress);
        
        // Set mint limit to a high value (1,000,000 tokens)
        policy.setMintLimit(1000000 * 10**18);
        
        // Set burn limit to a high value (1,000,000 tokens)
        policy.setBurnLimit(1000000 * 10**18);
        
        // Allow the deployer address to receive tokens
        policy.setWhitelist(deployer, true);
        
        console.log("Policy configured successfully");

        vm.stopBroadcast();
    }
}