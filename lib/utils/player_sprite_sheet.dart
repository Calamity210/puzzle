import 'package:bonfire/bonfire.dart';

class PlayerSpriteSheet {

  static Future<SpriteAnimation> get idle => SpriteAnimation.load(
    'dash/dash_idle.png',
    SpriteAnimationData.sequenced(
      amount: 1,
      stepTime: 0.1,
      textureSize: Vector2(24, 26),
    ),
  );

  static Future<SpriteAnimation> get runRight => SpriteAnimation.load(
    'dash/dash_run_right.png',
    SpriteAnimationData.sequenced(
      amount: 3,
      stepTime: 0.1,
      textureSize: Vector2(24, 26),
    ),
  );

  static Future<SpriteAnimation> get runDown => SpriteAnimation.load(
    'dash/dash_run_down.png',
    SpriteAnimationData.sequenced(
      amount: 3,
      stepTime: 0.1,
      textureSize: Vector2(24, 26),
    ),
  );

  static Future<SpriteAnimation> get runLeft => SpriteAnimation.load(
    'dash/dash_run_left.png',
    SpriteAnimationData.sequenced(
      amount: 3,
      stepTime: 0.1,
      textureSize: Vector2(24, 26),
    ),
  );

  static Future<SpriteAnimation> get jump => SpriteAnimation.load(
    'dash/dash_jump.png',
    SpriteAnimationData.sequenced(
      amount: 2,
      stepTime: 0.1,
      textureSize: Vector2(24, 26),
    ),
  );

  static SimpleDirectionAnimation get simpleDirectionAnimation =>
      SimpleDirectionAnimation(
        idleRight: idle,
        runRight: runRight,
        runDown: runDown,
        runUp: runDown,
      );
}