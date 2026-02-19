import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/match_state.dart';
import '../providers/match_provider.dart';
import '../theme/app_theme.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final matchProvider = context.watch<MatchProvider>();
    final state = matchProvider.state;

    final allEvents = <RallyEvent>[
      for (final game in state.games) ...game.rallyHistory,
    ];

    final statsA = <WinReason, int>{};
    final statsB = <WinReason, int>{};
    for (final event in allEvents) {
      if (event.scoringTeam == Team.A) {
        statsA[event.reason] = (statsA[event.reason] ?? 0) + 1;
      } else {
        statsB[event.reason] = (statsB[event.reason] ?? 0) + 1;
      }
    }

    final totalA = state.games.fold<int>(0, (p, g) => p + g.scoreA);
    final totalB = state.games.fold<int>(0, (p, g) => p + g.scoreB);

    return Scaffold(
      appBar: AppBar(title: const Text("Match Statistics")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _scoreTile(state.teamAName, totalA, AppColors.teamA),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _scoreTile(state.teamBName, totalB, AppColors.teamB),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _header(state.teamAName, state.teamBName),
                  const SizedBox(height: 8),
                  _statRow("Total Points", totalA, totalB, emphasis: true),
                  const Divider(height: 20),
                  ...WinReason.values.map(
                    (reason) => _statRow(
                      reason.displayName,
                      statsA[reason] ?? 0,
                      statsB[reason] ?? 0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _scoreTile(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "$value",
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(String teamA, String teamB) {
    return Row(
      children: [
        Expanded(
          child: Text(
            teamA,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.teamA,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(
          width: 100,
          child: Text(
            "Metric",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            teamB,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.teamB,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _statRow(String label, int a, int b, {bool emphasis = false}) {
    if (!emphasis && a == 0 && b == 0) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "$a",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: emphasis ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: emphasis ? AppColors.textPrimary : AppColors.textSecondary,
                fontWeight: emphasis ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              "$b",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: emphasis ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
