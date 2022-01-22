import 'dart:math';

import 'package:bonfire/base/bonfire_game_interface.dart';
import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:puzzle/game/level.dart';
import 'package:puzzle/items/box.dart';
import 'package:puzzle/pathfinder/node.dart';

class GameMap {
  GameMap({required this.level, this.tileSize = 50}) {
    boxes = [
      for (final data in level.boxes) Box(data, level, tileSize),
    ];
  }

  final Level level;
  final double tileSize;

  List<Node> walls = [];

  final wall = 'wall/wall.png';
  final wallMossy = 'wall/wall_mossy.png';
  final wallCracked1 = 'wall/wall_cracked1.png';
  final wallCracked2 = 'wall/wall_cracked2.png';
  final floor0 = 'floor/floor0.png';
  final floor1 = 'floor/floor1.png';
  final floor2 = 'floor/floor2.png';
  final floor3 = 'floor/floor3.png';
  final floor4 = 'floor/floor4.png';
  final floor5 = 'floor/floor5.png';
  final floor6 = 'floor/floor6.png';
  final destinationFloor = 'floor/destination.png';

  List<Box> boxes = [];

  MapWorld get map => MapWorld([
        ..._getFloors(),
        ..._getWalls(),
        ..._getDestinations(),
      ]);

  void solve(BonfireGameInterface gameRef) {
    if (boxes.any((b) => !b.data.placed)) {
      final unsolvedBoxes = boxes.where((b) => !b.data.placed);
      for (final box in unsolvedBoxes) {
        final destination = box.data.destination;
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
    switch (Random().nextInt(12)) {
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

  String randomWall() {
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

  static Vector2 getRelativeTilePosition(double tileSize, int x, int y) =>
      Vector2(x * tileSize, y * tileSize);
}
