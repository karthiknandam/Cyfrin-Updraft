// SPDX-License-Identifier : MIT
pragma solidity ^0.8.19;

import {FundMe} from "../src/FundMe.sol";
import {Script} from "forge-std/Script.sol";

import {HelperAddress} from "./HelperAddress.s.sol";

contract FundMeDeploy is Script{ 
    function run() public returns(FundMe){
        HelperAddress helperAddress = new HelperAddress();
        address getAdress = helperAddress.activeAdress();
        vm.startBroadcast();
        FundMe fundMe = new FundMe(getAdress);
        vm.stopBroadcast();
        return fundMe;
    }
}