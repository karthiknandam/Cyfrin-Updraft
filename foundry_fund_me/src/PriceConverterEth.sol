// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter { 
    function getPrice(AggregatorV3Interface interfaceVal) internal view returns(uint256){ 
        (,int256 answer , , ,) = interfaceVal.latestRoundData();
        return uint256(answer * 1e18);
    }
    function getConversionRate(uint256 _ethAmout , AggregatorV3Interface interfaceval) internal view returns(uint256){ 
        uint256 price = getPrice(interfaceval);
        uint256 conversionRate = (price * _ethAmout) / 1e18;
        return conversionRate;
    }
}