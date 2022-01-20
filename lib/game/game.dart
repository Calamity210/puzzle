import 'package:flutter/material.dart';
import 'package:puzzle/game/level.dart';
import 'package:puzzle/map/map.dart';

class Game extends ChangeNotifier {
  Game({
    required this.level,
    required this.map,
  });

  Level level;
  GameMap map;

  void newLevel(double tileSize, int size, int boxesCount) {
    level = Level.newLevel(tileSize, size, boxesCount);
    map = GameMap(level: level, tileSize: tileSize);
    notifyListeners();
  }
}
