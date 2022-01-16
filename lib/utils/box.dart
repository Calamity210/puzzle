import 'package:bonfire/bonfire.dart';

class Box extends SimpleEnemy with ObjectCollision {
  Box(Vector2 position)
      : super(
    animation: SimpleDirectionAnimation(
      idleRight: SpriteAnimation.load(
        "box.png",
        SpriteAnimationData.sequenced(
          amount: 1,
          stepTime: 0.1,
          textureSize: Vector2.all(32),
        ),
      ),
      runRight: SpriteAnimation.load(
        "box.png",
        SpriteAnimationData.sequenced(
          amount: 1,
          stepTime: 0.1,
          textureSize: Vector2.all(32),
        ),
      ),
    ),
    position: position,
    size: Vector2.all(32),
    life: 100,
  ) {
    setupCollision(
      CollisionConfig(
        collisions: [
          CollisionArea.rectangle(size: Vector2.all(32)),
        ],
      ),
    );
  }

  @override
  void update(double dt) {
    seeAndMoveToPlayer(
      closePlayer: (player) {
        /// do anything when close to player
      },
      radiusVision: 64,
    );
    super.update(dt);
  }
}