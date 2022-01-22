import 'package:bonfire/bonfire.dart';
import 'package:puzzle/items/box_animation.dart';

class BoxSpriteSheet {
  static Future<SpriteAnimation> get inactive => SpriteAnimation.load(
        'items/box.png',
        SpriteAnimationData.sequenced(
          amount: 1,
          stepTime: 0.1,
          textureSize: Vector2(32, 32),
        ),
      );

  static Future<SpriteAnimation> get active => SpriteAnimation.load(
        'items/box_activated.png',
        SpriteAnimationData.sequenced(
          amount: 1,
          stepTime: 0.1,
          textureSize: Vector2(32, 32),
        ),
      );

  static Future<SpriteAnimation> get transition => SpriteAnimation.load(
        'items/box_animation.png',
        SpriteAnimationData.sequenced(
          amount: 20,
          stepTime: 0.02,
          textureSize: Vector2(32, 32),
          loop: false,
        ),
      );

  static BoxAnimation get boxAnimation => BoxAnimation(
        inactive: inactive,
        active: active,
        transition: transition,
      );
}
