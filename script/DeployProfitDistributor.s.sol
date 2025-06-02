// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {ProfitDistributor} from "../src/profit-distributor/ProfitDistributor.sol";

contract DeployProfitDistributorScript is Script {
    function setUp() public {}

    function run() public {
        address deployer = vm.addr(uint256(vm.envBytes32("PRIVATE_KEY")));
        console.log("Deployer address:", deployer);
        vm.chainId(5777);

        vm.startBroadcast(deployer);

        // Deploy ProfitDistributor
        console.log("Deploying ProfitDistributor...");
        ProfitDistributor profitDistributor = new ProfitDistributor();
        console.log("ProfitDistributor deployed at:", address(profitDistributor));

        vm.stopBroadcast();
    }
}
