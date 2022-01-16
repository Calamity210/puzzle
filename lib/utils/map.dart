import 'dart:math';

import 'package:bonfire/bonfire.dart';

class GameMap {
  static double tileSize = 50;
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

  static MapWorld map() {
    final tileList = <TileModel>[];
    List.generate(35, (row) {
      List.generate(70, (col) {
        if (row == 3 && col > 2 && col < 30) {
          tileList.add(
            TileModel(
              sprite: TileModelSprite(path: wallBottom),
              x: col.toDouble(),
              y: row.toDouble(),
              collisions: [
                CollisionArea.rectangle(size: Vector2(tileSize, tileSize))
              ],
              width: tileSize,
              height: tileSize,
            ),
          );
          return;
        }
        if (row == 4 && col > 2 && col < 30) {
          tileList.add(
            TileModel(
              sprite: TileModelSprite(path: wall),
              x: col.toDouble(),
              y: row.toDouble(),
              collisions: [
                CollisionArea.rectangle(size: Vector2(tileSize, tileSize))
              ],
              width: tileSize,
              height: tileSize,
            ),
          );
          return;
        }

        if (row == 9 && col > 2 && col < 30) {
          tileList.add(
            TileModel(
              sprite: TileModelSprite(path: wallTop),
              x: col.toDouble(),
              y: row.toDouble(),
              collisions: [
                CollisionArea.rectangle(size: Vector2(tileSize, tileSize))
              ],
              width: tileSize,
              height: tileSize,
            ),
          );
          return;
        }

        if (row > 4 && row < 9 && col > 2 && col < 30) {
          tileList.add(
            TileModel(
              sprite: TileModelSprite(path: randomFloor()),
              x: col.toDouble(),
              y: row.toDouble(),
              width: tileSize,
              height: tileSize,
            ),
          );
          return;
        }

        if (row > 3 && row < 9 && col == 2) {
          tileList.add(
            TileModel(
              sprite: TileModelSprite(path: wallLeft),
              x: col.toDouble(),
              y: row.toDouble(),
              collisions: [
                CollisionArea.rectangle(size: Vector2(tileSize, tileSize))
              ],
              width: tileSize,
              height: tileSize,
            ),
          );
        }
        if (row == 9 && col == 2) {
          tileList.add(
            TileModel(
              sprite: TileModelSprite(path: wallBottomLeft),
              x: col.toDouble(),
              y: row.toDouble(),
              collisions: [
                CollisionArea.rectangle(size: Vector2(tileSize, tileSize))
              ],
              width: tileSize,
              height: tileSize,
            ),
          );
        }

        if (row > 3 && row < 9 && col == 30) {
          tileList.add(
            TileModel(
              sprite: TileModelSprite(path: wallRight),
              x: col.toDouble(),
              y: row.toDouble(),
              collisions: [
                CollisionArea.rectangle(size: Vector2(tileSize, tileSize))
              ],
              width: tileSize,
              height: tileSize,
            ),
          );
        }
      });
    });

    return MapWorld(tileList);
  }

  static List<GameDecoration> decorations() {
    final rand = Random();
    return [
      for (int i = 0; i < 10; i++)
      GameDecorationWithCollision.withSprite(
        sprite: Sprite.load('box.png'),
        position: getRelativeTilePosition(rand.nextInt(27) + 3, rand.nextInt(4) + 5),
        size: Vector2(tileSize, tileSize),
        collisions: [
          CollisionArea.rectangle(size: Vector2(tileSize, tileSize))
        ],
      ),
    ];
  }

  static String randomFloor() {
    switch (Random().nextInt(6)) {
      case 1:
        return floor_2;
      case 2:
      case 4:
        return floor_3;
      case 3:
      case 5:
        return floor_4;
      default:
        return floor_1;
    }
  }

  static Vector2 getRelativeTilePosition(int x, int y) =>
      Vector2(x * tileSize, y * tileSize);
}
