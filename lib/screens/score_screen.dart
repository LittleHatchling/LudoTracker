import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/match_provider.dart';
import 'stats_screen.dart';

class ScoreScreen extends StatelessWidget {
  const ScoreScreen({Key? key}) : super(key: key);

  /// Returns a list of possible roll outcomes based on the number of dice.
  List<int> getPossibleRolls(int diceCount) {
    int min = diceCount; // Minimum sum is when every die shows 1.
    int max = diceCount * 6; // Maximum sum.
    return List.generate(max - min + 1, (index) => min + index);
  }

  @override
  Widget build(BuildContext context) {
    final matchProvider = Provider.of<MatchProvider>(context);
    List<int> diceOutcomes = getPossibleRolls(matchProvider.numberOfDice);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Rolls'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatsScreen()),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Current Player: ${matchProvider.players[matchProvider.currentPlayerIndex].name}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                children: diceOutcomes.map((value) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                    onPressed: () {
                      matchProvider.recordRoll(value);
                    },
                    child: Text(
                      '$value',
                      style: const TextStyle(fontSize: 18),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
