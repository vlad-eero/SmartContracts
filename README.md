# disertation-app
## Dependencies

The system uses the following main dependencies:

```bash
# OpenZeppelin Contracts
@openzeppelin/contracts ^5.0.0
@openzeppelin/contracts-upgradeable ^5.0.0

# Forge for development and testing
forge-std ^1.7.1
```

## Installation

1. Clone the repository:


2. Install dependencies:
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