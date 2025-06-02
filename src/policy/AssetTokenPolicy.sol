// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IAssetTokenPolicy.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AssetTokenPolicy is IAssetTokenPolicy, Ownable {
    constructor() Ownable(msg.sender) {}

    mapping(address => bool) public whitelist;
    uint256 public mintLimit;
    uint256 public burnLimit;
    mapping(address => uint256) public minted;
    mapping(address => uint256) public burned;
    mapping(address => uint256) public lastReceived;
    uint256 public transferTimelock = 24 hours;

    event Whitelisted(address indexed account, bool whitelisted);
    event MintLimitSet(uint256 limit);
    event BurnLimitSet(uint256 limit);
    event TransferTimelockSet(uint256 timelock);

    function setWhitelist(address account, bool value) external onlyOwner {
        whitelist[account] = value;
        emit Whitelisted(account, value);
    }

    function setMintLimit(uint256 limit) external onlyOwner {
        mintLimit = limit;
        emit MintLimitSet(limit);
    }

    function setBurnLimit(uint256 limit) external onlyOwner {
        burnLimit = limit;
        emit BurnLimitSet(limit);
    }

    function setTransferTimelock(uint256 timelock) external onlyOwner {
        transferTimelock = timelock;
        emit TransferTimelockSet(timelock);
    }

    // Apelată de AssetToken la fiecare transfer
    function canTransfer(address from, address to, uint256) external view override returns (bool) {
        if (!whitelist[to]) return false;
        if (from == address(0) || to == address(0)) return true; // mint/burn
        if (block.timestamp < lastReceived[from] + transferTimelock) return false;
        return true;
    }

    // Apelată de AssetToken la mint
    function canMint(address to, uint256 amount) external view override returns (bool) {
        if (mintLimit == 0) return true;
        return minted[to] + amount <= mintLimit;
    }

    // Apelată de AssetToken la burn
    function canBurn(address from, uint256 amount) external view override returns (bool) {
        if (burnLimit == 0) return true;
        return burned[from] + amount <= burnLimit;
    }

    // Trebuie apelată de AssetToken după fiecare transfer pentru time lock
    function recordReceived(address from, address to) external {
        if (from != address(0) && to != address(0)) {
            lastReceived[to] = block.timestamp;
        }
    }

    // Pentru test/demo: reset counters
    function resetMinted(address to) external onlyOwner { minted[to] = 0; }
    function resetBurned(address from) external onlyOwner { burned[from] = 0; }
} 