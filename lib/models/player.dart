class Player {
  final String name;
  int totalRolls = 0;
  Map<int, int> rollFrequencies = {}; // key: roll value (sum), value: frequency

  Player({required this.name});

  void addRoll(int value) {
    totalRolls++;
    rollFrequencies[value] = (rollFrequencies[value] ?? 0) + 1;
  }
}
