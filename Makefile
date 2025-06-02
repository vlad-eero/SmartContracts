.PHONY: all test clean lint
# The .PHONY directive tells Make that test is not a real file target, 
# so Make should run the commands every time, regardless of whether a 
# file named "test" exists or what its timestamp is.

all:  dependencies
	forge build

dependencies:
	forge install OpenZeppelin/openzeppelin-contracts@v5.0.0
	forge install OpenZeppelin/openzeppelin-contracts-upgradeable@v5.0.0
	forge install foundry-rs/forge-std@v1.7.1

lint:
	forge fmt

test:
	forge test -vv

clean:
	forge clean
	rm -rf lib/

install:
	forge install
