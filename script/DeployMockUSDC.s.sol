// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ProfitDistributor} from "../src/profit-distributor/ProfitDistributor.sol";

// Simple mock USDC token
contract MockUSDC is ERC20 {
    uint8 private _decimals = 6;
    
    constructor() ERC20("USD Coin", "USDC") {
        // Mint 1,000,000 USDC to the deployer
        _mint(msg.sender, 1000000 * 10**_decimals);
    }
    
    function decimals() public view override returns (uint8) {
        return _decimals;
    }
}

contract DeployMockUSDCScript is Script {
    function setUp() public {}

    function run() public {
        address deployer = vm.addr(uint256(vm.envBytes32("PRIVATE_KEY")));
        console.log("Deployer address:", deployer);
        
        // Get profit distributor address
        address profitDistributorProxy = vm.envAddress("PROFIT_DISTRIBUTOR");
        
        vm.startBroadcast(deployer);
        
        // 1. Deploy mock USDC
        MockUSDC usdc = new MockUSDC();
        console.log("Mock USDC deployed at:", address(usdc));
        
        // 2. Approve profit distributor to spend USDC
        usdc.approve(profitDistributorProxy, type(uint256).max);
        console.log("Approved ProfitDistributor to spend USDC");
        
        vm.stopBroadcast();
        
        // Output the new address for updating .env and contract-addresses.json
        console.log("Update your .env and contract-addresses.json with this new address:");
        console.log("USDC_ADDRESS=", address(usdc));
    }
}