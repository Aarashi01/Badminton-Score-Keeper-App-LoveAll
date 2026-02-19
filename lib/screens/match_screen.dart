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
    final dark = Theme.of(context).brightness == Brightness.dark;
    final pageBg = dark ? const Color(0xFF131F16) : const Color(0xFFF6F8F6);
    final headerBg = dark ? const Color(0xFF0F172A) : Colors.white;
    final footerBg = dark ? const Color(0xFF0F172A) : Colors.white;
    final border = dark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: pageBg,
      body: matchState.matchWinner != null
          ? _buildMatchWinnerView(context, matchState, matchProvider)
          : SafeArea(
              child: Column(
                children: [
                  Container(
                    color: headerBg,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.undo),
                              onPressed: matchProvider.undo,
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    'Game ${currentGame.gameNumber}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: dark
                                          ? const Color(0xFFF8FAFC)
                                          : const Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    _formatLabel(
                                      matchState.matchFormat,
                                    ).toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 11,
                                      letterSpacing: 0.8,
                                      fontWeight: FontWeight.w700,
                                      color: dark
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.bar_chart),
                              onPressed: () => context.push('/match/stats'),
                            ),
                          ],
                        ),
                        Divider(height: 1, color: border),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _buildMatchView(context, matchState, currentGame),
                  ),
                  Container(
                    color: footerBg,
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _scoreButton(
                                title: '+1 Point',
                                subtitle: matchState.teamAName,
                                color: const Color(0xFF29A847),
                                onPressed: currentGame.winner == null
                                    ? () {
                                        HapticFeedback.mediumImpact();
                                        matchProvider.scorePoint(Team.A);
                                      }
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _scoreButton(
                                title: '+1 Point',
                                subtitle: matchState.teamBName,
                                color: const Color(0xFF2563EB),
                                onPressed: currentGame.winner == null
                                    ? () {
                                        HapticFeedback.mediumImpact();
                                        matchProvider.scorePoint(Team.B);
                                      }
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _utilityBar(
                          context: context,
                          dark: dark,
                          onMatchSettingsTap: () =>
                              _showResetDialog(context, matchProvider),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: footerBg,
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
                    child: Row(
                      children: [
                        _navItem(
                          icon: Icons.sports_score,
                          label: 'Scoring',
                          active: true,
                          color: const Color(0xFF29A847),
                        ),
                        _navItem(
                          icon: Icons.history,
                          label: 'Matches',
                          active: false,
                        ),
                        _navItem(
                          icon: Icons.military_tech,
                          label: 'League',
                          active: false,
                        ),
                        _navItem(
                          icon: Icons.person,
                          label: 'Profile',
                          active: false,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildMatchView(
    BuildContext context,
    MatchState matchState,
    GameState currentGame,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: _teamCard(
                    team: Team.A,
                    teamName: matchState.teamAName,
                    players: matchState.teamAPlayers,
                    score: currentGame.scoreA,
                    isServing: matchState.currentServer == Team.A,
                    servingPlayerName: matchState.currentServerPlayer?.name,
                    matchType: matchState.matchType,
                    positions: matchState.playerPositions,
                    accent: const Color(0xFF29A847),
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: _teamCard(
                    team: Team.B,
                    teamName: matchState.teamBName,
                    players: matchState.teamBPlayers,
                    score: currentGame.scoreB,
                    isServing: matchState.currentServer == Team.B,
                    servingPlayerName: matchState.currentServerPlayer?.name,
                    matchType: matchState.matchType,
                    positions: matchState.playerPositions,
                    accent: const Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _teamCard({
    required Team team,
    required String teamName,
    required TeamPlayers players,
    required int score,
    required bool isServing,
    required String? servingPlayerName,
    required MatchType matchType,
    required Map<String, CourtPosition> positions,
    required Color accent,
  }) {
    final scoreProgress = (score / 30).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.30), width: 2),
        color: accent.withValues(alpha: 0.12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        teamName.toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                          color: accent,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _playersLabel(players),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isServing)
                  Icon(
                    Icons.sports_tennis,
                    size: 28,
                    color: accent.withValues(alpha: 0.95),
                  ),
              ],
            ),
            const Spacer(),
            Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: Text(
                  score.toString(),
                  key: ValueKey('$team-$score'),
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 96,
                    color: accent,
                    height: 0.9,
                    letterSpacing: -2,
                  ),
                ),
              ),
            ),
            const Spacer(),
            LinearProgressIndicator(
              value: scoreProgress,
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
              valueColor: AlwaysStoppedAnimation<Color>(accent),
              backgroundColor: accent.withValues(alpha: 0.2),
            ),
            if (matchType == MatchType.doubles) ...[
              const SizedBox(height: 8),
              Text(
                _doublesStatus(players, positions, servingPlayerName),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _scoreButton({
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        disabledBackgroundColor: color.withValues(alpha: 0.35),
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _utilityBar({
    required BuildContext context,
    required bool dark,
    required VoidCallback onMatchSettingsTap,
  }) {
    final now = TimeOfDay.now();
    final hh = now.hour.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');
    final textColor = dark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Row(
      children: [
        _utilityIcon(
          icon: Icons.timer_outlined,
          label: '$hh:$mm',
          color: textColor,
        ),
        const SizedBox(width: 20),
        _utilityIcon(icon: Icons.swap_horiz, label: 'Switch', color: textColor),
        const Spacer(),
        OutlinedButton.icon(
          onPressed: onMatchSettingsTap,
          icon: const Icon(Icons.settings, size: 16),
          label: const Text('Match Settings'),
          style: OutlinedButton.styleFrom(
            foregroundColor: dark ? Colors.white : const Color(0xFF0F172A),
            side: BorderSide(
              color: dark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _utilityIcon({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 1),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required bool active,
    Color color = const Color(0xFF94A3B8),
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28, color: active ? color : const Color(0xFF94A3B8)),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: active ? color : const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 460),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.emoji_events,
                size: 64,
                color: Color(0xFFF59E0B),
              ),
              const SizedBox(height: 10),
              const Text(
                'Match Winner',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                winnerName,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Games ${matchState.gamesWonA}-${matchState.gamesWonB}',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => context.push('/match/stats'),
                icon: const Icon(Icons.bar_chart),
                label: const Text('View Stats'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  matchProvider.resetMatch();
                  context.go('/');
                },
                icon: const Icon(Icons.refresh),
                label: const Text('New Match'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context, MatchProvider matchProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Match Settings'),
        content: const Text('Reset the current match and return to setup?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              matchProvider.resetMatch();
              context.go('/');
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  String _playersLabel(TeamPlayers players) {
    if (players.player2 == null) {
      return players.player1.name;
    }
    return '${players.player1.name} / ${players.player2!.name}';
  }

  String _doublesStatus(
    TeamPlayers players,
    Map<String, CourtPosition> positions,
    String? servingPlayerName,
  ) {
    final p1Pos = positions[players.player1.name];
    final p2Pos = players.player2 == null
        ? null
        : positions[players.player2!.name];
    final serverText = servingPlayerName == null
        ? ''
        : ' | Server: $servingPlayerName';
    final p1Text = p1Pos == null
        ? '-'
        : (p1Pos == CourtPosition.right ? 'R' : 'L');
    final p2Text = p2Pos == null
        ? '-'
        : (p2Pos == CourtPosition.right ? 'R' : 'L');
    return '${players.player1.name}($p1Text), ${players.player2?.name ?? ''}($p2Text)$serverText';
  }

  String _formatLabel(MatchFormat format) {
    switch (format) {
      case MatchFormat.single:
        return '1 Set';
      case MatchFormat.bestOf3:
        return 'Best of 3';
      case MatchFormat.bestOf5:
        return 'Best of 5';
    }
  }
}
