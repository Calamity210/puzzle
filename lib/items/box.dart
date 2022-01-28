import 'package:bonfire/bonfire.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:puzzle/game/level.dart';
import 'package:puzzle/items/box_animation.dart';
import 'package:puzzle/items/box_sprite_sheet.dart';
import 'package:puzzle/pathfinder/node.dart';
import 'package:puzzle/player/dash.dart';
import 'package:puzzle/utils/destination.dart';
import 'package:puzzle/utils/extensions.dart';

class Box extends GameDecoration
    with ObjectCollision, Movement, MoveToPositionAlongThePath, Lighting {
  Box(this.data, this.level, this.tileSize)
      : super(
          position:
              data.position.vector2(tileSize) + Vector2.all(tileSize * 0.05),
          size: Vector2.all(tileSize * 0.9),
        ) {
    speed = 128;

    setLighting();
    setupCollision(
      CollisionConfig(
        collisions: [
          CollisionArea.rectangle(size: Vector2.all(tileSize * 0.9)),
        ],
      ),
    );
  }

  late final BoxAnimation _boxAnimation = BoxSpriteSheet.boxAnimation;
  final Level level;
  final double tileSize;
  final BoxData data;
  bool messageShown = false;

  @override
  void render(Canvas c) {
    super.render(c);
    _boxAnimation.render(c);
  }

  @override
  void update(double dt) {
    if (isVisible) {
      _boxAnimation.opacity = opacity;
      _boxAnimation.update(dt, position, size);
    }
    super.update(dt);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _boxAnimation.onLoad();
    _boxAnimation.play(BoxAnimationEnum.inactive);
  }

  @override
  set position(Vector2 position) {
    transform.position = position;

    if (level.destinations.any(checkIfSolved)) {
      if (!data.placed) {
        _boxAnimation.play(BoxAnimationEnum.transition);
        FlameAudio.audioCache.play('sfx/click.mp3');
        setLighting(0.4);
        data.placed = true;
        checkForWin();
      }
    } else {
      if (data.placed) {
        _boxAnimation.play(BoxAnimationEnum.transition, true);
      }
      setLighting();
      data.placed = false;
      data.placedOn?.placed = false;
      data.placedOn = null;
    }
  }

  void setLighting([double opacity = 0.2]) {
    setupLighting(
      LightingConfig(
        radius: width,
        blurBorder: width,
        withPulse: true,
        pulseVariation: 0.2,
        pulseSpeed: 0.5,
        pulseCurve: Curves.linear,
        color: const Color(0xFFC9F6F8).withOpacity(opacity),
      ),
    );
  }

  void reset() {
    position = data.position.vector2(tileSize) + Vector2.all(tileSize * 0.05);
    data.placed = false;
    data.destination.placed = false;
    data.placedOn?.placed = false;
    data.placedOn = null;
    setLighting();
  }

  bool checkIfSolved(Destination d) {
    final x = d.x * tileSize;
    final xEnd = x + tileSize;
    final y = d.y * tileSize;
    final yEnd = y + tileSize;
    final boxEnd = position + Vector2.all(tileSize * 0.9);

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
    if (!level.boxes.any((d) => !d.placed) && !level.solved) {
      level.solved = true;
      FlameAudio.audioCache.play('sfx/win.wav');
      Navigator.of(gameRef.context).pop();
    }
  }

  @override
  bool onCollision(GameComponent component, bool active) {
    if (active && isMovingAlongThePath && !messageShown) {
      messageShown = true;
      TalkDialog.show(
        gameRef.context,
        [
          Say(
            text: [
              const TextSpan(
                text: "The box can't seem to reach the destination point",
              ),
            ],
          ),
          Say(
            text: [
              const TextSpan(
                text: 'Is anything blocking the way?',
              ),
            ],
          ),
        ],
        dismissible: true,
      );
    } else if (component is Dash) {
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
