-include .env
build:
	forge build
deploy-sepholia:
	forge script script/FundeMe.s.sol:FundMeDeploy --rpc-url $(SEPHOLIA_TESTNET) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHSCAN_API_KEY) -vvvv
print-key:
	echo $(PRIVATE_KEY)