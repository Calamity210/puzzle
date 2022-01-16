import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

import 'map.dart';
import 'player_sprite_sheet.dart';

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
        radius: width * 1.5,
        blurBorder: width * 1.5,
        color: Colors.transparent,
      ),
    );
    setupCollision(
      CollisionConfig(
        collisions: [
          CollisionArea.rectangle(
            size: Vector2.all(GameMap.tileSize * 0.92),
          ),
        ],
      ),
    );
  }
}
