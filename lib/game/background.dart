import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:puzzle/particles/particle_circles.dart';

class Background extends GameBackground {
  Background({
    required this.color,
    required this.image,
  });

  final Color color;
  final img.Image image;

  late ImageParticles ip = ImageParticles(image);

  bool rendered = false;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawColor(
      color,
      BlendMode.src,
    );

    ip.draw(canvas);
  }
}
