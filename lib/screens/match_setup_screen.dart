import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/match_state.dart';
import '../providers/match_provider.dart';
import 'match_screen.dart';

class MatchSetupScreen extends StatefulWidget {
  const MatchSetupScreen({super.key});

  @override
  State<MatchSetupScreen> createState() => _MatchSetupScreenState();
}

class _MatchSetupScreenState extends State<MatchSetupScreen> {
  MatchType _matchType = MatchType.singles;

  // Team names
  final _teamAController = TextEditingController(text: "Team A");
  final _teamBController = TextEditingController(text: "Team B");

  // Team A players
  final _teamAPlayer1Controller = TextEditingController(text: "Player 1");
  final _teamAPlayer2Controller = TextEditingController(text: "Player 2");
  CourtPosition _teamAPlayer1Position = CourtPosition.right;
  CourtPosition _teamAPlayer2Position = CourtPosition.left;

  // Team B players
  final _teamBPlayer1Controller = TextEditingController(text: "Player 3");
  final _teamBPlayer2Controller = TextEditingController(text: "Player 4");
  CourtPosition _teamBPlayer1Position = CourtPosition.right;
  CourtPosition _teamBPlayer2Position = CourtPosition.left;

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
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text("Match Setup"),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Match Type Selection
            const Text(
              "Match Type",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<MatchType>(
              segments: const [
                ButtonSegment(
                  value: MatchType.singles,
                  label: Text("Singles"),
                  icon: Icon(Icons.person),
                ),
                ButtonSegment(
                  value: MatchType.doubles,
                  label: Text("Doubles"),
                  icon: Icon(Icons.people),
                ),
              ],
              selected: {_matchType},
              onSelectionChanged: (Set<MatchType> newSelection) {
                setState(() {
                  _matchType = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 32),

            // Team A
            _buildTeamSection(
              "Team A",
              _teamAController,
              _teamAPlayer1Controller,
              _teamAPlayer2Controller,
              _teamAPlayer1Position,
              _teamAPlayer2Position,
              (pos) => setState(() => _teamAPlayer1Position = pos),
              (pos) => setState(() => _teamAPlayer2Position = pos),
              Colors.green[700]!,
            ),
            const SizedBox(height: 24),

            // Team B
            _buildTeamSection(
              "Team B",
              _teamBController,
              _teamBPlayer1Controller,
              _teamBPlayer2Controller,
              _teamBPlayer1Position,
              _teamBPlayer2Position,
              (pos) => setState(() => _teamBPlayer1Position = pos),
              (pos) => setState(() => _teamBPlayer2Position = pos),
              Colors.blue[700]!,
            ),
            const SizedBox(height: 32),

            // Start Match Button
            ElevatedButton(
              onPressed: _startMatch,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[700],
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Start Match",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamSection(
    String teamLabel,
    TextEditingController teamNameController,
    TextEditingController player1Controller,
    TextEditingController player2Controller,
    CourtPosition player1Position,
    CourtPosition player2Position,
    Function(CourtPosition) onPlayer1PositionChanged,
    Function(CourtPosition) onPlayer2PositionChanged,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            teamLabel,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: teamNameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: "Team Name",
              labelStyle: const TextStyle(color: Colors.white70),
              border: const OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: color.withOpacity(0.5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: color),
              ),
            ),
          ),
          if (_matchType == MatchType.doubles) ...[
            const SizedBox(height: 16),
            const Text(
              "Players",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            _buildPlayerInput(
              "Player 1",
              player1Controller,
              player1Position,
              onPlayer1PositionChanged,
              color,
            ),
            const SizedBox(height: 12),
            _buildPlayerInput(
              "Player 2",
              player2Controller,
              player2Position,
              onPlayer2PositionChanged,
              color,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlayerInput(
    String label,
    TextEditingController controller,
    CourtPosition position,
    Function(CourtPosition) onPositionChanged,
    Color color,
  ) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(color: Colors.white70),
              border: const OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: color.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: color),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonFormField<CourtPosition>(
            value: position,
            dropdownColor: Colors.grey[800],
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: "Side",
              labelStyle: const TextStyle(color: Colors.white70),
              border: const OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: color.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: color),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            items: const [
              DropdownMenuItem(value: CourtPosition.left, child: Text("Left")),
              DropdownMenuItem(
                value: CourtPosition.right,
                child: Text("Right"),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                onPositionChanged(value);
              }
            },
          ),
        ),
      ],
    );
  }

  void _startMatch() {
    final matchProvider = context.read<MatchProvider>();

    // Create team players based on match type
    TeamPlayers teamAPlayers;
    TeamPlayers teamBPlayers;

    if (_matchType == MatchType.singles) {
      teamAPlayers = TeamPlayers(
        player1: Player(
          name: _teamAPlayer1Controller.text.trim(),
          startingPosition: CourtPosition.right,
        ),
      );
      teamBPlayers = TeamPlayers(
        player1: Player(
          name: _teamBPlayer1Controller.text.trim(),
          startingPosition: CourtPosition.right,
        ),
      );
    } else {
      teamAPlayers = TeamPlayers(
        player1: Player(
          name: _teamAPlayer1Controller.text.trim(),
          startingPosition: _teamAPlayer1Position,
        ),
        player2: Player(
          name: _teamAPlayer2Controller.text.trim(),
          startingPosition: _teamAPlayer2Position,
        ),
      );
      teamBPlayers = TeamPlayers(
        player1: Player(
          name: _teamBPlayer1Controller.text.trim(),
          startingPosition: _teamBPlayer1Position,
        ),
        player2: Player(
          name: _teamBPlayer2Controller.text.trim(),
          startingPosition: _teamBPlayer2Position,
        ),
      );
    }

    // Initialize match with setup data
    matchProvider.initializeMatch(
      teamAName: _teamAController.text.trim(),
      teamBName: _teamBController.text.trim(),
      matchType: _matchType,
      teamAPlayers: teamAPlayers,
      teamBPlayers: teamBPlayers,
    );

    // Navigate to match screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MatchScreen()),
    );
  }
}
