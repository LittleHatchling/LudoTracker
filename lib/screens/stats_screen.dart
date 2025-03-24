import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/match_provider.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({Key? key}) : super(key: key);

  /// Build bar groups for the global roll frequency chart.
  List<BarChartGroupData> _buildBarGroups(Map<int, int> frequency) {
    List<BarChartGroupData> groups = [];
    frequency.forEach((roll, count) {
      groups.add(
        BarChartGroupData(
          x: roll,
          barRods: [
            BarChartRodData(
              toY: count.toDouble(),
              width: 16,
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    });
    groups.sort((a, b) => a.x.compareTo(b.x));
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final matchProvider = Provider.of<MatchProvider>(context);

    // Aggregate global frequencies from all players.
    Map<int, int> globalFrequency = {};
    for (var player in matchProvider.players) {
      player.rollFrequencies.forEach((roll, count) {
        globalFrequency[roll] = (globalFrequency[roll] ?? 0) + count;
      });
    }

    List<BarChartGroupData> barGroups = _buildBarGroups(globalFrequency);

    return Scaffold(
      appBar: AppBar(title: const Text('Match Stats')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Global Roll Frequency',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (globalFrequency.values.isNotEmpty ? globalFrequency.values.reduce((a, b) => a > b ? a : b).toDouble() : 1) + 1,
                  barGroups: barGroups,
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString(), style: const TextStyle(fontSize: 12));
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 28),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Individual Player Stats',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...matchProvider.players.map((player) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(player.name),
                  subtitle: Text(
                      'Total Rolls: ${player.totalRolls} | 6s: ${player.rollFrequencies[6] ?? 0}'),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
