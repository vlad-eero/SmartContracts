// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {AssetToken} from "../src/asset-token/AssetToken.sol";

// Mock contract for ProfitDistributor
contract MockProfitDistributor {
    function updateReward(address, address) external pure returns (bool) {
        return true;
    }
}

contract AssetTokenTest is Test {
    AssetToken public assetToken;
    address public owner;
    address public addr1;
    address public addr2;
    uint256 public constant INITIAL_SUPPLY = 1_000_000; // 1 million tokens

       event Mint(address indexed to, uint256 amount);
    /// @notice Emitted when tokens are burned
    event Burn(address indexed from, uint256 amount);
    event ProfitDistributorRewardUpdated(address indexed from, address indexed to, uint256 amount);

    function setUp() public {
        // Setăm adresele de test
        owner = makeAddr("owner");
        addr1 = makeAddr("addr1");
        addr2 = makeAddr("addr2");

        // Deployăm contractul ca owner
        vm.startPrank(owner);
        assetToken = new AssetToken();
        assetToken.initialize("Test Token", "TEST", owner);
        vm.stopPrank();
    }

    // Test pentru inițializare
    function test_Initialization() public {
        assertEq(assetToken.name(), "Test Token");
        assertEq(assetToken.symbol(), "TEST");
        assertEq(assetToken.balanceOf(owner), 0);
    }

    // Test pentru funcționalitatea de mint
    function test_Mint() public {
        uint256 mintAmount = 1000;
        
        // Test mint ca owner
        vm.startPrank(owner);
        vm.expectEmit(true, true, true, true);
        emit Mint(addr1, mintAmount * 10 ** 18);
        assetToken.mint(addr1, mintAmount * 10 ** 18);
        assertEq(assetToken.balanceOf(addr1), mintAmount * 10 ** 18);
        vm.stopPrank();

        // Test mint ca non-owner (ar trebui să eșueze)
        vm.startPrank(addr1);
        vm.expectRevert();
        assetToken.mint(addr2, mintAmount);
        vm.stopPrank();
    }

    // Test pentru funcționalitatea de burn
    function test_Burn() public {
        uint256 burnAmount = 1000;
        
        // Mint tokens pentru addr1
        vm.startPrank(owner);
        assetToken.mint(addr1, burnAmount);
        vm.stopPrank();

        // Test burn ca owner
        vm.startPrank(owner);
        vm.expectEmit(true, true, true, true);
        emit Burn(addr1, burnAmount);
        assetToken.burn(addr1, burnAmount);
        assertEq(assetToken.balanceOf(addr1), 0);
        vm.stopPrank();

        // Test burn ca non-owner (ar trebui să eșueze)
        vm.startPrank(addr1);
        vm.expectRevert();
        assetToken.burn(addr2, burnAmount);
        vm.stopPrank();
    }

    // Test pentru setarea ProfitDistributor
    function test_SetProfitDistributor() public {
        // Test setare ca owner
        vm.startPrank(owner);
        assetToken.setProfitDistributor(addr1);
        assertEq(assetToken.profitDistributor(), addr1);
        vm.stopPrank();

        // Test setare ca non-owner (ar trebui să eșueze)
        vm.startPrank(addr1);
        vm.expectRevert();
        assetToken.setProfitDistributor(addr2);
        vm.stopPrank();
    }

    // Test pentru setarea Policy
    function test_SetPolicy() public {
        // Test setare ca owner
        vm.startPrank(owner);
        assetToken.setPolicy(addr1);
        assertEq(address(assetToken.policy()), addr1);
        vm.stopPrank();

        // Test setare ca non-owner (ar trebui să eșueze)
        vm.startPrank(addr1);
        vm.expectRevert();
        assetToken.setPolicy(addr2);
        vm.stopPrank();
    }

    // Test pentru ProfitDistributor
    function test_ProfitDistributor() public {
        // Create a mock ProfitDistributor contract that implements updateReward
        MockProfitDistributor mockProfitDistributor = new MockProfitDistributor();
        
        // Test transfer cu ProfitDistributor setat
        vm.startPrank(owner);
        assetToken.setProfitDistributor(address(mockProfitDistributor));
        uint256 transferAmount = 1000;
        assetToken.mint(owner, transferAmount);
        
        // Transferăm tokens către addr2
        vm.expectEmit(true, true, true, true);
        emit ProfitDistributorRewardUpdated(owner, addr2, transferAmount);
        assetToken.transfer(addr2, transferAmount);
        
        // Verificăm că ProfitDistributor a fost notificat
        assertEq(assetToken.profitDistributor(), address(mockProfitDistributor));
        vm.stopPrank();
    }

    function test_ProfitDistributorUpdate() public {
        // Test actualizare ProfitDistributor
        vm.startPrank(owner);
        assetToken.setProfitDistributor(addr1);
        assertEq(assetToken.profitDistributor(), addr1);
        
        // Actualizăm ProfitDistributor
        assetToken.setProfitDistributor(addr2);
        assertEq(assetToken.profitDistributor(), addr2);
        vm.stopPrank();
    }

    function test_ProfitDistributorUnauthorized() public {
        // Test setare ProfitDistributor de către non-owner
        vm.startPrank(addr1);
        vm.expectRevert();
        assetToken.setProfitDistributor(addr2);
        vm.stopPrank();
    }
} 