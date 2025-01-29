// SPDX-License-Identifier : MIT;
pragma solidity ^0.8.19;
import {PriceConverter} from "./PriceConverterEth.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
error FundMe_Error();
contract FundMe { 
    using PriceConverter for uint256;
    address immutable private i_owner;
    AggregatorV3Interface  interfaceValue;
    constructor(address provider){ 
        i_owner = msg.sender;
        interfaceValue =  AggregatorV3Interface(provider);
    }
    address[] private s_fundWallets;
    uint256 constant public MIN_USD = 5e18;
    mapping(address userAddress => uint256 amount) private s_AllFundedWallets;

    function fund() payable public{ 
        require(msg.value.getConversionRate(interfaceValue) > MIN_USD , "Suffiecient Amount should be require for sending the trasaction");
        s_fundWallets.push(msg.sender);
        s_AllFundedWallets[msg.sender] += msg.value;
    }
    function Withdraw() public isOwner{
        uint256 fundedAddressesLength = s_fundWallets.length; // ! this is used cause we need to use this form the memeory not from the storage -> storage cost lot higher gas fee and reading from the memory causes less gass fee 
        for(uint256 i = 0 ; i<fundedAddressesLength; i++){ 
            address userAddress = s_fundWallets[i];
            uint256 amount = s_AllFundedWallets[userAddress];
            if(amount > 0){
                (bool isDone , ) = payable(msg.sender).call{value : address(this).balance}("");
                require(isDone , "Cannot initate the trasaction");
            }
        }

    }
    function getVersion() public view returns(uint256){ 
        return interfaceValue.version();
    }
    modifier isOwner { 
        require(msg.sender == i_owner , "Owner should be sender");
        _;
    }

    receive() external payable{ 
        fund();
    }
    fallback() external payable{ 
        fund();
    }
    function getAmoutOfAddress(address Address) external view returns(uint256){ 
        return s_AllFundedWallets[Address];
    }
    function getUserAddress(uint256 Index) external view returns(address){ 
        return address(s_fundWallets[Index]);
    }
    function getOwner() external view returns(address){ 
        return i_owner;
    }
}