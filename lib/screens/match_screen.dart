import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/match_state.dart';
import '../providers/match_provider.dart';

class MatchScreen extends StatelessWidget {
  const MatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final matchProvider = context.watch<MatchProvider>();
    final matchState = matchProvider.state;
    final currentGame = matchState.currentGame;

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text("Badminton Score Keeper"),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              context.push('/match/stats');
            },
          ),
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: matchProvider.undo,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'reset') {
                _showResetDialog(context, matchProvider);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'reset', child: Text('Reset Match')),
            ],
          ),
        ],
      ),
      body: matchState.matchWinner != null
          ? _buildMatchWinnerView(context, matchState, matchProvider)
          : _buildMatchView(context, matchState, matchProvider, currentGame),
    );
  }

  Widget _buildMatchView(
    BuildContext context,
    MatchState matchState,
    MatchProvider matchProvider,
    GameState currentGame,
  ) {
    return Column(
      children: [
        // Match Score (Games Won)
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          color: Colors.blueGrey[800],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                "Games: ${matchState.gamesWonA} - ${matchState.gamesWonB}",
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              Text(
                "Game ${currentGame.gameNumber}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // Team Names & Scores
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTeamScore(
                context,
                Team.A,
                matchState.teamAName,
                currentGame.scoreA,
                matchState,
              ),
              const SizedBox(height: 40),
              const Text(
                "VS",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 40),
              _buildTeamScore(
                context,
                Team.B,
                matchState.teamBName,
                currentGame.scoreB,
                matchState,
              ),
            ],
          ),
        ),

        // Score Buttons
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: currentGame.winner == null
                      ? () {
                          HapticFeedback.mediumImpact();
                          matchProvider.scorePoint(Team.A);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "${matchState.teamAName} Scores",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: currentGame.winner == null
                      ? () {
                          HapticFeedback.mediumImpact();
                          matchProvider.scorePoint(Team.B);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "${matchState.teamBName} Scores",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTeamScore(
    BuildContext context,
    Team team,
    String teamName,
    int score,
    MatchState state,
  ) {
    final TeamPlayers players = (team == Team.A)
        ? state.teamAPlayers
        : state.teamBPlayers;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => _showEditTeamNameDialog(context, teamName),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    teamName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.edit, size: 16, color: Colors.white54),
                ],
              ),
            ),
          ],
        ),
        // Player Names Display
        if (state.matchType == MatchType.doubles ||
            players.player1.name.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildPlayerInfo(players.player1, state),
          if (players.player2 != null) ...[
            const SizedBox(height: 4),
            _buildPlayerInfo(players.player2!, state),
          ],
        ],
        const SizedBox(height: 12),
        Text(
          score.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 72,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMatchWinnerView(
    BuildContext context,
    MatchState matchState,
    MatchProvider matchProvider,
  ) {
    final winnerName = matchState.matchWinner == Team.A
        ? matchState.teamAName
        : matchState.teamBName;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.emoji_events, size: 100, color: Colors.amber),
          const SizedBox(height: 24),
          const Text(
            "Match Winner!",
            style: TextStyle(color: Colors.white70, fontSize: 24),
          ),
          const SizedBox(height: 12),
          Text(
            winnerName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Games: ${matchState.gamesWonA} - ${matchState.gamesWonB}",
            style: const TextStyle(color: Colors.white70, fontSize: 20),
          ),
          const SizedBox(height: 48),
          ElevatedButton.icon(
            onPressed: () {
              context.push('/match/stats');
            },
            icon: const Icon(Icons.bar_chart),
            label: const Text("View Stats"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              matchProvider.resetMatch();
              context.go('/'); // Return to setup screen (root)
            },
            icon: const Icon(Icons.refresh),
            label: const Text("New Match"),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, MatchProvider matchProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reset Match"),
        content: const Text(
          "Are you sure you want to reset the match? All progress will be lost and you'll return to match setup.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              matchProvider.resetMatch();
              context.go('/'); // Return to setup screen
            },
            child: const Text("Reset", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEditTeamNameDialog(BuildContext context, String currentName) {
    final matchProvider = context.read<MatchProvider>();
    final matchState = matchProvider.state;
    final isTeamA = currentName == matchState.teamAName;
    final controller = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit ${isTeamA ? 'Team A' : 'Team B'} Name"),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: "Team Name",
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              if (isTeamA) {
                matchProvider.setTeamNames(value.trim(), matchState.teamBName);
              } else {
                matchProvider.setTeamNames(matchState.teamAName, value.trim());
              }
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                if (isTeamA) {
                  matchProvider.setTeamNames(newName, matchState.teamBName);
                } else {
                  matchProvider.setTeamNames(matchState.teamAName, newName);
                }
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerInfo(Player player, MatchState state) {
    bool isServer = state.currentServerPlayer?.name == player.name;
    CourtPosition? pos = state.playerPositions[player.name];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isServer) ...[
          const Icon(Icons.sports_tennis, size: 14, color: Colors.amber),
          const SizedBox(width: 4),
        ],
        Text(
          player.name,
          style: TextStyle(
            color: isServer ? Colors.amber : Colors.white70,
            fontSize: 16,
            fontWeight: isServer ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        if (pos != null && state.matchType == MatchType.doubles) ...[
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              pos == CourtPosition.right ? "R" : "L",
              style: const TextStyle(fontSize: 10, color: Colors.white),
            ),
          ),
        ],
      ],
    );
  }
}
