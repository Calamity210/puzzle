import 'dart:math';
import 'dart:ui' as ui;

import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

const fractionSize = 80;
const originCircleRadius = 12;
const padding = 70;

double repulsionChangeDistance = 100;

class ParticleCircle {
  ParticleCircle(this.origin, this.originRadius, this.color);

  final Vector2 origin;
  final double originRadius;
  final ui.Color color;

  final rand = Random();
  late final Vector2 position = origin.clone();
  late Vector2 velocity = Vector2(
    rand.nextInt(50).toDouble(),
    rand.nextInt(50).toDouble(),
  );
  late final double repulsion = rand.nextDouble() * 4 + 1;
  late final double originRepulsion = rand.nextDouble() * 0.01 + 0.01;
  late double mouseRepulsion = 1;
  late double gravity = 0.1;
  late double radius = originRadius;

  void updateState(double mouseX, double mouseY) {
    _updateStateByMouse(mouseX, mouseY);
    _updateStateByOrigin();
    // velocity.add(Vector2(0, -0));
    velocity.scale(0.95);
    position.add(velocity);
  }

  void _updateStateByMouse(double mouseX, double mouseY) {
    final dx = mouseX - position.x;
    final dy = mouseY - position.y;
    final distance = sqrt(dx * dx + dy * dy);
    final pointCos = dx / distance;
    final pointSin = dy / distance;

    if (distance < repulsionChangeDistance) {
      gravity *= 0.6;
      mouseRepulsion = max(0, mouseRepulsion * 0.5 - 0.01);
      velocity.sub(Vector2(pointCos * repulsion, pointSin * repulsion));
      velocity.scale(1 - mouseRepulsion);
    } else {
      gravity += (originRepulsion - gravity) * 0.1;
      mouseRepulsion = min(1, mouseRepulsion + 0.03);
    }
  }

  void _updateStateByOrigin() {
    final dx = origin.x - position.x;
    final dy = origin.y - position.y;
    final distance = sqrt(dx * dx + dy * dy);

    velocity.add(Vector2(dx * gravity, dy * gravity));
    radius = originRadius + distance / 16;
  }

  void draw(ui.Canvas c) {
    final paint = ui.Paint()..color = color;

    c.drawCircle(position.toOffset(), radius, paint);
  }
}

class ImageParticles {
  ImageParticles(this.image) {
    createParticles();
  }

  final img.Image image;

  final points = <ParticleCircle>[];

  void createParticles() {
    final rand = Random();
    final imageWidth = image.width.toDouble();
    final imageHeight = image.height.toDouble();

    for (var i = 0; i < fractionSize; i++) {
      for (var j = 0; j < fractionSize; j++) {
        final imagePosition = Vector2(
          i * imageWidth / fractionSize,
          j * imageHeight / fractionSize,
        );

        imagePosition.add(Vector2(rand.nextInt(6) - 3, rand.nextInt(6) - 3));

        final originPosition = imagePosition.copyWith();
        final originRadius = rand.nextInt(originCircleRadius + 6) - 3;
        final originColor = getPixel(imagePosition.x, imagePosition.y);

        if (originColor.alpha == 0) {
          continue;
        }

        originPosition.add(Vector2(padding.toDouble(), padding.toDouble()));

        final point = ParticleCircle(
          originPosition,
          originRadius.toDouble(),
          originColor,
        );
        points.add(point);
      }
    }
  }

  void draw(ui.Canvas canvas, [double? mouseX, double? mouseY]) {
    for (final point in points) {
      if (mouseX != null && mouseY != null) {
        point.updateState(mouseX, mouseY);
      }

      point.draw(canvas);
    }
  }

  ui.Color getPixel(double x, double y) {
    final pixels = image.getBytes();
    final idx = (y.toInt() * image.width + x.toInt()) * 4;

    if (x != x.clamp(0, image.width) || y != y.clamp(0, image.height)) {
      return const ui.Color.fromARGB(0, 0, 0, 0);
    }

    return ui.Color.fromARGB(
      pixels[idx + 3],
      pixels[idx + 0],
      pixels[idx + 1],
      pixels[idx + 2],
    );
  }
}

class ImageParticlesPainter extends CustomPainter {
  ImageParticlesPainter(this.imagePainter, this.mouseX, this.mouseY);

  final ImageParticles imagePainter;
  final double mouseX;
  final double mouseY;

  @override
  void paint(ui.Canvas canvas, ui.Size size) =>
      imagePainter.draw(canvas, mouseX, mouseY);

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
