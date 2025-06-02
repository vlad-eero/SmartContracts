// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {AssetToken} from "../src/asset-token/AssetToken.sol";
import {AssetDeployer} from "../src/asset-token/AssetDeployer.sol";

contract DeployAssetTokenScript is Script {
    function setUp() public {}

    function run() public {
        address deployer = vm.addr(uint256(vm.envBytes32("PRIVATE_KEY")));
        console.log("Deployer address:", deployer);
        vm.chainId(5777);

        vm.startBroadcast(deployer);

        // Deploy AssetToken implementation
        console.log("Deploying AssetToken implementation...");
        AssetToken tokenImpl = new AssetToken();
        console.log("AssetToken implementation deployed at:", address(tokenImpl));

        // Deploy AssetDeployer
        console.log("Deploying AssetDeployer...");
        AssetDeployer deployerContract = new AssetDeployer();
        console.log("AssetDeployer deployed at:", address(deployerContract));

        // Deploy proxy via AssetDeployer
        console.log("Deploying AssetToken proxy...");
        address proxy = deployerContract.deployAssetToken(address(tokenImpl), "MyToken", "MTK");
        console.log("AssetToken proxy deployed at:", proxy);

        vm.stopBroadcast();
    }
}
