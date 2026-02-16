import 'package:uuid/uuid.dart';

enum Team { A, B }

enum WinReason {
  smashWinner,
  dropShotWinner,
  clearWinner,
  netKill,
  opponentErrorOut,
  opponentErrorNet,
  doubleHit,
  liftTooShort,
  serviceFault,
  other,
}

extension WinReasonDisplay on WinReason {
  String get displayName {
    switch (this) {
      case WinReason.smashWinner:
        return "Smash Winner";
      case WinReason.dropShotWinner:
        return "Drop Shot Winner";
      case WinReason.clearWinner:
        return "Clear Winner";
      case WinReason.netKill:
        return "Net Kill";
      case WinReason.opponentErrorOut:
        return "Opponent Error - Out";
      case WinReason.opponentErrorNet:
        return "Opponent Error - Into Net";
      case WinReason.doubleHit:
        return "Double Hit (Fault)";
      case WinReason.liftTooShort:
        return "Lift Too Short";
      case WinReason.serviceFault:
        return "Service Fault";
      case WinReason.other:
        return "Other";
    }
  }
}

enum MatchType { singles, doubles }

enum CourtPosition { left, right }

class Player {
  final String name;
  final CourtPosition startingPosition;

  Player({required this.name, required this.startingPosition});

  Player copyWith({String? name, CourtPosition? startingPosition}) {
    return Player(
      name: name ?? this.name,
      startingPosition: startingPosition ?? this.startingPosition,
    );
  }
}

class TeamPlayers {
  final Player player1; // For singles, this is the only player
  final Player? player2; // For doubles, this is the second player

  TeamPlayers({required this.player1, this.player2});

  bool get isDoubles => player2 != null;

  TeamPlayers copyWith({Player? player1, Player? player2}) {
    return TeamPlayers(player1: player1 ?? this.player1, player2: player2);
  }
}

class RallyEvent {
  final String id;
  final int pointNumber;
  final Team scoringTeam;
  final WinReason reason;
  final Team serverTeam;
  final DateTime timestamp;
  final int gameNumber;

  RallyEvent({
    required this.pointNumber,
    required this.scoringTeam,
    required this.reason,
    required this.serverTeam,
    required this.gameNumber,
    DateTime? timestamp,
    String? id,
  }) : this.timestamp = timestamp ?? DateTime.now(),
       this.id = id ?? const Uuid().v4();
}

class GameState {
  final int gameNumber;
  final int scoreA;
  final int scoreB;
  final Team? winner; // Null if game is in progress
  final List<RallyEvent> rallyHistory;

  GameState({
    required this.gameNumber,
    this.scoreA = 0,
    this.scoreB = 0,
    this.winner,
    List<RallyEvent>? rallyHistory,
  }) : this.rallyHistory = rallyHistory ?? [];

  GameState copyWith({
    int? scoreA,
    int? scoreB,
    Team? winner,
    List<RallyEvent>? rallyHistory,
  }) {
    return GameState(
      gameNumber: this.gameNumber,
      scoreA: scoreA ?? this.scoreA,
      scoreB: scoreB ?? this.scoreB,
      winner: winner ?? this.winner,
      rallyHistory: rallyHistory ?? this.rallyHistory,
    );
  }
}

class MatchState {
  final String teamAName;
  final String teamBName;
  final MatchType matchType;
  final TeamPlayers teamAPlayers;
  final TeamPlayers teamBPlayers;
  final int gamesWonA;
  final int gamesWonB;
  final int currentGameIndex; // 0-indexed (0, 1, 2)
  final List<GameState> games;
  final Team? matchWinner;
  final Team currentServer;
  final Player? currentServerPlayer;
  final Player? currentReceiverPlayer;
  final Map<String, CourtPosition> playerPositions;

  MatchState({
    this.teamAName = "Team A",
    this.teamBName = "Team B",
    this.matchType = MatchType.singles,
    TeamPlayers? teamAPlayers,
    TeamPlayers? teamBPlayers,
    this.gamesWonA = 0,
    this.gamesWonB = 0,
    this.currentGameIndex = 0,
    required this.games,
    this.matchWinner,
    this.currentServer = Team.A, // Default start
    this.currentServerPlayer,
    this.currentReceiverPlayer,
    Map<String, CourtPosition>? playerPositions,
  }) : this.teamAPlayers =
           teamAPlayers ??
           TeamPlayers(
             player1: Player(
               name: "Player 1",
               startingPosition: CourtPosition.right,
             ),
           ),
       this.teamBPlayers =
           teamBPlayers ??
           TeamPlayers(
             player1: Player(
               name: "Player 2",
               startingPosition: CourtPosition.right,
             ),
           ),
       this.playerPositions = playerPositions ?? {};

  GameState get currentGame => games[currentGameIndex];

  MatchState copyWith({
    String? teamAName,
    String? teamBName,
    MatchType? matchType,
    TeamPlayers? teamAPlayers,
    TeamPlayers? teamBPlayers,
    int? gamesWonA,
    int? gamesWonB,
    int? currentGameIndex,
    List<GameState>? games,
    Team? matchWinner,
    Team? currentServer,
    Player? currentServerPlayer,
    Player? currentReceiverPlayer,
    Map<String, CourtPosition>? playerPositions,
  }) {
    return MatchState(
      teamAName: teamAName ?? this.teamAName,
      teamBName: teamBName ?? this.teamBName,
      matchType: matchType ?? this.matchType,
      teamAPlayers: teamAPlayers ?? this.teamAPlayers,
      teamBPlayers: teamBPlayers ?? this.teamBPlayers,
      gamesWonA: gamesWonA ?? this.gamesWonA,
      gamesWonB: gamesWonB ?? this.gamesWonB,
      currentGameIndex: currentGameIndex ?? this.currentGameIndex,
      games: games ?? this.games,
      matchWinner: matchWinner ?? this.matchWinner,
      currentServer: currentServer ?? this.currentServer,
      currentServerPlayer: currentServerPlayer ?? this.currentServerPlayer,
      currentReceiverPlayer:
          currentReceiverPlayer ?? this.currentReceiverPlayer,
      playerPositions: playerPositions ?? this.playerPositions,
    );
  }

  // Create initial state
  factory MatchState.initial() {
    return MatchState(games: [GameState(gameNumber: 1)]);
  }
}
