// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./AssetTokenProxy.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AssetDeployer is Ownable {
    constructor() Ownable(msg.sender) {}

    event ProxyDeployed(address proxy, address implementation);

    function deployAssetToken(address implementation, string memory name, string memory symbol) external onlyOwner returns (address) {
        bytes memory data = abi.encodeWithSignature(
            "initialize(string,string,address)",
            name,
            symbol,
            msg.sender
        );
        AssetTokenProxy proxy = new AssetTokenProxy(implementation, data);
        emit ProxyDeployed(address(proxy), implementation);
        return address(proxy);
    }
}

