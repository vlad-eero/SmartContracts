// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {AssetToken} from "../src/asset-token/AssetToken.sol";

contract SetPolicyAndProfitDistributorScript is Script {
    function setUp() public {}

    function run() public {
        address deployer = vm.addr(uint256(vm.envBytes32("PRIVATE_KEY")));
        console.log("Deployer address:", deployer);
        vm.chainId(5777);

        // Adresele contractelor deployate anterior
        address assetTokenProxy = vm.envAddress("ASSET_TOKEN_PROXY");
        address policy = vm.envAddress("POLICY");
        address profitDistributor = vm.envAddress("PROFIT_DISTRIBUTOR");

        require(assetTokenProxy != address(0), "AssetToken proxy address not set");
        require(policy != address(0), "Policy address not set");
        require(profitDistributor != address(0), "ProfitDistributor address not set");

        vm.startBroadcast(deployer);

        // Set policy and profit distributor in AssetToken
        console.log("Setting policy and profit distributor in AssetToken...");
        AssetToken(assetTokenProxy).setPolicy(policy);
        AssetToken(assetTokenProxy).setProfitDistributor(profitDistributor);
        console.log("Policy and profit distributor set successfully");

        vm.stopBroadcast();
    }
}
