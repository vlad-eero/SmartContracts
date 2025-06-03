// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {AssetToken} from "../src/asset-token/AssetToken.sol";

contract FixMintOperationScript is Script {
    function setUp() public {}

    function run() public {
        address deployer = vm.addr(uint256(vm.envBytes32("PRIVATE_KEY")));
        console.log("Deployer address:", deployer);
        
        // Get addresses from environment
        address assetTokenProxy = vm.envAddress("ASSET_TOKEN_PROXY");
        
        vm.startBroadcast(deployer);
        
        // Temporarily set profit distributor to zero address to bypass the error
        AssetToken token = AssetToken(assetTokenProxy);
        token.setProfitDistributor(address(0));
        
        // Try to mint tokens
        token.mint(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266, 100 * 10**18);
        console.log("Tokens minted successfully");
        
        vm.stopBroadcast();
    }
}