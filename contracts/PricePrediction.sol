// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./OwnableUpgradeable.sol";

contract PricePrediction is Initializable, OwnableUpgradeable {
    struct Bet {
        address user;
        bool isUp;
        uint256 amount;
    }

    enum GameStatus {
        INACTIVE,
        ACTIVE,
        FINISHED
    }

    address public ownerr;
    ERC20 public gameToken;
    AggregatorV3Interface public priceFeed;
    uint256 public slotDuration;
    
    uint256 public gameStartTime;
    uint256 public currentSlot;
    GameStatus public status;
    mapping(uint256 => Bet[]) public bets;
    int256 public previousPrice;

    event BetPlaced(
        address indexed user,
        uint256 indexed slot,
        bool isUp,
        uint256 amount
    );
    event GameFINISHED(
        uint256 indexed slot,
        uint256 winnersCount,
        uint256 totalBettingAmount
    );
    function _onlyOwnerCanCall() internal view {
         require(
            msg.sender == ownerr ,
            "Only Owner can call"
        );
    }

    modifier onlyOwnerr()  {
        _onlyOwnerCanCall();
        _;
    }

    function _PricePrediction_init(
        address _gameToken,
        address _priceFeed  
    ) public initializer {
        ownerr = msg.sender;
        gameToken = ERC20(_gameToken);
        priceFeed = AggregatorV3Interface(_priceFeed);
        status = GameStatus.INACTIVE;
    }

    function startGame(uint256 _slotDuration) external onlyOwnerr {
        require(status == GameStatus.INACTIVE, "Game is already active");
        gameStartTime = block.timestamp;
        slotDuration = _slotDuration;
        currentSlot++;
        status = GameStatus.ACTIVE;
        previousPrice = getCurrentPrice();
    }

    function placeBet(bool _isUp, uint256 _amount) external payable {
        require(status == GameStatus.ACTIVE, "Game is not active");
        
        require(
            gameToken.balanceOf(msg.sender) >= _amount,
            "Insufficient game tokens"
        );

        gameToken.transferFrom(msg.sender, address(this), _amount);
        bets[currentSlot].push(Bet(msg.sender, _isUp, _amount));

        emit BetPlaced(msg.sender, currentSlot, _isUp, _amount);
    }

    function finalizeSlot() external onlyOwnerr {
        require(status == GameStatus.ACTIVE, "Game is not active");
        require(
            block.timestamp >= gameStartTime + slotDuration,
            "Slot is not FINISHED yet"
        );

        uint256 winnersCount = 0;
        uint256 totalBettingAmount = 0;

        for (uint256 i = 0; i < bets[currentSlot].length; i++) {
            Bet storage bet = bets[currentSlot][i];
            int256 currentPrice = getCurrentPrice();

            if (
                (bet.isUp && currentPrice > int256(previousPrice)) ||
                (!bet.isUp && currentPrice < int256(previousPrice))
            ) {
                winnersCount++;
            }
            totalBettingAmount += bet.amount;
        }

        uint256 rewardValue = 0;

        if (winnersCount > 0) {
            rewardValue = totalBettingAmount / winnersCount;
        }

        for (uint256 i = 0; i < bets[currentSlot].length; i++) {
            Bet storage bet = bets[currentSlot][i];

            if (
                (bet.isUp && getCurrentPrice() > int256(previousPrice)) ||
                (!bet.isUp && getCurrentPrice() < int256(previousPrice))
            ) {
                gameToken.transfer(bet.user, rewardValue);
            }
        }
        status = GameStatus.FINISHED;
        emit GameFINISHED(currentSlot, winnersCount, totalBettingAmount);
        
    }

    function getCurrentPrice() internal view returns (int256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return price;
    }
}
