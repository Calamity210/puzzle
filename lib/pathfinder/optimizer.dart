import 'dart:math';

import 'package:puzzle/game/level.dart';
import 'package:puzzle/pathfinder/generator.dart';
import 'package:puzzle/pathfinder/node.dart';
import 'package:puzzle/pathfinder/pathfinder.dart';

const optPathCost = 4;
const optPlayerCost = 4;

void optimizeLevel(Level level, int iterations) {
  var maxUnnecessary = <Node>[];
  var minDestroyWall = <Node>[];
  var bestPath = 0;
  var steps = 0;

  level.playerPosition = Node(level.playerStartX, level.playerStartY);

  final tempPlayerCost = playerPathCost;
  playerPathCost = optPlayerCost;

  for (var n = 0; n < iterations; n++) {
    final ghostBoxes = copyBoxes(level, true);
    var solveCounter = ghostBoxes.length;
    final destroyWall = <Node>[];
    var unsolvable = false;

    while (solveCounter > 0) {
      final tempCost = pathCost;
      pathCost = Random().nextInt(optPathCost + 2) - 2;

      final boxPaths = calculateBoxPaths(level, ghostBoxes);
      pathCost = tempCost;

      final playerPaths = calculatePlayerPaths(level, ghostBoxes, boxPaths).paths;
      bestPath = Random().nextInt(playerPaths.length);
      final playerPath = playerPaths[bestPath].path;
      final boxPath = boxPaths[bestPath].path;

      for (final path in playerPath) {
        path.used = true;
        if (path.wall) {
          destroyWall.add(path);
        }
      }

      final curBox = ghostBoxes[bestPath];
      var curNode = boxPath.first;
      final diffX = curNode.x - curBox.position.x;
      final diffY = curNode.y - curBox.position.y;

      var stop = 0;
      if (boxPath.length > 1) {
        for (var i = 1; i < boxPath.length; i++) {
          final nextNode = boxPath[i];
          if (diffX == nextNode.x - curNode.x &&
              diffY == nextNode.y - curNode.y) {
            curNode = nextNode;
          } else {
            stop = i - 1;
            break;
          }
        }
      }

      for (var i = 0; i <= stop; i++) {
        boxPath[i].used = true;
        if (boxPath[i].wall) {
          destroyWall.add(boxPath[i]);
        }
      }

      level.nodes[curNode.x][curNode.y].occupied = false;
      curBox.position = boxPath[stop];
      level.nodes[curNode.x][curNode.y].occupied = true;
      level.playerPosition = Node(
        curBox.position.x - diffX,
        curBox.position.y - diffY,
      );

      if (curBox.position.x == curBox.destination.x &&
          curBox.position.y == curBox.destination.y) {
        curBox.placed = true;
        solveCounter--;
        ghostBoxes.removeAt(bestPath);
      }
      steps++;
      if (steps > 5000) {
        unsolvable = true;
        break;
      }
    }

    level.playerPosition = Node(level.playerStartX, level.playerStartY);

    level.nodes[level.playerPosition.x][level.playerPosition.y].used = true;

    final unnecessary = <Node>[];
    for (var i = 0; i < level.nodes.length; i++) {
      for (var j = 0; j < level.nodes[0].length; j++) {
        if (!level.nodes[i][j].wall && !level.nodes[i][j].used) {
          unnecessary.add(level.nodes[i][j]);
        }

        level.nodes[i][j].used = false;
        level.nodes[i][j].occupied = false;
      }
    }

    if (!unsolvable &&
        unnecessary.length - destroyWall.length >
            maxUnnecessary.length - minDestroyWall.length) {
      maxUnnecessary = unnecessary;
      minDestroyWall = destroyWall;
    }
  }

  for (final unnecessary in maxUnnecessary) {
    unnecessary.wall = true;
  }

  for (final wall in minDestroyWall) {
    wall.wall = false;
  }

  playerPathCost = tempPlayerCost;
}
