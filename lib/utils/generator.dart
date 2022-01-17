import 'package:bonfire/bonfire.dart';
import 'package:puzzle/game/level.dart';
import 'package:puzzle/items/box.dart';
import 'package:puzzle/map/map.dart';
import 'package:puzzle/pathfinder/node.dart';
import 'package:puzzle/pathfinder/path.dart';
import 'package:puzzle/pathfinder/pathfinder.dart';

void generatePaths(Level level) {
  var steps = 0;
  final ghostBoxes = copyBoxes(level, false);

  while (level.solvedCount > 0) {
    final boxPaths = calculateBoxPaths(level, ghostBoxes);
    final playerPaths = calculatePlayerPaths(level, ghostBoxes, boxPaths);
    final bestPath = playerPaths.bestPath;
    final playerPath = playerPaths.paths[bestPath].path;
    final boxPath = boxPaths[bestPath].path;

    for (final path in playerPath) {
      path.wall = false;
      if (path.occupied) {
        level.unsolvable = true;
      }
    }

    final curBox = ghostBoxes[bestPath];
    var curNode = boxPath.first;
    final diffX = (curNode.x - curBox.x).toInt();
    final diffY = (curNode.y - curBox.y).toInt();
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

    for (final path in boxPath) {
      path.wall = false;
    }

    level.nodes[curBox.x.toInt()][curBox.y.toInt()].occupied = false;
    curBox.position = Vector2(
      boxPath[stop].x.toDouble(),
      boxPath[stop].y.toDouble(),
    );
    level.nodes[curBox.x.toInt()][curBox.y.toInt()].occupied = true;
    level.setPlayerPos(
      Node(curBox.x.toInt() - diffX, curBox.y.toInt() - diffY),
    );
    
    if (curBox.x == curBox.destination.x && curBox.y == curBox.destination.y) {
      curBox.placed = true;
      level.solvedCount--;
      ghostBoxes.removeAt(bestPath);
    }
    steps++;
    if (steps > 4000) {
      level.unsolvable = true;
      break;
    }
  }

  level.setPlayerPos(Node(level.playerStartX, level.playerStartY));
  GameMap.px = level.player.x.toInt();
  GameMap.py = level.player.y.toInt();
}

List<Box> copyBoxes(Level level, bool used) {
  final newBoxes = <Box>[];

  for (final box in level.boxes) {
    newBoxes.add(box);
    level.nodes[box.x.toInt()][box.y.toInt()].occupied = true;
    level.nodes[box.x.toInt()][box.y.toInt()].used = used;
  }

  return newBoxes;
}

List<Path> calculateBoxPaths(Level level, List<Box> ghostBoxes) {
  final boxPaths = <Path>[];

  for (final box in ghostBoxes) {
    level.nodes[box.x.toInt()][box.y.toInt()].occupied = false;
    final solver = Pathfinder(
      level,
      box.x.toInt(),
      box.y.toInt(),
      box.destination.x,
      box.destination.y,
    );

    boxPaths.add(solver.findPath(true));
    level.nodes[box.x.toInt()][box.y.toInt()].occupied = true;
  }

  return boxPaths;
}

Paths calculatePlayerPaths(
  Level level,
  List<Box> ghostBoxes,
  List<Path> boxPaths,
) {
  final playerPaths = <Path>[];
  var bestPath = -1;
  var lowestCost = 100000000;

  for (var i = 0; i < ghostBoxes.length; i++) {
    var newX = ghostBoxes[i].x.toInt();
    var newY = ghostBoxes[i].y.toInt();

    if (boxPaths[i].path.first.x == newX + 1) {
      newX -= 1;
    } else if (boxPaths[i].path.first.x == newX - 1) {
      newX += 1;
    } else {
      newY += 1;
    }

    final solver = Pathfinder(
      level,
      level.player.x.toInt(),
      level.player.y.toInt(),
      newX,
      newY,
    );
    playerPaths.add(solver.findPath(false));
    if (playerPaths[i].cost < lowestCost) {
      lowestCost = playerPaths[i].cost;
      bestPath = i;
    }
  }

  return Paths(playerPaths, bestPath);
}
