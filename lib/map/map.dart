import 'dart:math';

import 'package:bonfire/base/bonfire_game_interface.dart';
import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:puzzle/game/level.dart';
import 'package:puzzle/items/box.dart';
import 'package:puzzle/pathfinder/node.dart';
import 'package:puzzle/utils/extensions.dart';

class GameMap {
  GameMap({required this.level, this.tileSize = 50}) {
    boxes = [for (final data in level.boxes) Box(data, level, tileSize)];
  }

  final Level level;
  final double tileSize;

  List<Box> boxes = [];
  List<Node> walls = [];

  final rand = Random();

  final wall = 'wall/wall.png';
  final topWall = 'wall/wall0.png';
  final leftWall = 'wall/wall1.png';
  final bottomWall = 'wall/wall2.png';
  final rightWall = 'wall/wall3.png';
  final topLeftWall = 'wall/wall4.png';
  final bottomLeftWall = 'wall/wall5.png';
  final bottomRightWall = 'wall/wall6.png';
  final topRightWall = 'wall/wall7.png';
  final floor0 = 'floor/floor0.png';
  final floor1 = 'floor/floor1.png';
  final floor2 = 'floor/floor2.png';
  final floor3 = 'floor/floor3.png';
  final floor4 = 'floor/floor4.png';
  final floor5 = 'floor/floor5.png';
  final floor6 = 'floor/floor6.png';
  final destinationFloor = 'floor/destination.png';

  MapWorld get map => MapWorld([
        ..._getFloors(),
        ..._getWalls(),
        ..._getDestinations(),
      ]);

  void solve(BonfireGameInterface gameRef) {
    if (boxes.any((b) => !b.data.placed)) {
      final reversedBoxes = boxes.reversed;
      final unsolvedBoxes = reversedBoxes.where((b) => !b.data.placed);
      final solvedBoxes = reversedBoxes.where((b) => b.data.placed);
      for (final box in unsolvedBoxes) {
        final destination = box.data.destination;
        if (destination.placed) {
          final newBox =
              solvedBoxes.firstWhere((b) => b.data.placedOn == destination);
          newBox.moveToPositionAlongThePath(
            newBox.data.position.vector2(tileSize),
          );
          break;
        }
        box.messageShown = false;
        box.moveToPositionAlongThePath(
          GameMap.getRelativeTilePosition(
            tileSize,
            destination.x,
            destination.y,
          ),
        );

        if (!box.isMovingAlongThePath) {
          if (box != unsolvedBoxes.last) {
            continue;
          }

          TalkDialog.show(
            gameRef.context,
            [
              Say(
                text: [
                  const TextSpan(
                    text:
                        "Hmm... the box can't seem to reach the destination point",
                  ),
                ],
              ),
              Say(
                text: [
                  const TextSpan(
                    text: 'Can you see the box? Are we blocking the way?',
                  ),
                ],
              ),
            ],
            dismissible: true,
          );
        }
        break;
      }
    }
  }

  List<TileModel> _getFloors() {
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

  List<TileModel> _getWalls() {
    final tileList = <TileModel>[];

    for (var x = 0; x < level.nodes.length; x++) {
      for (var y = 0; y < level.nodes.first.length; y++) {
        if (level.nodes[x][y].wall && !level.surrounded(x, y)) {
          var wall = getWall(x, y);
          if (rand.nextInt(10) == 0 && wall != this.wall) {
            final numberIndex = wall.indexOf('.') - 1;
            final number = wall[numberIndex];
            wall = wall.replaceRange(
              numberIndex,
              wall.length,
              '_cracked$number.png',
            );
          }
          walls.add(level.nodes[x][y]);
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

  List<TileModel> _getDestinations() {
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

  String randomFloor() {
    switch (rand.nextInt(12)) {
      case 0:
        return floor1;
      case 1:
      case 2:
        return floor2;
      case 3:
        return floor3;
      case 4:
        return floor4;
      case 5:
      case 6:
        return floor5;
      case 7:
        return floor6;
      default:
        return floor0;
    }
  }

  bool isWall(int x, int y) =>
      level.nodes[x][y].wall &&!level.surrounded(x, y);

  String getWall(int x, int y) {
    if (x > 0 &&
        x < level.nodes.length - 1 &&
        y > 0 &&
        y < level.nodes.first.length - 1) {
      final behindWall = isWall(x - 1, y);
      final frontWall = isWall(x + 1, y);
      final aboveWall = isWall(x, y - 1);
      final belowWall = isWall(x, y + 1);

      if (belowWall) {
        if (behindWall) {
          return bottomLeftWall;
        }

        if (frontWall) {
          return bottomRightWall;
        }
      }

      if (aboveWall) {
        if (behindWall) {
          return topLeftWall;
        }

        if (frontWall) {
          return topRightWall;
        }
      }

      if ((aboveWall || belowWall) && (behindWall || frontWall)) {
        return wall;
      }

      if (!aboveWall && !belowWall) {
        if (y < level.nodes.first.length / 2) {
          return topWall;
        }
        return bottomWall;
      }

      if (!behindWall) {
        if (x < level.nodes.length / 2) {
          return leftWall;
        }
        return rightWall;
      }

      if (!frontWall) {
        if (x > level.nodes.length / 2) {
          return rightWall;
        }
        return leftWall;
      }
    } else if (x == 0) {
      if (!isWall(x + 1, y)) {
        return leftWall;
      }
    } else if (x == level.nodes.first.length - 1) {
      if (!isWall(x - 1, y)) {
        return rightWall;
      }
    } else if (y == 0) {
      if (!isWall(x, y + 1)) {
        return topWall;
      }
    } else if (y == level.nodes.length - 1) {
      if (!isWall(x, y - 1)) {
        return bottomWall;
      }
    }

    return wall;
  }

  static Vector2 getRelativeTilePosition(double tileSize, int x, int y) =>
      Vector2(x * tileSize, y * tileSize);
}
