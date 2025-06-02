all:  dependencies
	forge build

dependencies:
	forge install OpenZeppelin/openzeppelin-contracts@v5.0.0
	forge install OpenZeppelin/openzeppelin-contracts-upgradeable@v5.0.0
	forge install foundry-rs/forge-std@v1.7.1

test:
	forge test

clean:
	forge clean
	rm -rf lib/
