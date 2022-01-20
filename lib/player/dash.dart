import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:puzzle/game/level.dart';
import 'package:puzzle/map/map.dart';
import 'package:puzzle/player/dash_sprite_sheet.dart';

class Dash extends SimplePlayer with Lighting, ObjectCollision {
  Dash(Vector2 position)
      : super(
          animation: PlayerSpriteSheet.simpleDirectionAnimation,
          size: Vector2(GameMap.tileSize * 0.92, GameMap.tileSize),
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
            size: Vector2(GameMap.tileSize * 0.92, GameMap.tileSize * 0.46),
            align: Vector2(0, GameMap.tileSize * 0.46),
          ),
        ],
      ),
    );
  }

  @override
  void joystickAction(JoystickActionEvent event) {
    if (event.id == 1 && event.event == ActionEvent.UP) {
      GameMap.solve();
    }
    super.joystickAction(event);
  }
}
