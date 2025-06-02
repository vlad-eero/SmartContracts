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
```bash
git clone https://github.com/stefania2001/disertation-app.git
cd disertation-app
```

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
