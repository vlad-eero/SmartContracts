// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IAssetTokenPolicy {
    function canTransfer(address from, address to, uint256 amount) external view returns (bool);
    function canMint(address to, uint256 amount) external view returns (bool);
    function canBurn(address from, uint256 amount) external view returns (bool);
    function recordReceived(address from, address to) external;
} 