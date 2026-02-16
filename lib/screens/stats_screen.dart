import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/match_state.dart';
import '../providers/match_provider.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final matchProvider = context.watch<MatchProvider>();
    final matchState = matchProvider.state;

    // Helper to calculate stats
    // We can filter rallyHistory for the entire match (all games)

    List<RallyEvent> allEvents = [];
    for (var game in matchState.games) {
      allEvents.addAll(game.rallyHistory);
    }

    Map<WinReason, int> statsA = {};
    Map<WinReason, int> statsB = {};

    for (var event in allEvents) {
      if (event.scoringTeam == Team.A) {
        statsA[event.reason] = (statsA[event.reason] ?? 0) + 1;
      } else {
        statsB[event.reason] = (statsB[event.reason] ?? 0) + 1;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Match Statistics"),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatHeader(matchState.teamAName, matchState.teamBName),
          const Divider(),
          // ...WinReason.values.map((reason) {
          //   return _buildStatRow(
          //     reason.displayName,
          //     statsA[reason] ?? 0,
          //     statsB[reason] ?? 0,
          //   );
          // }).toList(),
          const Divider(),
          _buildStatRow(
            "Total Points",
            matchState.games.fold(0, (p, g) => p + g.scoreA),
            matchState.games.fold(0, (p, g) => p + g.scoreB),
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatHeader(String nameA, String nameB) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              nameA,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(
            width: 80,
            child: Text(
              "VS",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              nameB,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(
    String label,
    int valA,
    int valB, {
    bool isTotal = false,
  }) {
    if (valA == 0 && valB == 0) {
      return const SizedBox.shrink(); // Hide if no stats for this reason
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              valA.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isTotal ? Colors.black : Colors.grey[700],
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Expanded(
            child: Text(
              valB.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
