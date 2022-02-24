import 'dart:math';
import 'dart:ui' as ui;

import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:puzzle/utils/extensions.dart';

const fractionSize = 80;

class ParticleCircle {
  ParticleCircle(this.origin, this.originRadius, this.color);

  final Vector2 origin;
  final double originRadius;
  final ui.Color color;

  final rand = Random();
  late final Vector2 position = origin.clone();
  late Vector2 velocity = Vector2(
    rand.nextDouble() * 50,
    rand.nextDouble() * 50,
  );
  late final double repulsion = rand.nextDouble() * 4 + 1;
  late final double originRepulsion = rand.nextDouble() * 0.01 + 0.01;
  late double mouseRepulsion = 1;
  late double gravity = 0.1;
  late double radius = originRadius;

  bool updateState(
    double mouseX,
    double mouseY,
    double repulsionChangeDistance,
  ) {
    final oldPosition = position.clone();
    _updateStateByMouse(mouseX, mouseY, repulsionChangeDistance);
    _updateStateByOrigin();
    velocity.scale(0.95);
    position.add(velocity);
    return oldPosition != position;
  }

  void _updateStateByMouse(
    double mouseX,
    double mouseY,
    double repulsionChangeDistance,
  ) {
    final dx = mouseX - position.x;
    final dy = mouseY - position.y;
    final distance = sqrt(dx * dx + dy * dy);
    final pointCos = dx / distance;
    final pointSin = dy / distance;

    if (distance < repulsionChangeDistance) {
      gravity *= 0.6;
      mouseRepulsion = max(0, mouseRepulsion * 0.5 - 0.01);
      velocity.subNum(pointCos * repulsion, pointSin * repulsion);
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

    velocity.addNum(dx * gravity, dy * gravity);
    radius = originRadius + distance / 16;
  }

  void draw(ui.Canvas c) {
    c.drawCircle(position.toOffset(), radius, ui.Paint()..color = color);
  }
}

class ImageParticles {
  ImageParticles(this.image, int originCircleRadius) {
    createParticles(originCircleRadius);
  }

  final img.Image image;

  final points = <ParticleCircle>[];

  void createParticles(int originCircleRadius) {
    final rand = Random();
    final imageWidth = image.width.toDouble();
    final imageHeight = image.height.toDouble();

    final fracWidth = imageWidth / fractionSize;
    final fracHeight = imageHeight / fractionSize;

    for (var i = 0; i < fractionSize; i++) {
      for (var j = 0; j < fractionSize; j++) {
        final imagePosition = Vector2(i * fracWidth, j * fracHeight);

        imagePosition.addNum(rand.nextInt(6) - 3, rand.nextInt(6) - 3);

        final originPosition = imagePosition.clone();
        final originRadius = rand.nextInt(originCircleRadius + 6) - 3;
        final originColor = getPixel(imagePosition.x, imagePosition.y);

        if (originColor.alpha == 0) {
          continue;
        }

        points.add(
          ParticleCircle(originPosition, originRadius.toDouble(), originColor),
        );
      }
    }
  }

  void draw(
    ui.Canvas canvas, [
    double? mouseX,
    double? mouseY,
    double repulsionChangeDistance = 150,
  ]) {
    for (final point in points) {
      var redraw = false;
      if (mouseX != null && mouseY != null) {
        redraw = point.updateState(mouseX, mouseY, repulsionChangeDistance);
      }

      if (redraw) {
        point.draw(canvas);
      }
    }
  }

  ui.Color getPixel(num x, num y) {
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
  ImageParticlesPainter(
    this.imagePainter,
    this.mouseX,
    this.mouseY,
    this.repulsionChangeDistance,
  );

  final ImageParticles imagePainter;
  final double mouseX;
  final double mouseY;
  final double repulsionChangeDistance;

  @override
  void paint(ui.Canvas canvas, ui.Size size) =>
      imagePainter.draw(canvas, mouseX, mouseY, repulsionChangeDistance);

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(covariant CustomPainter oldDelegate) => false;
}
