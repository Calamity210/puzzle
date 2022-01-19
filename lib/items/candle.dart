import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:puzzle/map/map.dart';

class Candle extends GameDecoration with Lighting {
  Candle(Vector2 position)
      : super.withAnimation(
          animation: SpriteAnimation.load(
            'candle.png',
            SpriteAnimationData.sequenced(
              amount: 5,
              stepTime: 0.1,
              textureSize: Vector2(19, 26),
            ),
          ),
          position: position +
              Vector2(GameMap.tileSize * 0.225, GameMap.tileSize * 0.125),
          size: Vector2(GameMap.tileSize * 0.55, GameMap.tileSize * 0.75),
        ) {
    setupLighting(
      LightingConfig(
        radius: width * 1.5,
        blurBorder: width * 1.5,
        withPulse: true,
        pulseVariation: 0.3,
        pulseSpeed: 0.5,
        color: Colors.deepOrange.withOpacity(0.5),
      ),
    );
  }
}
