// SPDX-License-Identifier : MIT
pragma solidity ^0.8.19;

import {Script , console} from "forge-std/Script.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";

import {FundMe} from "src/FundMe.sol";


contract FundFundMe is Script { 
    uint256 constant SEND_VALUE = 0.01 ether;
        function fundFundMe (address mostRecentAddressDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentAddressDeployed)).fund{value : SEND_VALUE}();
        vm.stopBroadcast();
    }
    function run() external{ 
        address mostRecentAddressDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        console.log("Most recent deployed address:", mostRecentAddressDeployed);
        fundFundMe(mostRecentAddressDeployed);
    }

}
contract WithdrawFundMe is Script {
    function withdrawFundMe(address mostRecentAddressDeployed)public{
        vm.startBroadcast(); 
        FundMe(payable(mostRecentAddressDeployed)).Withdraw();
        vm.stopBroadcast();
    } 
    function run() external{ 
        address mostRecentAddressDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        withdrawFundMe(mostRecentAddressDeployed);
    }
}

