import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/match_provider.dart';
import 'score_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({Key? key}) : super(key: key);

  @override
  _SetupScreenState createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  int _playerCount = 2;
  int _diceCount = 1;
  List<TextEditingController> _nameControllers = [];

  @override
  void initState() {
    super.initState();
    _initializeNameControllers();
  }

  void _initializeNameControllers() {
    _nameControllers = List.generate(4, (index) => TextEditingController());
  }

  @override
  void dispose() {
    for (var controller in _nameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _startMatch() {
    List<String> playerNames = _nameControllers
        .take(_playerCount)
        .map((controller) => controller.text.trim().isEmpty ? 'Player' : controller.text)
        .toList();

    Provider.of<MatchProvider>(context, listen: false)
        .initMatch(playerNames: playerNames, diceCount: _diceCount);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ScoreScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Setup Match')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text('Select number of players', style: TextStyle(fontSize: 16)),
            DropdownButton<int>(
              value: _playerCount,
              onChanged: (val) {
                setState(() {
                  _playerCount = val!;
                });
              },
              items: [2, 3, 4]
                  .map((count) => DropdownMenuItem(
                value: count,
                child: Text('$count Players'),
              ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            const Text('Select number of dice', style: TextStyle(fontSize: 16)),
            DropdownButton<int>(
              value: _diceCount,
              onChanged: (val) {
                setState(() {
                  _diceCount = val!;
                });
              },
              items: [1, 2, 3, 4]
                  .map((count) => DropdownMenuItem(
                value: count,
                child: Text('$count Dice'),
              ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            const Text('Enter player names', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            ...List.generate(_playerCount, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  controller: _nameControllers[index],
                  decoration: InputDecoration(
                    labelText: 'Player ${index + 1} Name',
                    border: const OutlineInputBorder(),
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _startMatch,
              child: const Text('Start Match'),
            ),
          ],
        ),
      ),
    );
  }
}
