import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:puzzle/map/map.dart';

class Portrait extends GameDecoration with Lighting {
  Portrait(String sprite, Vector2 position)
      : super.withSprite(
          sprite: Sprite.load(sprite),
          position: position + Vector2(GameMap.tileSize * 0.05, GameMap.tileSize * 0.125),
          size: Vector2(GameMap.tileSize * 0.9, GameMap.tileSize * 0.75),
        ) {
    setupLighting(
      LightingConfig(
        radius: width * 1.5,
        blurBorder: width,
        color: Colors.transparent,
      ),
    );
  }
}
