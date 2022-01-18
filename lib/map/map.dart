import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:puzzle/game/level.dart';
import 'package:puzzle/items/box.dart';

class GameMap {
  static double tileSize = 50;

  static List activeSpots = [];

  static const wallBottom = 'wall/wall_bottom.png';
  static const wall = 'wall/wall.png';
  static const wallTop = 'wall/wall_top.png';
  static const wallLeft = 'wall/wall_left.png';
  static const wallBottomLeft = 'wall/wall_bottom_left.png';
  static const wallRight = 'wall/wall_right.png';
  static const floor_1 = 'floor/floor_1.png';
  static const floor_2 = 'floor/floor_2.png';
  static const floor_3 = 'floor/floor_3.png';
  static const floor_4 = 'floor/floor_4.png';
  static const floor_5 = 'floor/floor_5.png';
  static const floor_6 = 'floor/floor_6.png';
  static const floor_7 = 'floor/floor_7.png';

  static MapWorld map() {
    final tileList = <TileModel>[];

    tileList.addAll(_getFloors(Level.currentLevel));
    tileList.addAll(_getWalls(Level.currentLevel));
    // tileList.addAll(_getBoxes(Level.currentLevel!));
    tileList.addAll(_getDestinations(Level.currentLevel));

    return MapWorld(tileList);
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
        } else {
          tileList.add(
            TileModel(
              sprite: TileModelSprite(path: wall),
              x: i.toDouble(),
              y: j.toDouble(),
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

  static List<TileModel> _getWalls(Level level) {
    final tileList = <TileModel>[];

    for (var x = 0; x < level.nodes.length; x++) {
      for (var y = 0; y < level.nodes.first.length; y++) {
        if (level.nodes[x][y].wall && !level.surrounded(x, y)) {
          tileList.add(
            TileModel(
              sprite: TileModelSprite(path: wall),
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

    for (final element in level.destinations) {
      tileList.add(
        TileModel(
          sprite: TileModelSprite(path: 'floor/floor_8.png'),
          x: element.x.toDouble(),
          y: element.y.toDouble(),
          width: tileSize,
          height: tileSize,
        ),
      );
    }

    return tileList;
  }

  static List<GameDecoration> decorations() {
    for (final boxData in Level.currentLevel.boxes)
      print('data::: ${getRelativeTilePosition(
        boxData.position.x,
        boxData.position.y,
      )}');
    return [
      for (final boxData in Level.currentLevel.boxes)
        Box(
          getRelativeTilePosition(
            boxData.position.x,
            boxData.position.y,
          ),
        ),
    ];
  }

  static String randomFloor() {
    switch (Random().nextInt(11)) {
      case 1:
        return floor_2;
      case 2:
      case 3:
        return floor_3;
      case 4:
      case 5:
        return floor_4;
      case 6:
        return floor_5;
      case 7:
      case 8:
        return floor_6;
      case 9:
        return floor_7;

      default:
        return floor_1;
    }
  }

  static Vector2 getRelativeTilePosition(int x, int y) =>
      Vector2(x * tileSize, y * tileSize);
}
