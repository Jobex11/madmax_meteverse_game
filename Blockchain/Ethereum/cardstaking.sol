// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CardGameStaking is Ownable(address(msg.sender)) {
    // Token to be used for staking
    IERC20 public stakingToken;

    // Platform fee (percentage in basis points: 1% = 100)
    uint256 public platformFeeBasisPoints;

    // Game structure to hold game-related information
    struct Game {
        address player1;
        address player2;
        uint256 stakeAmount;
        bool isCompleted;
        address winner;
    }

    // Mapping of game ID to Game details
    mapping(uint256 => Game) public games;

    // Mapping of game ID to staked funds
    mapping(uint256 => uint256) public gameStakes;

    // Event declarations
    event GameCreated(uint256 gameId, address indexed player1, uint256 stakeAmount);
    event GameJoined(uint256 gameId, address indexed player2);
    event GameCompleted(uint256 gameId, address indexed winner, uint256 reward);
    event FundsWithdrawn(uint256 gameId, address indexed winner, uint256 amount);

    constructor(IERC20 _stakingToken, uint256 _platformFeeBasisPoints) {
        stakingToken = _stakingToken;
        platformFeeBasisPoints = _platformFeeBasisPoints;
    }

    /// @notice Creates a new game
    function createGame(uint256 gameId, uint256 stakeAmount) external {
        require(games[gameId].player1 == address(0), "Game ID already exists");
        require(stakeAmount > 0, "Stake amount must be greater than zero");

        // Transfer stake tokens from player1 to the contract
        stakingToken.transferFrom(msg.sender, address(this), stakeAmount);

        // Initialize the game
        games[gameId] = Game({
            player1: msg.sender,
            player2: address(0),
            stakeAmount: stakeAmount,
            isCompleted: false,
            winner: address(0)
        });

        // Track staked funds
        gameStakes[gameId] = stakeAmount;

        emit GameCreated(gameId, msg.sender, stakeAmount);
    }

    /// @notice Joins an existing game
    function joinGame(uint256 gameId) external {
        Game storage game = games[gameId];
        require(game.player1 != address(0), "Game does not exist");
        require(game.player2 == address(0), "Game is already full");
        require(msg.sender != game.player1, "Cannot join your own game");

        // Transfer stake tokens from player2 to the contract
        stakingToken.transferFrom(msg.sender, address(this), game.stakeAmount);

        // Update game details
        game.player2 = msg.sender;

        // Double the stake in escrow
        gameStakes[gameId] += game.stakeAmount;

        emit GameJoined(gameId, msg.sender);
    }

    /// @notice Completes a game and rewards the winner
    function completeGame(uint256 gameId, address winner) external onlyOwner {
        Game storage game = games[gameId];
        require(!game.isCompleted, "Game is already completed");
        require(game.player1 != address(0) && game.player2 != address(0), "Incomplete game");
        require(winner == game.player1 || winner == game.player2, "Invalid winner");

        // Calculate platform fee
        uint256 platformFee = (gameStakes[gameId] * platformFeeBasisPoints) / 10000;

        // Calculate winner reward
        uint256 reward = gameStakes[gameId] - platformFee;

        // Update game state
        game.isCompleted = true;
        game.winner = winner;

        // Transfer fee to owner
        stakingToken.transfer(owner(), platformFee);

        // Transfer reward to winner
        stakingToken.transfer(winner, reward);

        emit GameCompleted(gameId, winner, reward);
    }

    /// @notice Withdraws funds for the winner
    function withdrawFunds(uint256 gameId) external {
        Game storage game = games[gameId];
        require(game.isCompleted, "Game is not completed");
        require(msg.sender == game.winner, "Only the winner can withdraw funds");

        uint256 reward = gameStakes[gameId];

        // Reset game stakes to prevent reentrancy
        gameStakes[gameId] = 0;

        // Transfer reward to winner
        stakingToken.transfer(game.winner, reward);

        emit FundsWithdrawn(gameId, msg.sender, reward);
    }
}


/*
===> CONTRACT ADDRESS: 0x8592F3d64ce11556b32dda7Ab46ebf377a395670
*/