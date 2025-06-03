// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {AssetToken} from "../src/asset-token/AssetToken.sol";
import {AssetTokenPolicy} from "../src/policy/AssetTokenPolicy.sol";
import {ProfitDistributor} from "../src/profit-distributor/ProfitDistributor.sol";

contract ResetAndFixContractsScript is Script {
    function setUp() public {}

    function run() public {
        address deployer = vm.addr(uint256(vm.envBytes32("PRIVATE_KEY")));
        console.log("Deployer address:", deployer);
        
        // Get addresses from environment
        address assetTokenProxy = vm.envAddress("ASSET_TOKEN_PROXY");
        address policyAddress = vm.envAddress("POLICY");
        address profitDistributorProxy = vm.envAddress("PROFIT_DISTRIBUTOR");
        
        vm.startBroadcast(deployer);
        
        // 1. Configure policy
        AssetTokenPolicy policy = AssetTokenPolicy(policyAddress);
        policy.setMintLimit(1000000 * 10**18);
        policy.setBurnLimit(1000000 * 10**18);
        policy.setWhitelist(deployer, true);
        policy.setWhitelist(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266, true);
        policy.setTransferTimelock(0); // No timelock for testing
        console.log("Policy configured");
        
        // 2. Set policy and profit distributor in AssetToken
        AssetToken token = AssetToken(assetTokenProxy);
        token.setPolicy(policyAddress);
        token.setProfitDistributor(profitDistributorProxy);
        console.log("AssetToken configured");
        
        // 3. Mint some tokens to the test address for testing
        try token.mint(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266, 100 * 10**18) {
            console.log("Tokens minted successfully");
        } catch Error(string memory reason) {
            console.log("Mint failed:", reason);
        }
        
        vm.stopBroadcast();
    }
}