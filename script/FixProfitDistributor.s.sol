// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {AssetToken} from "../src/asset-token/AssetToken.sol";
import {ProfitDistributor} from "../src/profit-distributor/ProfitDistributor.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract FixProfitDistributorScript is Script {
    function setUp() public {}

    function run() public {
        address deployer = vm.addr(uint256(vm.envBytes32("PRIVATE_KEY")));
        console.log("Deployer address:", deployer);
        
        // Get addresses from environment
        address assetTokenProxy = vm.envAddress("ASSET_TOKEN_PROXY");
        address usdcAddress = vm.envAddress("USDC_ADDRESS");
        
        vm.startBroadcast(deployer);
        
        // 1. Deploy a new ProfitDistributor implementation
        console.log("Deploying new ProfitDistributor implementation...");
        ProfitDistributor implementation = new ProfitDistributor();
        console.log("ProfitDistributor implementation deployed at:", address(implementation));
        
        // 2. Prepare initialization data
        bytes memory initData = abi.encodeWithSelector(
            ProfitDistributor.initialize.selector,
            assetTokenProxy,
            usdcAddress,
            deployer,
            deployer
        );
        
        // 3. Deploy a new proxy
        console.log("Deploying new ProfitDistributor proxy...");
        ERC1967Proxy proxy = new ERC1967Proxy(address(implementation), initData);
        console.log("ProfitDistributor proxy deployed and initialized at:", address(proxy));
        
        // 4. Set the new profit distributor in AssetToken
        console.log("Setting new ProfitDistributor in AssetToken...");
        AssetToken token = AssetToken(assetTokenProxy);
        token.setProfitDistributor(address(proxy));
        console.log("ProfitDistributor set successfully");
        
        vm.stopBroadcast();
        
        // Output the new address for updating .env and contract-addresses.json
        console.log("Update your .env and contract-addresses.json with this new address:");
        console.log("PROFIT_DISTRIBUTOR=", address(proxy));
    }
}