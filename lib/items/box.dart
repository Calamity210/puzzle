import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:puzzle/game/level.dart';
import 'package:puzzle/map/map.dart';
import 'package:puzzle/pathfinder/node.dart';
import 'package:puzzle/player/dash.dart';
import 'package:puzzle/utils/destination.dart';
import 'package:puzzle/utils/extensions.dart';

class Box extends GameDecoration
    with ObjectCollision, Movement, MoveToPositionAlongThePath, Lighting {
  Box(this.data)
      : super.withSprite(
          sprite: Sprite.load('box.png'),
          position: data.position.vector2 +
              Vector2.all(
                GameMap.tileSize * 0.05,
              ),
          size: Vector2.all(GameMap.tileSize * 0.9),
        ) {
    speed = 128;

    setLighting();

    setupCollision(
      CollisionConfig(
        collisions: [
          CollisionArea.rectangle(size: Vector2.all(GameMap.tileSize * 0.9)),
        ],
      ),
    );
  }

  final BoxData data;

  @override
  set position(Vector2 position) {
    transform.position = position;
    if (Level.currentLevel.destinations.any(checkIfSolved)) {
      setupLighting(null);
      data.placed = true;
      checkForWin();
    } else {
      setLighting();
      data.placed = false;
      data.placedOn?.placed = false;
      data.placedOn = null;
    }
  }

  void setLighting() {
    setupLighting(
      LightingConfig(
        radius: width,
        blurBorder: width,
        withPulse: true,
        pulseVariation: 0.2,
        pulseSpeed: 0.5,
        pulseCurve: Curves.linear,
        color: Colors.orange.withOpacity(0.2),
      ),
    );
  }

  void reset() {
    position = data.position.vector2 +
        Vector2.all(
          GameMap.tileSize * 0.05,
        );
    data.placed = false;
    data.destination.placed = false;
    data.placedOn?.placed = false;
    data.placedOn = null;
    setLighting();
  }

  bool checkIfSolved(Destination d) {
    final x = d.x * GameMap.tileSize;
    final xEnd = x + GameMap.tileSize;
    final y = d.y * GameMap.tileSize;
    final yEnd = y + GameMap.tileSize;
    final boxEnd = position + Vector2.all(GameMap.tileSize * 0.9);

    if (position.x == position.x.clamp(x, xEnd) &&
        position.y == position.y.clamp(y, yEnd) &&
        boxEnd.x == boxEnd.x.clamp(x, xEnd) &&
        boxEnd.y == boxEnd.y.clamp(y, yEnd)) {
      d.placed = true;
      data.placedOn = d;
      return true;
    }

    return false;
  }

  void checkForWin() {
    if (!Level.currentLevel.boxes.any((d) => !d.placed) &&
        !Level.currentLevel.solved) {
      Level.currentLevel.solved = true;
      print('WIN');
    }
  }

  @override
  bool onCollision(GameComponent component, bool active) {
    if (component is Dash) {
      switch (getComponentDirectionFromMe(component)) {
        case Direction.left:
          moveRight(speed);
          break;
        case Direction.right:
          moveLeft(speed);
          break;
        case Direction.up:
          moveDown(speed);
          break;
        case Direction.down:
          moveUp(speed);
          break;
        default:
          break;
      }

      return true;
    }

    return super.onCollision(component, active);
  }
}

class BoxData {
  BoxData(this.position, this.destination, [this.placed = false]);

  Node position;
  final Destination destination;
  bool placed;
  Destination? placedOn;

  BoxData copy() => BoxData(position, destination, placed);
}
