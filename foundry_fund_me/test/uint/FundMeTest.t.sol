// SPDX-License-Identifier : MIT
pragma solidity ^0.8.19;

// cheat code vm.prank(takes a user address which in the case test purpose);
// vm.revert() in this case the next should be revert cause it is true falsy;
// vm.deal gets the dealing for fake user initialization;

import {Test , console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {FundMeDeploy} from "../../script/FundeMe.s.sol";
contract FundMeTest is Test { 
    FundMe fundMe;
    address USER = makeAddr("karthikeya");
    uint256 constant  public SEND_USD  = 0.1 ether;
    uint256  constant public STARTING_BAL = 10 ether;

    function setUp() external { 
        FundMeDeploy deploy = new FundMeDeploy();
        fundMe = deploy.run();
        vm.deal(USER , STARTING_BAL);
    }
    function testIsOwner() public view{     
        console.log(fundMe.getOwner());
        console.log(fundMe.MIN_USD());
        console.log(msg.sender);
        console.log(address(this));
        assertEq(fundMe.getOwner(), msg.sender);
    }
   function testIsFailedFunding() public {
        vm.expectRevert();
        fundMe.fund();
   }
    //* asserEq gives us to verify the thing form left === right;
    //* providing the value to initial and then specifying the value to the need for external payable values
    function testIsVersionIsSame() public view { 
        console.log(fundMe.getVersion());
        assertEq(fundMe.getVersion() , 4);
    }

    // enseure that it can be act as the funded wallet for every single function in the test environment;

    modifier FUND_ME { 
        vm.prank(USER);
        fundMe.fund{value : SEND_USD}();
        _;
    }

    function testAmountToFunded() public FUND_ME() { 
        uint256 amountSended = fundMe.getAmoutOfAddress(USER);
        assertEq(SEND_USD , amountSended);
    }

    function testIsOwnerIsSender() public FUND_ME{ 
        address isOwner = fundMe.getUserAddress(0);
        assertEq(isOwner , USER);
    }
    function testIsOwnerIsWithdrawable() public FUND_ME{ 
        vm.prank(USER);
        vm.expectRevert();
        fundMe.Withdraw();
    }
    function testWithdrawWithOwner() public FUND_ME{ 
        // Arrage 
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 stratingFundmeBalance = address(fundMe).balance;

        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.Withdraw();
        vm.stopPrank();

        // Assert 
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance; 
        assert(endingFundMeBalance == 0);
        assertEq(stratingFundmeBalance + startingOwnerBalance , endingOwnerBalance , "Sorry Not Enough funds");
    }
    function testWithdrawWithAllFunders() public FUND_ME {  
        // Arrange
        uint160 startingAddress  = 1;
        uint160 totalAddresses = 10;

        for(uint160 i = startingAddress ; i<totalAddresses ; i++){ 
            // vm.prank() + vm.deal() = hoax and we can build upn it;
            hoax(address(i) , STARTING_BAL);
            fundMe.fund{value : SEND_USD}();
        } 

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // ACT

        vm.startPrank(fundMe.getOwner());
        fundMe.Withdraw();
        vm.stopPrank();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        // Assert

        assertEq(endingFundMeBalance , 0);
        assertEq(startingFundMeBalance + startingOwnerBalance , endingOwnerBalance , "Not equal test fails");
    
    }
}

