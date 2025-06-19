import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/match_provider.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({Key? key}) : super(key: key);

  /// Build bar groups for the global roll frequency chart.
  List<BarChartGroupData> _buildGlobalBarGroups(Map<int, int> frequency) {
    List<BarChartGroupData> groups = [];
    frequency.forEach((roll, count) {
      groups.add(
        BarChartGroupData(
          x: roll,
          barRods: [
            BarChartRodData(
              toY: count.toDouble(),
              width: 16,
              color: Colors.tealAccent,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    });
    groups.sort((a, b) => a.x.compareTo(b.x));
    return groups;
  }

  /// Build bar chart for an individual player's roll frequency.
  BarChartData _buildPlayerBarChartData(Map<int, int> frequency) {
    List<BarChartGroupData> groups = [];
    frequency.forEach((roll, count) {
      groups.add(
        BarChartGroupData(
          x: roll,
          barRods: [
            BarChartRodData(
              toY: count.toDouble(),
              width: 12,
              color: Colors.orangeAccent,
              borderRadius: BorderRadius.circular(2),
            ),
          ],
        ),
      );
    });
    groups.sort((a, b) => a.x.compareTo(b.x));
    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: (frequency.values.isNotEmpty ? frequency.values.reduce((a, b) => a > b ? a : b).toDouble() : 1) + 1,
      barGroups: groups,
      borderData: FlBorderData(show: false),
      gridData: FlGridData(show: true),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              return Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 12),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: const TextStyle(fontSize: 12),
              );
            },
          ),
        ),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
    );
  }

  /// Build pie chart sections for an individual player's roll frequencies.
  List<PieChartSectionData> _buildPlayerPieSections(Map<int, int> frequency) {
    int total = frequency.values.fold(0, (prev, element) => prev + element);
    if (total == 0) return [];

    return frequency.entries.map((entry) {
      double percentage = (entry.value / total) * 100;
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '${entry.key}\n${percentage.toStringAsFixed(1)}%',
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
        radius: 50,
        titlePositionPercentageOffset: 0.55,
        color: Colors.primaries[entry.key % Colors.primaries.length],
      );
    }).toList();
  }

  /// Calculate metrics (average, standard deviation, max roll %)
  Map<String, double> _calculateMetrics(Map<int, int> frequency) {
    int totalRolls = frequency.values.fold(0, (prev, cur) => prev + cur);
    if (totalRolls == 0) {
      return {'average': 0, 'stdDev': 0, 'maxPercent': 0};
    }
    double sum = 0;
    double sumSquares = 0;
    frequency.forEach((roll, count) {
      sum += roll * count;
      sumSquares += roll * roll * count;
    });
    double average = sum / totalRolls;
    double variance = (sumSquares / totalRolls) - (average * average);
    double stdDev = variance > 0 ? sqrt(variance) : 0;

    // Max possible roll for this mode is assumed to be the highest key in frequency.
    int maxOutcome = frequency.keys.isNotEmpty ? frequency.keys.reduce((a, b) => a > b ? a : b) : 0;
    int maxCount = frequency[maxOutcome] ?? 0;
    double maxPercent = (maxCount / totalRolls) * 100;

    return {'average': average, 'stdDev': stdDev, 'maxPercent': maxPercent};
  }

  /// Build a card displaying global metrics.
  Widget _buildGlobalMetricsCard(Map<int, int> globalFrequency) {
    Map<String, double> metrics = _calculateMetrics(globalFrequency);
    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Global Metrics', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.tealAccent)),
            const SizedBox(height: 8),
            Text('Average Roll: ${metrics['average']!.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            Text('Std. Deviation: ${metrics['stdDev']!.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            Text('Max Roll Frequency: ${metrics['maxPercent']!.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  /// Build a card displaying individual player metrics.
  Widget _buildPlayerMetricsCard(String playerName, Map<int, int> frequency) {
    Map<String, double> metrics = _calculateMetrics(frequency);
    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              playerName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.tealAccent),
            ),
            const SizedBox(height: 8),
            Text('Total Rolls: ${frequency.values.fold(0, (prev, cur) => prev + cur)}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Average Roll: ${metrics['average']!.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            Text('Std. Deviation: ${metrics['stdDev']!.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            Text('Max Roll Frequency: ${metrics['maxPercent']!.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final matchProvider = Provider.of<MatchProvider>(context);

    // Global frequency aggregated from all players.
    Map<int, int> globalFrequency = {};
    for (var player in matchProvider.players) {
      player.rollFrequencies.forEach((roll, count) {
        globalFrequency[roll] = (globalFrequency[roll] ?? 0) + count;
      });
    }
    List<BarChartGroupData> globalBarGroups = _buildGlobalBarGroups(globalFrequency);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Stats'),
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Global Roll Frequency',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (globalFrequency.values.isNotEmpty
                      ? globalFrequency.values.reduce((a, b) => a > b ? a : b).toDouble()
                      : 1) +
                      1,
                  barGroups: globalBarGroups,
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              value.toInt().toString(),
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                ),
              ),
            ),
            // Global metrics card.
            _buildGlobalMetricsCard(globalFrequency),
            const SizedBox(height: 24),
            const Text(
              'Individual Player Stats',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // For each player: include the charts and a metrics card.
            ...matchProvider.players.map((player) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    color: const Color(0xFF1E1E1E),
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            player.name,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.tealAccent),
                          ),
                          const SizedBox(height: 8),
                          Text('Total Rolls: ${player.totalRolls}', style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 12),
                          const Text('Roll Distribution', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 200,
                            child: BarChart(_buildPlayerBarChartData(player.rollFrequencies)),
                          ),
                          const SizedBox(height: 12),
                          const Text('Roll Percentage', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 200,
                            child: PieChart(
                              PieChartData(
                                sections: _buildPlayerPieSections(player.rollFrequencies),
                                sectionsSpace: 2,
                                centerSpaceRadius: 40,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Additional metrics card for the player.
                  _buildPlayerMetricsCard(player.name, player.rollFrequencies),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
