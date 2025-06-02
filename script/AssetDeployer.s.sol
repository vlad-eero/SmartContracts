// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {AssetToken} from "../src/asset-token/AssetToken.sol";
import {AssetDeployer} from "../src/asset-token/AssetDeployer.sol";
import {AssetTokenPolicy} from "../src/policy/AssetTokenPolicy.sol";
import {ProfitDistributor} from "../src/profit-distributor/ProfitDistributor.sol";

contract AssetDeployerScript is Script {
    function setUp() public {}

    function run() public {
        address setupAddress = vm.addr(uint256(vm.envBytes32("PRIVATE_KEY")));
        console.log("Deployer address:", setupAddress);
        vm.chainId(5777);

        vm.startBroadcast(setupAddress);

        // 1. Deploy Policy
        console.log("Deploying AssetTokenPolicy...");
        AssetTokenPolicy policy = new AssetTokenPolicy();
        console.log("AssetTokenPolicy deployed at:", address(policy));

        // 2. Deploy ProfitDistributor
        console.log("Deploying ProfitDistributor...");
        ProfitDistributor profitDistributor = new ProfitDistributor();
        console.log("ProfitDistributor deployed at:", address(profitDistributor));

        // 3. Deploy AssetToken implementation
        console.log("Deploying AssetToken implementation...");
        AssetToken tokenImpl = new AssetToken();
        console.log("AssetToken implementation deployed at:", address(tokenImpl));

        // 4. Deploy AssetDeployer
        console.log("Deploying AssetDeployer...");
        AssetDeployer deployer = new AssetDeployer();
        console.log("AssetDeployer deployed at:", address(deployer));

        // 5. Deploy proxy via AssetDeployer and set policy and profit distributor
        console.log("Deploying AssetToken proxy...");
        address proxy = deployer.deployAssetToken(
            address(tokenImpl),
            "MyToken",
            "MTK"
        );
        console.log("AssetToken proxy deployed at:", proxy);

        // 6. Set policy and profit distributor in AssetToken
        console.log("Setting policy and profit distributor in AssetToken...");
        AssetToken(proxy).setPolicy(address(policy));
        AssetToken(proxy).setProfitDistributor(address(profitDistributor));
        console.log("Policy and profit distributor set successfully");

        vm.stopBroadcast();
    }
} 