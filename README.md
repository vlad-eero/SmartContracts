# Solidity Smart Contracts

## Installation

1. Clone the repository:

2. Install dependencies:

The system uses the following main dependencies:

```bash
# OpenZeppelin Contracts
@openzeppelin/contracts ^5.0.0
@openzeppelin/contracts-upgradeable ^5.0.0

# Forge for development and testing
forge-std ^1.7.1
```

```bash
forge install
```

3. Compile contracts:

```bash
forge build
```

## Project Structure

```
disertation-app/
├── src/
│   ├── asset-token/         # Token contracts
│   ├── profit-distributor/  # Profit distribution contracts
│   └── policy/             # Transfer policy contracts
├── test/                   # Tests for all contracts
├── script/                 # Deployment scripts
```

## Testing

The system includes a comprehensive test suite covering all functionalities:

1. **Unit Tests**

```bash
# Run all tests
forge test

# Run tests with details
forge test -vv

# Run a specific test
forge test --match-test test_DeployAssetToken
```

# Project Notes

This project implements a tokenized asset system with profit distribution capabilities. It consists of three main components:

## 1. Asset Token System

### AssetToken.sol

An upgradeable ERC20 token that represents ownership of an asset

Implements the UUPS (Universal Upgradeable Proxy Standard) pattern for upgradeability

Key features:

- Controlled minting and burning (only by owner)
- Integration with a policy system that enforces transfer rules
- Connection to a profit distributor that tracks token movements for reward calculations
- Events for tracking mints, burns, and profit distributor updates

### AssetTokenProxy.sol

A simple proxy contract that delegates calls to the implementation contract

Uses OpenZeppelin's ERC1967Proxy as its base

### AssetDeployer.sol

Factory contract for deploying new asset tokens

Creates proxy instances pointing to an implementation contract

Initializes tokens with name, symbol, and owner

## 2. Policy System

### IAssetTokenPolicy.sol

Interface defining the policy rules for token operations

Defines methods for checking if transfers, mints, and burns are allowed

### AssetTokenPolicy.sol

Implementation of the policy interface with specific rules:

- Whitelist system for controlling who can receive tokens
- Time-lock mechanism preventing transfers within 24 hours of receiving tokens
- Configurable limits for minting and burning
- Owner can adjust all policy parameters

## 3. Profit Distribution System

### ProfitDistributor.sol

Distributes USDC profits to token holders proportionally to their holdings

Key features:

- Tracks profit per token with high precision (1e18)
- Allows an authorized depositor to add profits
- Users can claim their share of profits
- Automatically updates reward accounting when tokens are transferred
- Upgradeable using UUPS pattern

### ProfitDistributorProxy.sol

Similar to AssetTokenProxy, delegates calls to the implementation

### ProfitDistributorDeployer.sol

Factory for deploying profit distributor instances

Creates and initializes proxy contracts

# How It All Works Together

## Token Creation

The AssetDeployer creates a new token through a proxy pointing to the AssetToken implementation.

## Policy Enforcement:

The token owner sets a policy contract that enforces rules on transfers:

- Only whitelisted addresses can receive tokens
- Transfers are time-locked (24 hours by default)
- Minting and burning can be limited

## Profit Distribution:

- The token is connected to a ProfitDistributor contract
- When tokens are transferred, the distributor updates reward accounting
- An authorized depositor can add USDC profits to the distributor
- Token holders can claim their share of profits proportional to their holdings

### Upgradeability

Both the token and profit distributor use the UUPS pattern, allowing their logic to be upgraded while preserving state and addresses.

# Technical Highlights

## Proxy Pattern

Uses OpenZeppelin's ERC1967 proxy implementation for upgradeability

## Security Features

- Reentrancy protection in the profit distributor
- Owner-only access control for sensitive operations
- Policy-based transfer restrictions

## High Precision

Uses 1e18 precision for accurate profit calculations

## Event Logging

Comprehensive events for tracking all important operations

This system could be used for tokenizing real-world assets (like real estate or art) while distributing profits (like rental income or royalties) to token holders in a transparent and automated way

# Setup and running

## 1. Install foundryup

```
curl -L https://foundry.paradigm.xyz | bash
source ~/.bashrc
foundryup
```

```
.xOx.xOx.xOx.xOx.xOx.xOx.xOx.xOx.xOx.xOx.xOx.xOx.xOx.xOx.xOx.xOx.xOx.xOx

 ╔═╗ ╔═╗ ╦ ╦ ╔╗╔ ╔╦╗ ╦═╗ ╦ ╦         Portable and modular toolkit
 ╠╣  ║ ║ ║ ║ ║║║  ║║ ╠╦╝ ╚╦╝    for Ethereum Application Development
 ╚   ╚═╝ ╚═╝ ╝╚╝ ═╩╝ ╩╚═  ╩                 written in Rust.

.xOx.xOx.xOx.xOx.xOx.xOx.xOx.xOx.xOx.xOx.xOx.xOx.xOx.xOx.xOx.xOx.xOx.xOx

Repo       : https://github.com/foundry-rs/foundry
Book       : https://book.getfoundry.sh/
Chat       : https://t.me/foundry_rs/
Support    : https://t.me/foundry_support/
Contribute : https://github.com/foundry-rs/foundry/blob/master/CONTRIBUTING.md

.xOx.xOx.xOx.xOx.xOx.xOx.xOx.xOx.xOx.xOx.xOx.xOx.xOx.xOx.xOx.xOx.xOx.xOx

foundryup: installing foundry (version stable, tag stable)
foundryup: downloading forge, cast, anvil, and chisel for stable version
############################################################################################################################################################################################################################### 100.0%
forge
cast
anvil
chisel
foundryup: downloading manpages
############################################################################################################################################################################################################################### 100.0%
foundryup: use - forge 1.2.2-dev (73ac79f067 2025-06-01T14:56:28.997274444Z)
foundryup: warning:
There are multiple binaries with the name 'forge' present in your 'PATH'.
This may be the result of installing 'forge' using another method,
like Cargo or other package managers.
You may need to run 'rm /usr/local/bin/forge' or move '/root/.foundry/bin'
in your 'PATH' to allow the newly installed version to take precedence!

foundryup: use - cast 1.2.2-dev (73ac79f067 2025-06-01T14:56:28.997274444Z)
foundryup: warning:
There are multiple binaries with the name 'cast' present in your 'PATH'.
This may be the result of installing 'cast' using another method,
like Cargo or other package managers.
You may need to run 'rm /usr/local/bin/cast' or move '/root/.foundry/bin'
in your 'PATH' to allow the newly installed version to take precedence!

foundryup: use - anvil 1.2.2-dev (73ac79f067 2025-06-01T14:56:28.997274444Z)
foundryup: warning:
There are multiple binaries with the name 'anvil' present in your 'PATH'.
This may be the result of installing 'anvil' using another method,
like Cargo or other package managers.
You may need to run 'rm /usr/local/bin/anvil' or move '/root/.foundry/bin'
in your 'PATH' to allow the newly installed version to take precedence!

foundryup: use - chisel 1.2.2-dev (73ac79f067 2025-06-01T14:56:28.997274444Z)
foundryup: warning:
There are multiple binaries with the name 'chisel' present in your 'PATH'.
This may be the result of installing 'chisel' using another method,
like Cargo or other package managers.
You may need to run 'rm /usr/local/bin/chisel' or move '/root/.foundry/bin'
in your 'PATH' to allow the newly installed version to take precedence!
```

## 2. Compile contracts

`forge build`

## 3. Deploy the contracts to a blockchain (local or testnet):

### For local development with Anvil (Foundry's local blockchain)

`anvil`

```
                             _   _
                            (_) | |
      __ _   _ __   __   __  _  | |
     / _` | | '_ \  \ \ / / | | | |
    | (_| | | | | |  \ V /  | | | |
     \__,_| |_| |_|   \_/   |_| |_|

    1.0.0-nightly (25c363e072 2025-04-09T11:59:25.054235703Z)
    https://github.com/foundry-rs/foundry

Available Accounts
==================

(0) 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 (10000.000000000000000000 ETH)
(1) 0x70997970C51812dc3A010C7d01b50e0d17dc79C8 (10000.000000000000000000 ETH)
(2) 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC (10000.000000000000000000 ETH)
(3) 0x90F79bf6EB2c4f870365E785982E1f101E93b906 (10000.000000000000000000 ETH)
(4) 0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65 (10000.000000000000000000 ETH)
(5) 0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc (10000.000000000000000000 ETH)
(6) 0x976EA74026E726554dB657fA54763abd0C3a0aa9 (10000.000000000000000000 ETH)
(7) 0x14dC79964da2C08b23698B3D3cc7Ca32193d9955 (10000.000000000000000000 ETH)
(8) 0x23618e81E3f5cdF7f54C3d65f7FBc0aBf5B21E8f (10000.000000000000000000 ETH)
(9) 0xa0Ee7A142d267C1f36714E4a8F75612F20a79720 (10000.000000000000000000 ETH)

Private Keys
==================

(0) 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
(1) 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d
(2) 0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a
(3) 0x7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6
(4) 0x47e179ec197488593b187f80a00eb0da91f1b9d0b13f8733639f19c30a34926a
(5) 0x8b3a350cf5c34c9194ca85829a2df0ec3153be0318b5e2d3348e872092edffba
(6) 0x92db14e403b83dfe3df233f83dfa3a0d7096f21ca9b0d6d6b8d88b2b4ec1564e
(7) 0x4bbbf85ce3377467afe5d46f804f221813b2bb87f24d81f60f1fcdbf7cbf4356
(8) 0xdbda1821b80551c9d65939329250298aa3472ba22feea921c0cf5d620ea67b97
(9) 0x2a871d0798f97d79848a013d4936a73bf4cc922c825d33c1cf7073dff6d409c6

Wallet
==================
Mnemonic:          test test test test test test test test test test test junk
Derivation path:   m/44'/60'/0'/0/


Chain ID
==================

31337

Base Fee
==================

1000000000

Gas Limit
==================

30000000

Genesis Timestamp
==================

1748938207

Genesis Number
==================

0

Listening on 127.0.0.1:8545
```

### In a new terminal, deploy the contracts

```
forge script script/DeployAssetToken.s.sol --rpc-url http://localhost:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast
forge script script/DeployPolicy.s.sol --rpc-url http://localhost:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast
forge script script/DeployProfitDistributor.s.sol --rpc-url http://localhost:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast
forge script script/ConfigurePolicy.s.sol --rpc-url http://localhost:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast
forge script script/SetPolicyAndProfitDistributor.s.sol --rpc-url http://localhost:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast
```

update `.env` and `contract-addresses.json` cu noile adrese

```
##### anvil-hardhat
✅  [Success] Hash: 0xf0f2c72c77a3ab994f8bb03bf27b412593faccc3e078ce790a17561f80898bb8
Contract Address: 0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9
Block: 5
Paid: 0.002522375095577566 ETH (1204186 gas * 2.094672331 gwei)


##### anvil-hardhat
✅  [Success] Hash: 0x5d8735911961750af2f4814fdabdd9fdc0cbef7673a95ae2cb24532b66bb60fa
Contract Address: 0x5FC8d32690cc91D4c39d9d3abcBD16989F875707
Block: 6
Paid: 0.000547349763962476 ETH (270122 gas * 2.026305758 gwei)

✅ Sequence #1 on anvil-hardhat | Total Paid: 0.003069724859540042 ETH (1474308 gas * avg 2.060489044 gwei)
```

`PROFIT_DISTRIBUTOR=0x5FC8d32690cc91D4c39d9d3abcBD16989F875707`

`"profitDistributorProxy": "0x5FC8d32690cc91D4c39d9d3abcBD16989F875707"`

or use `node deploy.js` - NOT WORKING !!!

### Set up the proxies for upgradeable contracts

Save all contract addresses to contract-addresses.json

## Start the Web API

Once the contracts are deployed, start the API server:

`node api.js`

The API will be available at http://localhost:3000.

### Example Usage with curl

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

# API Endpoints

## Token Information

- GET `/api/token/info` - Get token name, symbol, and total supply

## Mint Tokens

- POST `/api/token/mint` - Mint new tokens
  ```json
  {
    "address": "0xYourAddress",
    "amount": "100"
  }
  ```

## Deposit Profit

- POST `/api/profit/deposit` - Deposit profit for distribution
  ```json
  {
    "amount": "10"
  }
  ```

## Check Earned Profit

- GET `/api/profit/earned/:address` - Check how much profit an address has earned

## Claim Profit

- POST `/api/profit/claim` - Claim profit for an address
  ```json
  {
    "address": "0xYourAddress"
  }
  ```
