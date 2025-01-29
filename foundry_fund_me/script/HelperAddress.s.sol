// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "test/mock/MockAggregatorV3.sol";
contract HelperAddress is Script{ 
    NetworkConfig public activeAdress;
    uint8 private constant DECIMAL = 8;
    int256 private constant  INTIAL_ANSWER = 2000e8;
    struct NetworkConfig { 
        address payingChain;
    }

    constructor() { 
        if(block.chainid == 11155111){ 
            activeAdress = getSepholiaEthAdress();
        }else if (block.chainid == 1) {
            activeAdress = getEthMainNetAdress();
        }else{ 
            activeAdress = getOrSetAlchemyEthAdress();
        }
    }

    function getSepholiaEthAdress() public pure returns(NetworkConfig memory){
        NetworkConfig memory networkConfig = NetworkConfig({ 
            payingChain : 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return networkConfig;
    } 

    function getEthMainNetAdress() public pure returns(NetworkConfig memory){
        NetworkConfig memory networkConfig = NetworkConfig({ 
            payingChain : 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return networkConfig;
    }
    function getOrSetAlchemyEthAdress() public returns(NetworkConfig memory){ 
        if(activeAdress.payingChain != address(0)){ 
            return activeAdress;
        }
        // Mock adress goes into here;
        vm.startBroadcast();
        MockV3Aggregator newMock = new MockV3Aggregator(DECIMAL , INTIAL_ANSWER);
        vm.stopBroadcast();
        NetworkConfig memory networkConfig = NetworkConfig({ 
            payingChain : address(newMock)
        });
        return networkConfig;
    }

}