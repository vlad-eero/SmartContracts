# Terminal 1

`anvil`

# Terminal 2

`node deploy.js`

```
Deploying contracts from 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
Deploying AssetToken implementation...
AssetToken implementation deployed at: 0x5FbDB2315678afecb367f032d93F642f64180aa3
Deploying AssetToken proxy...
AssetToken proxy deployed at: 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
Deploying AssetTokenPolicy...
AssetTokenPolicy deployed at: 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0
Deploying ProfitDistributor implementation...
ProfitDistributor implementation deployed at: 0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9
Deploying ProfitDistributor proxy...
ProfitDistributor proxy deployed at: 0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9
Setting policy and profit distributor in AssetToken...
Policy and profit distributor set successfully
Contract addresses saved to contract-addresses.json
```

`node api.js`

```
API server running on port 3000
```

# Terminal 3

#### Get token info

```
curl http://localhost:3000/api/token/info
```

```
{"name":"MyToken","symbol":"MTK","totalSupply":"0.0"}
```

#### Mint tokens

```
curl -X POST http://localhost:3000/api/token/mint \
 -H "Content-Type: application/json" \
 -d '{"address":"0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266","amount":"100"}'
```

Success

```
{
   "success":true,
   "txHash":"0x7ead15bf9cd86cbb0f61e90c6218e41955a49d4a691dd0a7ea3470e2a267b57e",
   "message":"Minted 100 tokens to 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"
}
```

Error on policy address

```
{
  "error": "cannot estimate gas; transaction may fail or may require manual gas limit [ See: https://links.ethers.org/v5-errors-UNPREDICTABLE_GAS_LIMIT ] (error={\"reason\":\"execution reverted\",\"code\":\"UNPREDICTABLE_GAS_LIMIT\",\"method\":\"estimateGas\",\"transaction\":{\"from\":\"0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266\",\"maxPriorityFeePerGas\":{\"type\":\"BigNumber\",\"hex\":\"0x59682f00\"},\"maxFeePerGas\":{\"type\":\"BigNumber\",\"hex\":\"0x9110bf6a\"},\"to\":\"0xCafac3dD18aC6c6e92c921884f9E4176737C052c\",\"data\":\"0x40c10f19000000000000000000000000f39fd6e51aad88f6f4ce6ab8827279cfffb922660000000000000000000000000000000000000000000000056bc75e2d63100000\",\"type\":2,\"accessList\":null},\"error\":{\"reason\":\"processing response error\",\"code\":\"SERVER_ERROR\",\"body\":\"{\\\"jsonrpc\\\":\\\"2.0\\\",\\\"id\\\":83,\\\"error\\\":{\\\"code\\\":3,\\\"message\\\":\\\"execution reverted\\\",\\\"data\\\":\\\"0x\\\"}}\",\"error\":{\"code\":3,\"data\":\"0x\"},\"requestBody\":\"{\\\"method\\\":\\\"eth_estimateGas\\\",\\\"params\\\":[{\\\"type\\\":\\\"0x2\\\",\\\"maxFeePerGas\\\":\\\"0x9110bf6a\\\",\\\"maxPriorityFeePerGas\\\":\\\"0x59682f00\\\",\\\"from\\\":\\\"0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266\\\",\\\"to\\\":\\\"0xcafac3dd18ac6c6e92c921884f9e4176737c052c\\\",\\\"data\\\":\\\"0x40c10f19000000000000000000000000f39fd6e51aad88f6f4ce6ab8827279cfffb922660000000000000000000000000000000000000000000000056bc75e2d63100000\\\"}],\\\"id\\\":83,\\\"jsonrpc\\\":\\\"2.0\\\"}\",\"requestMethod\":\"POST\",\"url\":\"http://localhost:8545\"}}, tx={\"data\":\"0x40c10f19000000000000000000000000f39fd6e51aad88f6f4ce6ab8827279cfffb922660000000000000000000000000000000000000000000000056bc75e2d63100000\",\"to\":{},\"from\":\"0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266\",\"type\":2,\"maxFeePerGas\":{\"type\":\"BigNumber\",\"hex\":\"0x9110bf6a\"},\"maxPriorityFeePerGas\":{\"type\":\"BigNumber\",\"hex\":\"0x59682f00\"},\"nonce\":{},\"gasLimit\":{},\"chainId\":{}}, code=UNPREDICTABLE_GAS_LIMIT, version=abstract-signer/5.8.0)"
}
```

#### Deposit profit

```
curl -X POST http://localhost:3000/api/profit/deposit \
 -H "Content-Type: application/json" \
 -d '{"amount":"10"}'
```

```
{
   "success":true,
   "txHash":"0xefe5f80c0866631fd1d3f53950a16be4039f2f07a0caee598b7d2b524ba37953",
   "message":"Deposited 10 USDC as profit"
}
```

```
{
   "success":false,
   "error":"transaction failed [ See: https://links.ethers.org/v5-errors-CALL_EXCEPTION ] (

    transactionHash=\"0xc2465dacc1df8961ee98f215bdcc2329b1b4b047cf7895b5d48e01e414c55f55\",
    transaction={\"type\":2,\"chainId\":31337,\"nonce\":16,\"maxPriorityFeePerGas\":{\"type\":\"BigNumber\",\"hex\":\"0x59682f00\"},\"maxFeePerGas\":{\"type\":\"BigNumber\",\"hex\":\"0x6abf1ac0\"},\"gasPrice\":null,\"gasLimit\":{\"type\":\"BigNumber\",\"hex\":\"0x07a120\"},\"to\":\"0xB7f8BC63BbcaD18155201308C8f3540b07f84F5e\",\"value\":{\"type\":\"BigNumber\",\"hex\":\"0x00\"},\"data\":\"0x33c19ab00000000000000000000000000000000000000000000000000000000000989680\",\"accessList\":[],\"hash\":\"0xc2465dacc1df8961ee98f215bdcc2329b1b4b047cf7895b5d48e01e414c55f55\",\"v\":1,\"r\":\"0x7a79e544245e9b499acb85e2f0373368324200bde4a456432a8fc6f1012340c7\",\"s\":\"0x5fecb1f39e5ca201474a16966dc47550bfe9452996e2c48f12c49e4a0970392d\",\"from\":\"0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266\",\"confirmations\":0}, receipt={\"to\":\"0xB7f8BC63BbcaD18155201308C8f3540b07f84F5e\",\"from\":\"0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266\",\"contractAddress\":null,\"transactionIndex\":0,\"gasUsed\":{\"type\":\"BigNumber\",\"hex\":\"0xc762\"},\"logsBloom\":\"0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000\",\"blockHash\":\"0xb6fe8793ccb490b8988836c3f3860b35452b4cb68f750dc156cd8a2a51a5e953\",\"transactionHash\":\"0xc2465dacc1df8961ee98f215bdcc2329b1b4b047cf7895b5d48e01e414c55f55\",\"logs\":[],\"blockNumber\":17,\"confirmations\":1,\"cumulativeGasUsed\":{\"type\":\"BigNumber\",\"hex\":\"0xc762\"},\"effectiveGasPrice\":{\"type\":\"BigNumber\",\"hex\":\"0x60ff27d2\"},\"status\":0,\"type\":2,\"byzantium\":true},

   code=CALL_EXCEPTION,
   version=providers/5.8.0)"
}
```

#### Check earned profit

```
curl http://localhost:3000/api/profit/earned/0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
```

Error

```
{
   "address":"0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
   "earned":"0.0",
   "status":"Error calculating earned amount",
   "error":"call revert exception [ See: https://links.ethers.org/v5-errors-CALL_EXCEPTION ] (method=\"earned(address)\", data=\"0x\", errorArgs=null, errorName=null, errorSignature=null, reason=null, code=CALL_EXCEPTION, version=abi/5.8.0)",
   "details":"Error: call revert exception [ See: https://links.ethers.org/v5-errors-CALL_EXCEPTION ] (method=\"earned(address)\", data=\"0x\", errorArgs=null, errorName=null, errorSignature=null, reason=null, code=CALL_EXCEPTION, version=abi/5.8.0)\n    at Logger.makeError (/workspaces/disertation-app-main/node_modules/@ethersproject/logger/lib/index.js:238:21)\n    at Logger.throwError (/workspaces/disertation-app-main/node_modules/@ethersproject/logger/lib/index.js:247:20)\n    at Interface.decodeFunctionResult (/workspaces/disertation-app-main/node_modules/@ethersproject/abi/lib/interface.js:388:23)\n    at Contract.<anonymous> (/workspaces/disertation-app-main/node_modules/@ethersproject/contracts/lib/index.js:395:56)\n    at step (/workspaces/disertation-app-main/node_modules/@ethersproject/contracts/lib/index.js:48:23)\n    at Object.next (/workspaces/disertation-app-main/node_modules/@ethersproject/contracts/lib/index.js:29:53)\n    at fulfilled (/workspaces/disertation-app-main/node_modules/@ethersproject/contracts/lib/index.js:20:58)\n    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)"
}
```

#### Claim profit

```
curl -X POST http://localhost:3000/api/profit/claim \
 -H "Content-Type: application/json" \
 -d '{"address":"0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"}'
```

```
{
  "success":true,
  "txHash":"0x0000000000000000000000000000000000000000000000000000000000000000",
  "message":"Claimed profit for 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 (mock)",
  "status":"Contract not fully initialized"
}
```
