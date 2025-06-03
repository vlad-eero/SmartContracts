// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {AssetTokenPolicy} from "../src/policy/AssetTokenPolicy.sol";

contract WhitelistAddressScript is Script {
    function setUp() public {}

    function run() public {
        address deployer = vm.addr(uint256(vm.envBytes32("PRIVATE_KEY")));
        address policyAddress = vm.envAddress("POLICY");
        address recipient = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
        
        vm.startBroadcast(deployer);
        AssetTokenPolicy policy = AssetTokenPolicy(policyAddress);
        policy.setWhitelist(recipient, true);
        vm.stopBroadcast();
    }
}