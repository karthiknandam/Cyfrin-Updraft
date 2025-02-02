// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {Test , console2} from "forge-std/Test.sol";
import {HelperConfig , ConstantVarible} from "script/HelperConfig.s.sol";
import {Raffle} from "src/raffle.sol";
import {DeployRaffle} from "script/DeployRaffle.s.sol";
import {Vm } from "forge-std/Vm.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
contract RaffelTest is Test , ConstantVarible {
    uint256  entranceFee;
    uint256  interval;
    address  vrfCoordinator;
    bytes32  keyHash;
    uint256  subId;
    uint32  callbackGasLimit;
    Raffle public raffel ;
    HelperConfig public helperConfig;

    event RaffleEntered(address indexed player);
    event RaffleWinner(address indexed winner);

    address public PLAYER = makeAddr("YOOO");
    uint256 public constant RAFFLE_AMOUNT = 10 ether;
    function setUp() external { 
        DeployRaffle deployRaflle = new DeployRaffle();
        (raffel , helperConfig) = deployRaflle.deployRaffle();
        HelperConfig.NetworkConfing memory config = helperConfig.getConfig();
        entranceFee = config.entranceFee;
        interval = config.interval;
        vrfCoordinator = config.vrfCoordinator;
        keyHash = config.keyHash;
        subId = config.subId;
        callbackGasLimit = config.callbackGasLimit;
        vm.deal(PLAYER, RAFFLE_AMOUNT);
    }
    function testIsRaffleOpen() public view{ 
        assert(Raffle.RaffleState.OPEN == raffel.getRaffleState());
    }
    function testIsUserHaveEnoughMoneyToEnter() public { 
        vm.prank(PLAYER);
        vm.expectRevert(Raffle.Raffle_SendMoreToEnterRaffle.selector);
        raffel.enterRaffle();
    }
    function testRaffleRecordsWhenThePlayerEnters() public{ 
        vm.prank(PLAYER);
        raffel.enterRaffle{value : entranceFee}();
        assert(raffel.getPlayerAddress(0) == PLAYER);
    }
    // for the emiting the evetnbs expectEmit(3 for indexes adn last any , for the addres of contract )
    function testUserHasBeenEmitted() public{ 
        vm.prank(PLAYER);
        vm.expectEmit(true, false, false, false , address(raffel));
        emit RaffleEntered(PLAYER);
        raffel.enterRaffle{value : entranceFee}();
    }
    function testDonNotEnterNewPlayerWhileCaluclating() public { 
        vm.prank(PLAYER);
        raffel.enterRaffle{value : entranceFee}();
        vm.warp(block.timestamp + interval +1); //this ensure to push the block timstamp to watterver want we to be;
        vm.roll(block.number + 1);
        raffel.performUpkeep("");
        // asserting

        vm.prank(PLAYER);
        vm.expectRevert(Raffle.Raffle_RaffleIsNotOpen.selector);
        raffel.enterRaffle{value : entranceFee}();
    }

    // Checkup keeps finding;

    function testIsRaffleHasEnoughBalance() public { 
        vm.warp(block.timestamp + interval+ 1);
        vm.roll(block.chainid + 1);
        (bool upkeepNeeded ,) = raffel.checkUpkeep("");
        assert(!upkeepNeeded);
    }
    function testCheckUpKeepReturnFalseRaffleIsNotOpen() public{ 
        vm.prank(PLAYER);
        raffel.enterRaffle{value : entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.chainid+1);
        raffel.performUpkeep("");

        assert(Raffle.RaffleState.CALCULATING == raffel.getRaffleState());
    }

    // Working with performUpkeep ;

    function testPerformUpKeepWorkFineIfCheckUpKeepIsTrue() public{ 
        vm.prank(PLAYER);
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.chainid + 1);
        raffel.enterRaffle{value : entranceFee}();
        raffel.performUpkeep("");
    }

    function testPerformUpKeepIfCheckUpKeepFalse() public skipTheTestIfChainIdIsNotLocal{ 
        // ASSIGN
        uint256 balance = 0;
        uint256 playersLength = 0;
        Raffle.RaffleState rState = raffel.getRaffleState();

        vm.prank(PLAYER);
        raffel.enterRaffle{value : entranceFee}();
        balance += entranceFee;
        playersLength++;
        // cause we are not updating the value in the raffle state that is the reason it is reverting back ;
        // ASEERT ACT
        vm.expectRevert(
            abi.encodeWithSelector(Raffle.Raffle__RaffleAutomationError.selector , balance, playersLength, rState)
        );
        raffel.performUpkeep("");
    }
    // event handling;

    modifier RaffleEnterModifier(){ 
        vm.prank(PLAYER);
        vm.warp(block.timestamp + interval + 1); 
        vm.roll(block.chainid + 1);
        raffel.enterRaffle{value : entranceFee}();
        _;
    }

    function testPerformUpKeepUpdatesTheRaffleStateEventEmit() public RaffleEnterModifier{ 

        vm.recordLogs();
        raffel.performUpkeep("");
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 requesId = entries[1].topics[1];
        
        Raffle.RaffleState raffelState = raffel.getRaffleState();

        // Assert;

        assert(uint256(requesId) > 0);
        assert(uint256(raffelState) == 1);   
    }

    // Fuzz tests ; it calls the random nuber time that we have specified in the .toml file
    function testFullfillRandomWordsOnlyCalledAfterPerformUpKeep(uint256 randomNumber) public skipTheTestIfChainIdIsNotLocal{ 
        vm.expectRevert(VRFCoordinatorV2_5Mock.InvalidRequest.selector);
        VRFCoordinatorV2_5Mock(vrfCoordinator).fulfillRandomWords(randomNumber, address(raffel));
    }


    // getting funded again and again;

    modifier skipTheTestIfChainIdIsNotLocal(){ 
        if(block.chainid != LOCALNETWORK_CHAIN){ 
            return;
        }
        _;
    }

    function testTheWinnerAndDrawTheRaffel() public  RaffleEnterModifier  skipTheTestIfChainIdIsNotLocal { 
        uint160 additionalPlayers = 3;
        uint160 startingPlayer = 1;
        address expectedWinner = address(1);
        for(uint160 i = startingPlayer ; i <= additionalPlayers ; i++ ){ 
            address newPlayer = address(i);
            hoax(newPlayer , 1 ether);
            raffel.enterRaffle{value : entranceFee}();
        }
        uint256 startingTimeStamp = raffel.getLatestTimeStamp();
        uint256 expectedWinnerBalance = expectedWinner.balance;
        vm.recordLogs();
        raffel.performUpkeep("");
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 requestId = entries[1].topics[1];

        VRFCoordinatorV2_5Mock(vrfCoordinator).fulfillRandomWords(uint256(requestId), address(raffel));
        
        address recentWinner = raffel.getLatestWinner();
        Raffle.RaffleState raffelState = raffel.getRaffleState();
        uint256 endingTimeStamp = raffel.getLatestTimeStamp();
        uint256 walletBalance = recentWinner.balance;
        uint256 prize = entranceFee * (uint256(additionalPlayers) + 1);

        assert(recentWinner == expectedWinner);
        assert(walletBalance ==( expectedWinnerBalance + prize));
        assert(uint256(raffelState) == 0);
        assert(endingTimeStamp > startingTimeStamp);
    }

}