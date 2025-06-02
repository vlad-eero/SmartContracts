// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ProfitDistributorProxy.sol";

contract ProfitDistributorDeployer {
    event ProxyDeployed(address proxy, address implementation);

    function deployProfitDistributor(address implementation, address shares, address usdc, address profitDepositor)
        external
        returns (address)
    {
        bytes memory data = abi.encodeWithSignature(
            "initialize(address,address,address,address)", shares, usdc, profitDepositor, msg.sender
        );
        ProfitDistributorProxy proxy = new ProfitDistributorProxy(implementation, data);
        emit ProxyDeployed(address(proxy), implementation);
        return address(proxy);
    }
}
