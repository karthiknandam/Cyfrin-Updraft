// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {LinkToken} from "test/mocks/LinkMocks.t.sol";
import {Script} from "forge-std/Script.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

abstract contract ConstantVarible { 
    uint256 public constant ETH_SEPHOLIA_CHAIN = 11155111;
    uint256 public constant LOCALNETWORK_CHAIN = 31337;

    // Mock
    uint96 public constant MOCK_BASE_FEE = 0.025 ether;
    uint96 public constant MOCK_GASE_FEE = 1e19;
    int256 public constant MOCK_WEI_PER_UNIT_LINK = 4e15;    
}

contract HelperConfig is Script , ConstantVarible{ 
    error  HelperConfig__InvalidChainId();
    struct NetworkConfing{ 
        uint256 entranceFee;
        uint256 interval;
        address vrfCoordinator;
        bytes32 keyHash;
        uint256 subId;
        uint32 callbackGasLimit;
        address link;
        address playerAddress;
    }
    NetworkConfing public latestNetworkConfig;
    mapping(uint256 chainId => NetworkConfing) networkConfigs;
    constructor(){
        networkConfigs[ETH_SEPHOLIA_CHAIN] = getSepholiaNetworkNetworkConfig();
    }

    function getConfigNetwokChain(uint256 chainId) public returns(NetworkConfing memory){ 
        if(networkConfigs[chainId].vrfCoordinator != address(0)){ 
            return networkConfigs[chainId];
        }else if(chainId == LOCALNETWORK_CHAIN){ 
            return getLocalNetworkChainConfig();
        }else { 
            revert HelperConfig__InvalidChainId();
        }
    }
    function getConfig() public returns (NetworkConfing memory){ 
        return getConfigNetwokChain(block.chainid);
    }

    function getSepholiaNetworkNetworkConfig() public pure returns(NetworkConfing memory){ 
        return NetworkConfing({ 
            entranceFee : 0.001 ether,
            interval : 30,
            keyHash : 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            subId : 4109463507368075439185070617858064503407636344239896953845368839007968509247,
            callbackGasLimit : 500000,
            vrfCoordinator : 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B,
            link : 0x779877A7B0D9E8603169DdbD7836e478b4624789,
            playerAddress : 0x958380077A987e1938c37531de8a5cddcED329A6
        });
    }

    function getLocalNetworkChainConfig() public returns(NetworkConfing memory){
        if(latestNetworkConfig.vrfCoordinator != address(0)){ 
            return latestNetworkConfig;
        }
        vm.startBroadcast();
        VRFCoordinatorV2_5Mock vrfMock = new VRFCoordinatorV2_5Mock(MOCK_BASE_FEE , MOCK_GASE_FEE , MOCK_WEI_PER_UNIT_LINK);
        LinkToken linkToken = new LinkToken();
        vm.stopBroadcast();
        latestNetworkConfig =  NetworkConfing({ 
            entranceFee : 0.001 ether,
            interval : 30,
            keyHash : 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            subId : 0,
            callbackGasLimit : 500000,
            vrfCoordinator : address(vrfMock),
            link : address(linkToken),
            playerAddress : 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38
        });
        return latestNetworkConfig;
    }
}