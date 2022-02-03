import 'package:puzzle/game/level.dart';
import 'package:puzzle/items/box.dart';
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
      boxPath[i].wall = false;
    }

    level.nodes[curBox.position.x][curBox.position.y].occupied = false;
    curBox.position = boxPath[stop];
    level.nodes[curBox.position.x][curBox.position.y].occupied = true;
    level.playerPosition = Node(
      curBox.position.x - diffX,
      curBox.position.y - diffY,
    );

    if (curBox.position.x == curBox.destination.x &&
        curBox.position.y == curBox.destination.y) {
      curBox.placed = true;
      level.solvedCount--;
      ghostBoxes.removeAt(bestPath);
    }
    steps++;
    if (steps > 2000) {
      level.unsolvable = true;
      break;
    }
  }

  level.playerPosition = Node(level.playerStartX, level.playerStartY);
}

List<BoxData> copyBoxes(Level level, bool used) {
  final newBoxes = <BoxData>[];

  for (final box in level.boxes) {
    newBoxes.add(box.copy());
    level.nodes[box.position.x][box.position.y].occupied = true;
    level.nodes[box.position.x][box.position.y].used = used;
  }

  return newBoxes;
}

List<Path> calculateBoxPaths(Level level, List<BoxData> ghostBoxes) {
  final boxPaths = <Path>[];

  for (final box in ghostBoxes) {
    level.nodes[box.position.x][box.position.y].occupied = false;
    final solver = Pathfinder(
      level,
      box.position.x,
      box.position.y,
      box.destination.x,
      box.destination.y,
    );

    boxPaths.add(solver.findPath(true));
    level.nodes[box.position.x][box.position.y].occupied = true;
  }

  return boxPaths;
}

Paths calculatePlayerPaths(
  Level level,
  List<BoxData> ghostBoxes,
  List<Path> boxPaths,
) {
  final playerPaths = <Path>[];
  var bestPath = -1;
  var lowestCost = 100000000;

  for (var i = 0; i < ghostBoxes.length; i++) {
    var newX = ghostBoxes[i].position.x;
    var newY = ghostBoxes[i].position.y;

    if (boxPaths[i].path.first.x == newX + 1) {
      newX -= 1;
    } else if (boxPaths[i].path.first.x == newX - 1) {
      newX += 1;
    } else if (boxPaths[i].path.first.y == newY + 1) {
      newY -= 1;
    } else {
      newY += 1;
    }

    final solver = Pathfinder(
      level,
      level.playerPosition.x,
      level.playerPosition.y,
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
