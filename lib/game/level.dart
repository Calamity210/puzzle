import 'dart:math';

import 'package:puzzle/items/box.dart';
import 'package:puzzle/items/destination.dart';
import 'package:puzzle/map/map.dart';
import 'package:puzzle/pathfinder/generator.dart';
import 'package:puzzle/pathfinder/node.dart';
import 'package:puzzle/pathfinder/optimizer.dart';
import 'package:puzzle/player/dash.dart';
import 'package:puzzle/utils/extensions.dart';

class Level {
  Level({
    required this.size,
    required this.boxesCount,
  }) {
    defineAllowedSpots();
    placeObjects(boxesCount);
  }

  factory Level.newLevel(double tileSize, int size, int boxesCount) {
    final rand = Random();
    final level = Level(size: size, boxesCount: boxesCount);

    level.rip(rand.nextInt(7) - 2);
    generatePaths(level);

    if (level.unsolvable) {
      return Level.newLevel(tileSize, size, boxesCount);
    }

    level.activeSpots = [];
    if (boxesCount < 6) {
      optimizeLevel(level, rand.nextInt(2000) - 1000);
    }

    return level
      ..player = Dash(
        GameMap.getRelativeTilePosition(
          tileSize,
          level.playerStartX,
          level.playerStartY,
        ),
        tileSize,
      );
  }

  final int size;
  final int boxesCount;

  late Dash player;
  int playerStartX = 0;
  int playerStartY = 0;
  late Node playerPosition;

  final List<BoxData> boxes = [];
  final List ghostBoxes = [];

  final List<Destination> destinations = [];
  late int solvedCount = boxesCount;
  List activeSpots = [];

  final List<Node> allowedSpots = [];

  bool unsolvable = false;
  bool solved = false;

  late final List<List<Node>> nodes = List.generate(
    size,
    (i) => List.generate(
      size,
      (j) => Node(i, j),
    ),
  );

  void defineAllowedSpots() {
    for (var i = 2; i < nodes.length - 2; i++) {
      for (var j = 2; j < nodes.length - 2; j++) {
        allowedSpots.add(nodes[i][j]);
      }
    }
  }

  void placeObjects(int boxesCount) {
    // Place destinations and boxes
    for (var i = 0; i < boxesCount; i++) {
      final dPoint = randomPoint();
      if (dPoint != null) {
        destinations.add(Destination(dPoint.x, dPoint.y));
      }

      final bPoint = randomPoint();

      if (bPoint != null) {
        boxes.add(BoxData(bPoint, destinations[i]));
        nodes[bPoint.x][bPoint.y].hasBox = true;
      }
    }

    // Place player
    final pPoint =
        randomPoint() ?? Node(destinations.first.x, destinations.first.y,);

    playerPosition = Node(pPoint.x, pPoint.y);
    playerStartX = playerPosition.x;
    playerStartY = playerPosition.y;
  }

  Node? randomPoint() {
    if (allowedSpots.isEmpty) {
      return null;
    }

    final rand = Random().nextInt(allowedSpots.length);
    final x = allowedSpots[rand].x;
    final y = allowedSpots[rand].y;

    allowedSpots.removeAt(rand);
    nodes[x][y].wall = false;

    if (_blocked(x, y)) {
      return randomPoint();
    }

    return Node(x, y);
  }

  void rip(int amount) {
    for (var i = 0; i < amount; i++) {
      if (allowedSpots.isNotEmpty) {
        randomPoint();
      }
    }
  }

  bool _blocked(int x, int y) {
    final nextX = nodes[x + 1][y];
    final nextY = nodes[x][y + 1];
    final prevX = nodes[x - 1][y];
    final prevY = nodes[x][y - 1];
    final nextXY = nodes[x + 1][y + 1];
    final prevXY = nodes[x - 1][y - 1];
    final nextXPrevY = nodes[x + 1][y - 1];
    final prevXNextY = nodes[x - 1][y + 1];

    return (nextX.hasBox &&
            ((nextXY.hasBox && nextY.hasBox) ||
                (nextXPrevY.hasBox && prevY.hasBox))) ||
        (prevX.hasBox &&
            ((prevXY.hasBox && prevY.hasBox) ||
                (prevXNextY.hasBox && nextY.hasBox)));
  }

  bool surrounded(int x, int y) {
    for (var i = x - 1; i <= x + 1; i++) {
      for (var j = y - 1; j <= y + 1; j++) {
        if (nodes.checkBoundaries(i, j) && !nodes[i][j].wall) {
          return false;
        }
      }
    }

    return true;
  }
}
