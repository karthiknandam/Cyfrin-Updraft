// SPDX-License-Identifier : MIT
pragma solidity ^0.8.19;

// cheat code vm.prank(takes a user address which in the case test purpose);
// vm.revert() in this case the next should be revert cause it is true falsy;
// vm.deal gets the dealing for fake user initialization;

import {Test , console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {FundMeDeploy} from "../../script/FundeMe.s.sol";
import {FundFundMe , WithdrawFundMe} from "../../script/Interactions.s.sol";
contract FundMeTest is Test { 
    FundMe fundMe;
    address USER = makeAddr("karthikeya");
    uint256 constant  public SEND_USD  = 0.1 ether;
    uint256  constant public STARTING_BAL = 10 ether;

    function setUp() external {
        FundMeDeploy deploy = new FundMeDeploy();
        fundMe = deploy.run();
        vm.deal(USER, STARTING_BAL); 
    }
    function testUserCanFundInteractions() public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        assert(address(fundMe).balance == 0);
        
    }

} 