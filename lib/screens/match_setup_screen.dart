import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/match_state.dart';
import '../providers/match_provider.dart';

class MatchSetupScreen extends StatefulWidget {
  const MatchSetupScreen({super.key});

  @override
  State<MatchSetupScreen> createState() => _MatchSetupScreenState();
}

class _MatchSetupScreenState extends State<MatchSetupScreen> {
  MatchType _matchType = MatchType.singles;
  MatchFormat _matchFormat = MatchFormat.bestOf3;

  final _teamAController = TextEditingController();
  final _teamBController = TextEditingController();
  final _teamAPlayer1Controller = TextEditingController();
  final _teamAPlayer2Controller = TextEditingController();
  final _teamBPlayer1Controller = TextEditingController();
  final _teamBPlayer2Controller = TextEditingController();

  bool get _canStartMatch {
    final singlesPlayersValid =
        _teamAPlayer1Controller.text.trim().isNotEmpty &&
        _teamBPlayer1Controller.text.trim().isNotEmpty;
    if (_matchType == MatchType.singles) {
      return singlesPlayersValid;
    }

    final doublesPlayersValid =
        _teamAPlayer2Controller.text.trim().isNotEmpty &&
        _teamBPlayer2Controller.text.trim().isNotEmpty;
    return singlesPlayersValid && doublesPlayersValid;
  }

  @override
  void dispose() {
    _teamAController.dispose();
    _teamBController.dispose();
    _teamAPlayer1Controller.dispose();
    _teamAPlayer2Controller.dispose();
    _teamBPlayer1Controller.dispose();
    _teamBPlayer2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final surface = Theme.of(context).colorScheme.surface;
    final fieldBg = dark ? const Color(0xFF1F2937) : const Color(0xFFF8FAFC);
    final divider = dark ? const Color(0xFF1F2937) : const Color(0xFFE2E8F0);
    final textMuted = dark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Match Setup',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: divider),
        ),
        leading: IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _sectionLabel('Match Type', textMuted),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _matchTypeCard(
                                title: 'Singles',
                                selected: _matchType == MatchType.singles,
                                icon: Icons.sports_tennis,
                                onTap: () {
                                  setState(
                                    () => _matchType = MatchType.singles,
                                  );
                                },
                                colorScheme: colorScheme,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _matchTypeCard(
                                title: 'Doubles',
                                selected: _matchType == MatchType.doubles,
                                icon: Icons.groups_2_outlined,
                                onTap: () {
                                  setState(
                                    () => _matchType = MatchType.doubles,
                                  );
                                },
                                colorScheme: colorScheme,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _sectionLabel('Match Format', textMuted),
                        const SizedBox(height: 12),
                        _formatSelector(colorScheme, surface, textMuted),
                        const SizedBox(height: 24),
                        _teamConfigurationCard(
                          title: 'Team A Configuration',
                          dotColor: const Color(0xFF3B82F6),
                          teamController: _teamAController,
                          player1Controller: _teamAPlayer1Controller,
                          player2Controller: _teamAPlayer2Controller,
                          fieldBg: fieldBg,
                          textMuted: textMuted,
                        ),
                        const SizedBox(height: 20),
                        _teamConfigurationCard(
                          title: 'Team B Configuration',
                          dotColor: const Color(0xFFEF4444),
                          teamController: _teamBController,
                          player1Controller: _teamBPlayer1Controller,
                          player2Controller: _teamBPlayer2Controller,
                          fieldBg: fieldBg,
                          textMuted: textMuted,
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  decoration: BoxDecoration(
                    color: surface.withValues(alpha: 0.95),
                    border: Border(top: BorderSide(color: divider)),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _canStartMatch ? _startMatch : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF258CF4),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text(
                        'Start Match',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text, Color mutedColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          letterSpacing: 0.7,
          fontWeight: FontWeight.w700,
          color: mutedColor,
        ),
      ),
    );
  }

  Widget _matchTypeCard({
    required String title,
    required bool selected,
    required IconData icon,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? const Color(0xFF258CF4) : Colors.transparent,
            width: 2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x120F172A),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF258CF4).withValues(alpha: 0.12),
              ),
              child: Icon(icon, color: const Color(0xFF258CF4), size: 26),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _formatSelector(ColorScheme colorScheme, Color surface, Color muted) {
    return Container(
      decoration: BoxDecoration(
        color: muted.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _formatOption(
            title: '1 Set',
            selected: _matchFormat == MatchFormat.single,
            onTap: () => setState(() => _matchFormat = MatchFormat.single),
            surface: surface,
            accent: colorScheme.primary,
          ),
          _formatOption(
            title: 'Best of 3',
            selected: _matchFormat == MatchFormat.bestOf3,
            onTap: () => setState(() => _matchFormat = MatchFormat.bestOf3),
            surface: surface,
            accent: colorScheme.primary,
          ),
          _formatOption(
            title: 'Best of 5',
            selected: _matchFormat == MatchFormat.bestOf5,
            onTap: () => setState(() => _matchFormat = MatchFormat.bestOf5),
            surface: surface,
            accent: colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _formatOption({
    required String title,
    required bool selected,
    required VoidCallback onTap,
    required Color surface,
    required Color accent,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? surface : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? accent : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _teamConfigurationCard({
    required String title,
    required Color dotColor,
    required TextEditingController teamController,
    required TextEditingController player1Controller,
    required TextEditingController player2Controller,
    required Color fieldBg,
    required Color textMuted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: dotColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 0.7,
                  fontWeight: FontWeight.w700,
                  color: textMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF334155)
                  : const Color(0xFFE2E8F0),
            ),
            color: Theme.of(context).colorScheme.surface,
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 12,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _fieldLabel('Team Name (Optional)', textMuted),
              const SizedBox(height: 6),
              _textField(
                controller: teamController,
                hint: title.startsWith('Team A')
                    ? 'e.g. Smash Kings'
                    : 'e.g. Shuttle Warriors',
                icon: Icons.shield_outlined,
                fieldBg: fieldBg,
              ),
              const SizedBox(height: 12),
              _fieldLabel('Players', textMuted),
              const SizedBox(height: 6),
              _textField(
                controller: player1Controller,
                hint: 'Player 1 Name',
                icon: Icons.person_outline,
                fieldBg: fieldBg,
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: _matchType == MatchType.doubles
                    ? Padding(
                        key: const ValueKey('doubles-2nd-player'),
                        padding: const EdgeInsets.only(top: 10),
                        child: _textField(
                          controller: player2Controller,
                          hint: 'Player 2 Name',
                          icon: Icons.person_outline,
                          fieldBg: fieldBg,
                        ),
                      )
                    : const SizedBox.shrink(
                        key: ValueKey('singles-no-2nd-player'),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _fieldLabel(String text, Color mutedColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: mutedColor,
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color fieldBg,
  }) {
    return TextField(
      controller: controller,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: fieldBg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: const Color(0xFF258CF4).withValues(alpha: 0.35),
            width: 1.3,
          ),
        ),
      ),
    );
  }

  void _startMatch() {
    final matchProvider = context.read<MatchProvider>();

    final teamAName = _teamAController.text.trim().isEmpty
        ? 'Team A'
        : _teamAController.text.trim();
    final teamBName = _teamBController.text.trim().isEmpty
        ? 'Team B'
        : _teamBController.text.trim();

    final teamAPlayers = _matchType == MatchType.singles
        ? TeamPlayers(
            player1: Player(
              name: _teamAPlayer1Controller.text.trim(),
              startingPosition: CourtPosition.right,
            ),
          )
        : TeamPlayers(
            player1: Player(
              name: _teamAPlayer1Controller.text.trim(),
              startingPosition: CourtPosition.right,
            ),
            player2: Player(
              name: _teamAPlayer2Controller.text.trim(),
              startingPosition: CourtPosition.left,
            ),
          );

    final teamBPlayers = _matchType == MatchType.singles
        ? TeamPlayers(
            player1: Player(
              name: _teamBPlayer1Controller.text.trim(),
              startingPosition: CourtPosition.right,
            ),
          )
        : TeamPlayers(
            player1: Player(
              name: _teamBPlayer1Controller.text.trim(),
              startingPosition: CourtPosition.right,
            ),
            player2: Player(
              name: _teamBPlayer2Controller.text.trim(),
              startingPosition: CourtPosition.left,
            ),
          );

    matchProvider.initializeMatch(
      teamAName: teamAName,
      teamBName: teamBName,
      matchType: _matchType,
      matchFormat: _matchFormat,
      teamAPlayers: teamAPlayers,
      teamBPlayers: teamBPlayers,
    );

    context.go('/match');
  }
}
