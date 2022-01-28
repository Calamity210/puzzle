import 'package:bonfire/bonfire.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:puzzle/game/game.dart';
import 'package:puzzle/map/map.dart';
import 'package:puzzle/player/dash_sprite_sheet.dart';

class Dash extends SimplePlayer with Lighting, ObjectCollision {
  Dash(Vector2 position, double tileSize)
      : super(
          animation: PlayerSpriteSheet.simpleDirectionAnimation,
          size: Vector2(tileSize * 0.92, tileSize),
          position: position,
          life: 200,
          speed: 128,
        ) {
    setupLighting(
      LightingConfig(
        radius: width,
        blurBorder: width,
        color: Colors.transparent,
      ),
    );
    setupCollision(
      CollisionConfig(
        collisions: [
          CollisionArea.rectangle(
            size: Vector2(tileSize * 0.92, tileSize * 0.46),
            align: Vector2(0, tileSize * 0.46),
          ),
        ],
      ),
    );
  }

  @override
  void joystickChangeDirectional(JoystickDirectionalEvent event) {
    super.joystickChangeDirectional(event);
  }

  @override
  void joystickAction(JoystickActionEvent event) {
    final game = Provider.of<Game>(gameRef.context, listen: false);

    switch (event.id) {
      case 'help':
        if (event.event == ActionEvent.UP) {
          game.map.solve(gameRef);
        }
        break;
      case 'restart':
        if (event.event == ActionEvent.UP) {
          FlameAudio.audioCache.play('sfx/restart.wav');
          position = GameMap.getRelativeTilePosition(
            game.map.tileSize,
            game.level.playerStartX,
            game.level.playerStartY,
          );

          for (final box in game.map.boxes) {
            box.reset();
          }
        }
        break;
    }
    super.joystickAction(event);
  }
}
