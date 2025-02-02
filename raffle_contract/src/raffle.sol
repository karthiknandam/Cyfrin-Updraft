// SPDX-License-Identifier: MIT
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
pragma solidity ^0.8.19;

contract Raffle is VRFConsumerBaseV2Plus {
    // ^ Errors
    error Raffle_SendMoreToEnterRaffle();
    error  Raffle__TransferFailed();
    error Raffle_RaffleIsNotOpen();
    error Raffle__RaffleAutomationError(uint256 balance , uint256 playersLength , uint8 isOpen );
    //  Events

    event RaffleEntered(address indexed player);
    event RecentRaffleWinner(address indexed winner);
    event RaffleWinner(uint256 indexed reqId);
    // Enums

    enum RaffleState{
        OPEN,
        CALCULATING
    }

    RaffleState private s_raffleState;

    // ? custom error hanlding revert is less and require is takes more gas
    uint256 private immutable i_entranceFee;
    address payable[] private s_players;
    uint256 private immutable i_interval;
    uint256 private s_latestBlockTimeStamp;

    // VRF confirmation
    bytes32 private immutable i_keyHash;
    uint256 private immutable i_subId;
    uint16 private constant REQUEST_CONFORMATIONS = 3;
    uint32 private immutable i_callbackGasLimit;
    uint32 private constant NUM_WORDS = 1;

    address payable recentWinner;

    constructor(
        uint256 entranceFee,
        uint256 interval,
        address vrfCoordinator,
        bytes32 keyHash,
        uint256 subId,
        uint32 callbackGasLimit
    ) VRFConsumerBaseV2Plus(vrfCoordinator) {
        i_entranceFee = entranceFee;
        i_interval = interval;
        i_keyHash = keyHash;
        i_subId = subId;
        i_callbackGasLimit = callbackGasLimit;
        s_latestBlockTimeStamp = block.timestamp;
        s_raffleState = RaffleState.OPEN;
    }

    function enterRaffle() external payable {
        if(s_raffleState!=RaffleState.OPEN){ 
            revert Raffle_RaffleIsNotOpen();
        }
        if (msg.value < i_entranceFee) {
            revert Raffle_SendMoreToEnterRaffle();
        }
        s_players.push(payable(msg.sender)); // -> sending the payable address so that we can pay to that user directly
        emit RaffleEntered(msg.sender);
    }

    /**
     * @dev This function is used to This ensures that we can use this and check if the data which is return true or not and second return key nerver mind
     * 1. Checks the time stamp
     * 2.Checks the address balance 
     * 3.checks users length
     * 4.Checks is OPEN ?
     */

    function checkUpkeep(bytes calldata /* checkData */) external view
        returns (bool upkeepNeeded, bytes memory /* performData */)
    {
        bool timeStampCheck = (block.timestamp >= s_latestBlockTimeStamp) &&
                              ((block.timestamp - s_latestBlockTimeStamp) >= i_interval);
        bool addressBalance = address(this).balance > 0;
        bool players = s_players.length > 0;
        bool isOpen = s_raffleState == RaffleState.OPEN;
        upkeepNeeded = timeStampCheck && addressBalance && players && isOpen;
        return (upkeepNeeded , "");
    }


    // getting the timeStamp ; -> block.timestamp and using it to verify the latest timeStamp of the user;
    // getting a random number ;

    function performUpkeep(bytes calldata /* performData */) external {
        // block hash time - latest block time !< i_interval in theat case just revert the function
        (bool _upkeepNeeded , ) = this.checkUpkeep("");
        if(!_upkeepNeeded){ 
            revert Raffle__RaffleAutomationError(address(this).balance , s_players.length , uint8(s_raffleState));
        }
        
        s_raffleState = RaffleState.CALCULATING;
        VRFV2PlusClient.RandomWordsRequest memory request = VRFV2PlusClient.RandomWordsRequest({
            keyHash: i_keyHash,
            subId: i_subId,
            requestConfirmations: REQUEST_CONFORMATIONS,
            callbackGasLimit: i_callbackGasLimit,
            numWords: NUM_WORDS,
            extraArgs: VRFV2PlusClient._argsToBytes(
                VRFV2PlusClient.ExtraArgsV1({
                    nativePayment: false
                })
            )
        });

        uint256 reqId =  s_vrfCoordinator.requestRandomWords(request);
        emit RaffleWinner(reqId);
        // picking a random user else -> haha
    }
    function fulfillRandomWords(uint256 /*requestId*/, uint256[] calldata randomWords) internal override{
        // Getting a random int value form the randomWords generator so that it can be done;
        // Checks
        // Effects
        uint256 indexWinner = randomWords[0] % s_players.length;
        address payable winnerAddress = s_players[indexWinner];
        recentWinner = winnerAddress;
        s_players = new address payable[](0);
        s_raffleState = RaffleState.OPEN;
        s_latestBlockTimeStamp = block.timestamp;
        // Interactions
        ( bool success , ) = recentWinner.call{value : address(this).balance}("");
        if(!success){ 
            revert Raffle__TransferFailed();
        }
        emit RecentRaffleWinner(recentWinner);
        
    }
    
    /**
     * Getter functions
     *
     */
    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }
    function getRaffleState() external view returns(RaffleState){ 
        return s_raffleState;
    }

    function getPlayerAddress(uint256 indexOfPLayer) external view returns(address){ 
        return s_players[indexOfPLayer];
    }
    function getLatestTimeStamp() external view returns(uint256){ 
        return s_latestBlockTimeStamp;
    }
    function getLatestWinner() external view returns(address){ 
        return recentWinner;
    }
}
