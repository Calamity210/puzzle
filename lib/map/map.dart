import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:puzzle/game/level.dart';
import 'package:puzzle/items/box.dart';
import 'package:puzzle/pathfinder/node.dart';

class GameMap {
  static double tileSize = 50;

  static List activeSpots = [];
  static List<Node> walls = [];

  static const wall = 'wall/wall.png';
  static const wallMossy = 'wall/wall_mossy.png';
  static const wallCracked1 = 'wall/wall_cracked1.png';
  static const wallCracked2 = 'wall/wall_cracked2.png';
  static const floor1 = 'floor/floor_1.png';
  static const floor2 = 'floor/floor_2.png';
  static const floor3 = 'floor/floor_3.png';
  static const floor4 = 'floor/floor_4.png';
  static const floor5 = 'floor/floor_5.png';
  static const floor6 = 'floor/floor_6.png';
  static const floor7 = 'floor/floor_7.png';
  static const destinationFloor = 'floor/floor_8.png';

  static List<Box> boxes = [];

  static MapWorld map() => MapWorld([
        ..._getFloors(Level.currentLevel),
        ..._getWalls(Level.currentLevel),
        ..._getDestinations(Level.currentLevel)
      ]);

  static void solve() {
    if (boxes.any((b) => !b.data.placed)) {
      final box = boxes.firstWhere((b) => !b.data.placed);
      box.moveToPositionAlongThePath(
        getRelativeTilePosition(box.data.destination.x, box.data.destination.y),
      );
      box.data.placed = true;
      box.setupLighting(null);
    }
  }

  static List<TileModel> _getFloors(Level level) {
    final tileList = <TileModel>[];

    for (var i = 0; i < level.nodes.length; i++) {
      for (var j = 0; j < level.nodes.first.length; j++) {
        if (!level.nodes[i][j].wall) {
          tileList.add(
            TileModel(
              sprite: TileModelSprite(path: randomFloor()),
              x: i.toDouble(),
              y: j.toDouble(),
              width: tileSize,
              height: tileSize,
            ),
          );
        }
      }
    }

    return tileList;
  }

  static List<TileModel> _getWalls(Level level) {
    final tileList = <TileModel>[];

    for (var x = 0; x < level.nodes.length; x++) {
      for (var y = 0; y < level.nodes.first.length; y++) {
        if (level.nodes[x][y].wall && !level.surrounded(x, y)) {
          walls.add(level.nodes[x][y]);
          tileList.add(
            TileModel(
              sprite: TileModelSprite(path: randomWall()),
              x: x.toDouble(),
              y: y.toDouble(),
              collisions: [
                CollisionArea.rectangle(size: Vector2(tileSize, tileSize))
              ],
              width: tileSize,
              height: tileSize,
            ),
          );
        }
      }
    }

    return tileList;
  }

  static List<TileModel> _getDestinations(Level level) {
    final tileList = <TileModel>[];

    for (final destination in level.destinations) {
      tileList.add(
        TileModel(
          sprite: TileModelSprite(path: destinationFloor),
          x: destination.x.toDouble(),
          y: destination.y.toDouble(),
          width: tileSize,
          height: tileSize,
        ),
      );
    }

    return tileList;
  }

  static void getBoxes() =>
      boxes = [for (final data in Level.currentLevel.boxes) Box(data)];

  static String randomFloor() {
    switch (Random().nextInt(11)) {
      case 1:
        return floor2;
      case 2:
      case 3:
        return floor3;
      case 4:
      case 5:
        return floor4;
      case 6:
        return floor5;
      case 7:
      case 8:
        return floor6;
      case 9:
        return floor7;

      default:
        return floor1;
    }
  }

  static String randomWall() {
    switch (Random().nextInt(21)) {
      case 1:
        return wallMossy;
      case 2:
        return wallCracked1;
      case 3:
        return wallCracked2;
      default:
        return wall;
    }
  }

  static Vector2 getRelativeTilePosition(int x, int y) =>
      Vector2(x * tileSize, y * tileSize);
}
