// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {Raffle} from "src/raffle.sol";
import {CreateSubscription , FundSubscription , AddConsumer} from "./Ineteractions.s.sol";
contract DeployRaffle is Script { 
    function run() public{ }
    function deployRaffle() external returns(Raffle , HelperConfig){ 
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfing memory config =  helperConfig.getConfig();
        if(config.subId == 0){ 
            CreateSubscription createSubscription = new CreateSubscription();
            (config.subId , config.vrfCoordinator) = createSubscription.createSubscription(config.vrfCoordinator , config.playerAddress);
            FundSubscription fundSubscription = new FundSubscription();
            fundSubscription.fundSubscription(config.vrfCoordinator, config.subId, config.link , config.playerAddress);
        }
        vm.startBroadcast();
        Raffle raffle  = new Raffle(config.entranceFee,
            config.interval,
            config.vrfCoordinator,
            config.keyHash,
            config.subId,
            config.callbackGasLimit
        );
        vm.stopBroadcast();

        AddConsumer addConsumer = new AddConsumer();
        addConsumer.addConsumer(config.vrfCoordinator , config.subId , address(raffle) , config.playerAddress);
        return (raffle , helperConfig);
    }
}
