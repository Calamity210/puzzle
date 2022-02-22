import 'package:flutter/material.dart';
import 'package:puzzle/game/level.dart';
import 'package:puzzle/map/map.dart';

class Game extends ChangeNotifier {
  Game({
    required this.level,
    required this.map,
  }) : startTime = DateTime.now();

  Level level;
  GameMap map;
  DateTime startTime;

  void newLevel(double tileSize, int size, int boxesCount) {
    level = Level.newLevel(tileSize, size, boxesCount);
    map = GameMap(level: level, tileSize: tileSize);
    startTime = DateTime.now();
    notifyListeners();
  }
}
