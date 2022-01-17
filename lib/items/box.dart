import 'package:bonfire/bonfire.dart';
import 'package:puzzle/map/map.dart';
import 'package:puzzle/pathfinder/node.dart';
import 'package:puzzle/player/dash.dart';
import 'package:puzzle/utils/destination.dart';

class Box extends GameDecoration with ObjectCollision, Movement {
  Box(Vector2 position)
      : super.withSprite(
          sprite: Sprite.load('box.png'),
          position: position,
          size: Vector2.all(GameMap.tileSize),
        ) {
    speed = 128;
    setupCollision(
      CollisionConfig(
        collisions: [
          CollisionArea.rectangle(size: Vector2.all(GameMap.tileSize)),
        ],
      ),
    );
  }

  @override
  bool onCollision(GameComponent component, bool active) {
    if (component is Dash && !active) {
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
          return false;
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

  BoxData copy() => BoxData(position, destination, placed);
}
