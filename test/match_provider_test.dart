import 'package:flutter_test/flutter_test.dart';
import 'package:badminton_score_keeper/providers/match_provider.dart';
import 'package:badminton_score_keeper/models/match_state.dart';

void main() {
  group('MatchProvider Doubles Logic', () {
    late MatchProvider provider;

    setUp(() {
      provider = MatchProvider();
      provider.initializeMatch(
        teamAName: "Team A",
        teamBName: "Team B",
        matchType: MatchType.doubles,
        matchFormat: MatchFormat.bestOf3,
        teamAPlayers: TeamPlayers(
          player1: Player(name: "A1", startingPosition: CourtPosition.right),
          player2: Player(name: "A2", startingPosition: CourtPosition.left),
        ),
        teamBPlayers: TeamPlayers(
          player1: Player(name: "B1", startingPosition: CourtPosition.right),
          player2: Player(name: "B2", startingPosition: CourtPosition.left),
        ),
      );
    });

    test('Initial State is correct', () {
      final state = provider.state;
      expect(state.currentServer, Team.A);
      expect(state.currentServerPlayer?.name, "A1");
      expect(state.playerPositions["A1"], CourtPosition.right);
      expect(state.playerPositions["A2"], CourtPosition.left);
      expect(state.playerPositions["B1"], CourtPosition.right);
      expect(state.playerPositions["B2"], CourtPosition.left);
    });

    test(
      'Server wins point -> Points increase, Server same, Positions swap',
      () {
        // Team A serves (A1 from Right). A wins.
        provider.scorePoint(Team.A);

        final state = provider.state;
        expect(state.currentGame.scoreA, 1);
        expect(state.currentServer, Team.A);
        expect(state.currentServerPlayer?.name, "A1"); // A1 continues serving

        // A1 was Right, A2 was Left.
        // Score 1-0 (Odd). Server should be Left.
        // So A1 should have swapped to Left.
        expect(state.playerPositions["A1"], CourtPosition.left);
        expect(state.playerPositions["A2"], CourtPosition.right);

        // B positions should NOT change
        expect(state.playerPositions["B1"], CourtPosition.right);
        expect(state.playerPositions["B2"], CourtPosition.left);
      },
    );

    test(
      'Receiver wins point -> Service Over, Server changes, No Position Swap',
      () {
        // Team A serves. Team B wins.
        provider.scorePoint(Team.B);

        final state = provider.state;
        expect(state.currentGame.scoreB, 1);
        expect(state.currentServer, Team.B);

        // Score 0-1. Odd. Server should be from Left.
        // B1 is Right, B2 is Left.
        // So B2 should be the new server.
        expect(state.currentServerPlayer?.name, "B2");

        // Positions should NOT change for anyone
        expect(state.playerPositions["A1"], CourtPosition.right);
        expect(state.playerPositions["A2"], CourtPosition.left);
        expect(state.playerPositions["B1"], CourtPosition.right);
        expect(state.playerPositions["B2"], CourtPosition.left);
      },
    );
  });

  group('MatchProvider Match Format', () {
    late MatchProvider provider;

    setUp(() {
      provider = MatchProvider();
    });

    test('Single match ends after first game win', () {
      provider.initializeMatch(
        teamAName: "Team A",
        teamBName: "Team B",
        matchType: MatchType.singles,
        matchFormat: MatchFormat.single,
        teamAPlayers: TeamPlayers(
          player1: Player(name: "A1", startingPosition: CourtPosition.right),
        ),
        teamBPlayers: TeamPlayers(
          player1: Player(name: "B1", startingPosition: CourtPosition.right),
        ),
      );

      for (int i = 0; i < 21; i++) {
        provider.scorePoint(Team.A);
      }

      final state = provider.state;
      expect(state.matchWinner, Team.A);
      expect(state.gamesWonA, 1);
      expect(state.games.length, 1);
    });

    test('Best of 5 requires 3 game wins', () {
      provider.initializeMatch(
        teamAName: "Team A",
        teamBName: "Team B",
        matchType: MatchType.singles,
        matchFormat: MatchFormat.bestOf5,
        teamAPlayers: TeamPlayers(
          player1: Player(name: "A1", startingPosition: CourtPosition.right),
        ),
        teamBPlayers: TeamPlayers(
          player1: Player(name: "B1", startingPosition: CourtPosition.right),
        ),
      );

      for (int i = 0; i < 42; i++) {
        provider.scorePoint(Team.A);
      }
      expect(provider.state.matchWinner, isNull);
      expect(provider.state.gamesWonA, 2);

      for (int i = 0; i < 21; i++) {
        provider.scorePoint(Team.A);
      }

      final state = provider.state;
      expect(state.matchWinner, Team.A);
      expect(state.gamesWonA, 3);
    });
  });
}
