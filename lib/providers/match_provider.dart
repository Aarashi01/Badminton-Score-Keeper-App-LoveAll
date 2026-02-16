import 'package:flutter/material.dart';
import '../models/match_state.dart';

class MatchProvider extends ChangeNotifier {
  MatchState _state = MatchState(
    games: [GameState(gameNumber: 1)],
    currentServer: Team.A, // Assume Team A serves first initially
  );

  MatchState get state => _state;

  // Undo history stack (simple state snapshots)
  final List<MatchState> _undoStack = [];

  void setTeamNames(String teamA, String teamB) {
    _state = _state.copyWith(teamAName: teamA, teamBName: teamB);
    notifyListeners();
  }

  void initializeMatch({
    required String teamAName,
    required String teamBName,
    required MatchType matchType,
    required TeamPlayers teamAPlayers,
    required TeamPlayers teamBPlayers,
  }) {
    // Determine initial server (Team A starts)
    Player server = teamAPlayers.player1;
    Player receiver = teamBPlayers.player1;

    // Initial Positions
    Map<String, CourtPosition> positions = {};

    if (matchType == MatchType.singles) {
      // Singles: Positions determined by score (0-0 = Right)
      positions[teamAPlayers.player1.name] = CourtPosition.right;
      positions[teamBPlayers.player1.name] = CourtPosition.right;
    } else {
      // Doubles:
      // Team A (Serving first)
      // Player 1 in Right (Starts serving)
      // Player 2 in Left
      positions[teamAPlayers.player1.name] = CourtPosition.right;
      if (teamAPlayers.player2 != null) {
        positions[teamAPlayers.player2!.name] = CourtPosition.left;
      }

      // Team B (Receiving)
      // Player 1 in Right (Receiving from Right)
      // Player 2 in Left
      positions[teamBPlayers.player1.name] = CourtPosition.right;
      if (teamBPlayers.player2 != null) {
        positions[teamBPlayers.player2!.name] = CourtPosition.left;
      }

      // Override based on user selection if implemented later (startingPosition)
      // For now assuming standard start position or user selection mapped to player1/2 order
      if (teamAPlayers.player1.startingPosition == CourtPosition.left) {
        // This would mean Player 1 starts in Left? Standard is Right for 0-0.
        // We'll enforce Right for 0-0 server.
      }
    }

    _state = MatchState(
      teamAName: teamAName,
      teamBName: teamBName,
      matchType: matchType,
      teamAPlayers: teamAPlayers,
      teamBPlayers: teamBPlayers,
      games: [GameState(gameNumber: 1)],
      currentServer: Team.A,
      currentServerPlayer: server,
      currentReceiverPlayer: receiver,
      playerPositions: positions,
    );
    _undoStack.clear();
    notifyListeners();
  }

  void scorePoint(Team scoringTeam, {WinReason reason = WinReason.other}) {
    if (_state.matchWinner != null) return; // Match Over

    _saveStateForUndo();

    GameState currentGame = _state.games[_state.currentGameIndex];

    // Add point
    int newScoreA = currentGame.scoreA;
    int newScoreB = currentGame.scoreB;

    if (scoringTeam == Team.A) {
      newScoreA++;
    } else {
      newScoreB++;
    }

    // Determine new Server and Player Positions (Doubles Logic)
    Team nextServerTeam = _state.currentServer;
    Player? nextServerPlayer = _state.currentServerPlayer;
    Player? nextReceiverPlayer = _state.currentReceiverPlayer;
    Map<String, CourtPosition> nextPositions = Map.from(_state.playerPositions);

    if (_state.matchType == MatchType.doubles) {
      if (scoringTeam == _state.currentServer) {
        // Serving team won point -> Swap positions, Same server
        _swapTeamPositions(scoringTeam, nextPositions);
        // Server player remains same
      } else {
        // Receiving team won point -> Service Over
        // No position swap
        nextServerTeam = scoringTeam;

        // New server is determined by score (Even=Right, Odd=Left)
        // Find which player is in the correct court
        int newScore = (scoringTeam == Team.A) ? newScoreA : newScoreB;
        CourtPosition correctCourt = (newScore % 2 == 0)
            ? CourtPosition.right
            : CourtPosition.left;

        nextServerPlayer = _getPlayerInCourt(
          scoringTeam,
          correctCourt,
          nextPositions,
        );
      }

      // Determine receiver for next rally (Diagonal to server)
      // Server is at 'serverScore % 2' court (Right/Left)
      // Actually after point, server is at correct court for their score
      // Receiver should be in diagonal court.
      // But wait: Players only move when they serve and win.
      // So checks:
      int serverScore = (nextServerTeam == Team.A) ? newScoreA : newScoreB;
      CourtPosition serverCourt = (serverScore % 2 == 0)
          ? CourtPosition.right
          : CourtPosition.left;
      CourtPosition receiverCourt =
          serverCourt; // Diagonal is same side (Right serves to Right)

      Team receivingTeam = (nextServerTeam == Team.A) ? Team.B : Team.A;
      nextReceiverPlayer = _getPlayerInCourt(
        receivingTeam,
        receiverCourt,
        nextPositions,
      );
    } else {
      // Singles Logic
      if (scoringTeam != _state.currentServer) {
        nextServerTeam = scoringTeam;
      }
      // In singles, positions are always implied by score, but we can update map for consistency
      // Update A Position
      nextPositions[_state.teamAPlayers.player1.name] = (newScoreA % 2 == 0)
          ? CourtPosition.right
          : CourtPosition.left;
      nextPositions[_state.teamBPlayers.player1.name] = (newScoreB % 2 == 0)
          ? CourtPosition.right
          : CourtPosition.left;

      nextServerPlayer =
          _state.teamAPlayers.player1; // Simplification for singles
      if (nextServerTeam == Team.B)
        nextServerPlayer = _state.teamBPlayers.player1;
    }

    // Create rally event
    final event = RallyEvent(
      pointNumber: newScoreA + newScoreB,
      scoringTeam: scoringTeam,
      reason: reason,
      serverTeam: _state.currentServer, // Who WAS serving
      gameNumber: currentGame.gameNumber,
    );

    // Update Game State
    GameState updatedGame = currentGame.copyWith(
      scoreA: newScoreA,
      scoreB: newScoreB,
      rallyHistory: [...currentGame.rallyHistory, event],
    );

    _state = _state.copyWith(
      games: List.from(_state.games)..[_state.currentGameIndex] = updatedGame,
      currentServer: nextServerTeam,
      currentServerPlayer: nextServerPlayer,
      currentReceiverPlayer: nextReceiverPlayer,
      playerPositions: nextPositions,
    );

    // Check Game Win
    _checkGameWin(updatedGame);

    notifyListeners();
  }

  void _swapTeamPositions(Team team, Map<String, CourtPosition> positions) {
    TeamPlayers players = (team == Team.A)
        ? _state.teamAPlayers
        : _state.teamBPlayers;
    String p1 = players.player1.name;
    String p2 = players.player2!.name; // Assumes doubles

    CourtPosition pos1 = positions[p1]!;
    CourtPosition pos2 = positions[p2]!;

    positions[p1] = pos2;
    positions[p2] = pos1;
  }

  Player _getPlayerInCourt(
    Team team,
    CourtPosition pos,
    Map<String, CourtPosition> positions,
  ) {
    TeamPlayers players = (team == Team.A)
        ? _state.teamAPlayers
        : _state.teamBPlayers;
    if (positions[players.player1.name] == pos) return players.player1;
    if (players.player2 != null && positions[players.player2!.name] == pos)
      return players.player2!;
    return players.player1; // Fallback
  }

  void _checkGameWin(GameState game) {
    if (game.winner != null) return;

    bool gameWon = false;
    Team? winner;

    int sA = game.scoreA;
    int sB = game.scoreB;

    // Standard win: 21 pts and >= 2 point lead
    if ((sA >= 21 || sB >= 21) && (sA - sB).abs() >= 2) {
      gameWon = true;
      winner = sA > sB ? Team.A : Team.B;
    }
    // Cap at 30: 30-29 wins
    else if (sA == 30 || sB == 30) {
      gameWon = true;
      winner = sA > sB ? Team.A : Team.B;
    }

    if (gameWon && winner != null) {
      // Mark game winner
      GameState finishedGame = game.copyWith(winner: winner);
      List<GameState> newGames = List.from(_state.games);
      newGames[_state.currentGameIndex] = finishedGame;

      int wonA = _state.gamesWonA + (winner == Team.A ? 1 : 0);
      int wonB = _state.gamesWonB + (winner == Team.B ? 1 : 0);

      _state = _state.copyWith(
        games: newGames,
        gamesWonA: wonA,
        gamesWonB: wonB,
      );

      _checkMatchWin(wonA, wonB);

      if (_state.matchWinner == null) {
        // Start next game
        // Winner of previous game serves first
        _startNextGame(winner);
      }
    } else {
      // Check for side switch if Game 3 and score is 11
      // This is mainly a UI prompt, but we can store "isSwitched" state if we want.
      // For now, UI can derive this: (gameNumber == 3 && (scoreA == 11 || scoreB == 11) && !switched)
    }
  }

  void _checkMatchWin(int wonA, int wonB) {
    if (wonA == 2) {
      _state = _state.copyWith(matchWinner: Team.A);
    } else if (wonB == 2) {
      _state = _state.copyWith(matchWinner: Team.B);
    }
  }

  void _startNextGame(Team firstServer) {
    // delay or immediate? Immediate for state, UI can show dialog
    final nextGame = GameState(gameNumber: _state.games.length + 1);

    // Determine players for next game start
    Player? serverPlayer;
    Player? receiverPlayer;
    Map<String, CourtPosition> newPositions = {};

    if (_state.matchType == MatchType.singles) {
      // Singles: Positions determined by score (0-0 = Right)
      newPositions[_state.teamAPlayers.player1.name] = CourtPosition.right;
      newPositions[_state.teamBPlayers.player1.name] = CourtPosition.right;

      serverPlayer = (firstServer == Team.A)
          ? _state.teamAPlayers.player1
          : _state.teamBPlayers.player1;
      receiverPlayer = (firstServer == Team.A)
          ? _state.teamBPlayers.player1
          : _state.teamAPlayers.player1;
    } else {
      // Doubles
      TeamPlayers servingTeam = (firstServer == Team.A)
          ? _state.teamAPlayers
          : _state.teamBPlayers;
      TeamPlayers receivingTeam = (firstServer == Team.A)
          ? _state.teamBPlayers
          : _state.teamAPlayers;

      // Reset positions to standard 0-0
      // Defaulting to Player 1 serving for now.
      // In real life, they can choose. We assume Player 1.
      serverPlayer = servingTeam.player1;
      receiverPlayer = receivingTeam.player1;

      newPositions[servingTeam.player1.name] = CourtPosition.right;
      if (servingTeam.player2 != null) {
        newPositions[servingTeam.player2!.name] = CourtPosition.left;
      }

      newPositions[receivingTeam.player1.name] = CourtPosition.right;
      if (receivingTeam.player2 != null) {
        newPositions[receivingTeam.player2!.name] = CourtPosition.left;
      }
    }

    _state = _state.copyWith(
      games: [..._state.games, nextGame],
      currentGameIndex: _state.currentGameIndex + 1,
      currentServer: firstServer,
      currentServerPlayer: serverPlayer,
      currentReceiverPlayer: receiverPlayer,
      playerPositions: newPositions,
    );
  }

  void undo() {
    if (_undoStack.isNotEmpty) {
      _state = _undoStack.removeLast();
      notifyListeners();
    }
  }

  void resetMatch() {
    _state = MatchState(
      games: [GameState(gameNumber: 1)],
      currentServer: Team.A,
      teamAName: _state.teamAName,
      teamBName: _state.teamBName,
    );
    _undoStack.clear();
    notifyListeners();
  }

  void _saveStateForUndo() {
    _undoStack.add(_state);
    // Limit stack size if needed, e.g. 50?
  }

  // Helper for UI to know which side serves
  // Returns 'Right' or 'Left'
  String getServerCourtSide() {
    // BWF: Server score even -> Right, Odd -> Left
    int serverScore = 0;
    if (_state.currentServer == Team.A) {
      serverScore = _state.currentGame.scoreA;
    } else {
      serverScore = _state.currentGame.scoreB;
    }

    return (serverScore % 2 == 0) ? "Right" : "Left";
  }
}
