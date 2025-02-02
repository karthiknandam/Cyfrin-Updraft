// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {Script , console} from "forge-std/Script.sol";
import {HelperConfig , ConstantVarible} from "./HelperConfig.s.sol";
import {LinkToken} from "test/mocks/LinkMocks.t.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
contract CreateSubscription is Script{ 
    function createSubscriptionUser() public returns(uint256 , address){ 
        HelperConfig helperConfig = new HelperConfig();
        address vrfCoordinator = helperConfig.getConfig().vrfCoordinator;
        address playerAddress = helperConfig.getConfig().playerAddress;
        (uint256 subId ,) = createSubscription(vrfCoordinator , playerAddress);
        return (subId , vrfCoordinator);
    }
    function createSubscription(address vrfCoordinatorAddress , address playerAddress ) public returns(uint256 , address){ 
        vm.startBroadcast(playerAddress);
        uint256 subId = VRFCoordinatorV2_5Mock(vrfCoordinatorAddress).createSubscription();
        vm.stopBroadcast();
        return(subId , vrfCoordinatorAddress);
    }
    function run() public { 
        createSubscriptionUser();
    }
}
contract FundSubscription is Script , ConstantVarible{ 
    uint256 public constant FUND_AMOUNT = 300000 ether;
    function fundSubscriptionUsingConfig() public{
        HelperConfig helperConfig = new HelperConfig();
        address vrfCoordinator = helperConfig.getConfig().vrfCoordinator;
        uint256 subId = helperConfig.getConfig().subId;
        address link = helperConfig.getConfig().link;
        address playerAddress = helperConfig.getConfig().playerAddress;
        fundSubscription(vrfCoordinator, subId, link , playerAddress);
    }
    function fundSubscription(address vrfCoordinator , uint256 subId , address link , address playerAddress) public { 
        console.log("vrfCoordinator %s" , vrfCoordinator);
        console.log("Subid %s" , subId);
        console.log("Link" , link );
        if(block.chainid == LOCALNETWORK_CHAIN){    
            vm.startBroadcast();
            VRFCoordinatorV2_5Mock(vrfCoordinator).fundSubscription(subId, FUND_AMOUNT * 10000); // chaged this ill get back to it later
            vm.stopBroadcast();
        }else{ 
            vm.startBroadcast(playerAddress);
            LinkToken(link).transferAndCall(vrfCoordinator, 3 ether , abi.encode(subId));
            vm.stopBroadcast();
        }
    }
    function run() public {
        fundSubscriptionUsingConfig();
    }
}

contract AddConsumer is Script{ 
    function run () external {
        address recentlyDeployed = DevOpsTools.get_most_recent_deployment("raffel", block.chainid);
        addConsumerConfig(recentlyDeployed);     
    }
    function addConsumerConfig(address recentlyDeployed) public{ 
        HelperConfig helperConfig = new HelperConfig();
        address vrfCoordinator  = helperConfig.getConfig().vrfCoordinator;
        uint256 subId = helperConfig.getConfig().subId;
        address playerAddress = helperConfig.getConfig().playerAddress;
        addConsumer(vrfCoordinator , subId , recentlyDeployed , playerAddress);
    }
    function addConsumer(address vrfCoordinator , uint256 subId  , address recentlyDeployed , address playerAddress) public{ 
        vm.startBroadcast(playerAddress);
        VRFCoordinatorV2_5Mock(vrfCoordinator).addConsumer(subId, recentlyDeployed);
        vm.stopBroadcast();
    }

}