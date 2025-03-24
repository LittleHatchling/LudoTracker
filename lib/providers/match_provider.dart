import 'package:flutter/material.dart';
import '../models/player.dart';

class MatchProvider with ChangeNotifier {
  List<Player> players = [];
  int currentPlayerIndex = 0;
  int numberOfDice = 1;

  /// Initialize match with player names and dice count.
  void initMatch({required List<String> playerNames, required int diceCount}) {
    players = playerNames.map((name) => Player(name: name)).toList();
    numberOfDice = diceCount;
    currentPlayerIndex = 0;
    notifyListeners();
  }

  /// Record the roll for the current player and move to the next.
  void recordRoll(int rollValue) {
    players[currentPlayerIndex].addRoll(rollValue);
    currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
    notifyListeners();
  }
}
