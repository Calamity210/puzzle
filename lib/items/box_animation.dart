import 'dart:async';
import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/assets_loader.dart';

enum BoxAnimationEnum {
  inactive,
  active,
  transition,
}

class BoxAnimation {
  BoxAnimation({
    required FutureOr<SpriteAnimation> inactive,
    required FutureOr<SpriteAnimation> active,
    required FutureOr<SpriteAnimation> transition,
    BoxAnimationEnum initAnimation = BoxAnimationEnum.inactive,
  }) {
    _currentType = initAnimation;
    _loader?.add(AssetToLoad(inactive, (value) => this.inactive = value));
    _loader?.add(AssetToLoad(active, (value) => this.active = value));
    _loader?.add(AssetToLoad(transition, (value) => this.transition = value));
  }

  SpriteAnimation? inactive;
  SpriteAnimation? active;
  SpriteAnimation? transition;

  AssetsLoader? _loader = AssetsLoader();

  SpriteAnimation? _current;
  late BoxAnimationEnum _currentType;
  AnimatedObjectOnce? _fastAnimation;
  Vector2 position = Vector2.zero();
  Vector2 size = Vector2.zero();

  bool runToTheEndFastAnimation = false;

  double opacity = 1.0;

  SpriteAnimation play(BoxAnimationEnum animation, [bool reverse = false]) {
    _currentType = animation;
    if (!runToTheEndFastAnimation) {
      _fastAnimation = null;
    }
    switch (animation) {
      case BoxAnimationEnum.inactive:
        if (inactive != null) {
          _current = inactive;
        }
        break;
      case BoxAnimationEnum.active:
        if (active != null) {
          _current = active;
        }
        break;
      case BoxAnimationEnum.transition:
        if (transition != null) {
          _current = reverse ? transition!.reversed() : transition;
        }
        break;
    }
    return _current!;
  }

  Future playOnce(
    FutureOr<SpriteAnimation> animation, {
    VoidCallback? onFinish,
    bool runToTheEnd = false,
  }) async {
    runToTheEndFastAnimation = runToTheEnd;
    final anim = AnimatedObjectOnce(
      position: position,
      size: size,
      animation: animation,
      onFinish: () {
        onFinish?.call();
        _fastAnimation = null;
      },
    );
    await anim.onLoad();
    _fastAnimation = anim;
  }

  void render(Canvas canvas) {
    if (_fastAnimation != null) {
      _fastAnimation?.render(canvas);
    } else {
      _current?.getSprite().renderWithOpacity(
            canvas,
            position,
            size,
            opacity: opacity,
          );
    }
  }

  void update(double dt, Vector2 position, Vector2 size) {
    _fastAnimation?.opacity = opacity;
    _fastAnimation?.position = position;
    _fastAnimation?.size = size;
    _fastAnimation?.update(dt);

    this.position = position;
    this.size = size;
    _current?.update(dt);
  }

  Future<void> onLoad() async {
    await _loader?.load();
    _loader = null;
  }

  BoxAnimationEnum? get currentType => _currentType;
}
