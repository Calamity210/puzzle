import 'dart:math';
import 'dart:ui' as ui;

import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:puzzle/game/game_page.dart';

const fractionSize = 50;
const originCircleRadius = 12;
const padding = 70;

double repulsionChangeDistance = 100;
ImageParticles? pointSystem;
Image? targetImage;

class ParticleCircle {
  ParticleCircle(this.position, this.originRadius, this.color);

  final Vector2 position;
  final double originRadius;
  final ui.Color color;

  final rand = Random();
  late final Vector2 origin = position;
  late final Vector2 velocity = Vector2(
    rand.nextDouble() * 50,
    rand.nextDouble() * 50,
  );
  late final double repulsion = rand.nextDouble() * 4 + 1;
  late final double originRepulsion = rand.nextDouble() * 0.01 + 0.01;
  late final double mouseRepulsion = 1;
  late double gravity = 0.6;
  late double radius = originRadius;

  void updateState() {
    _updateStateByOrigin();
  }

  void _updateStateByOrigin() {
    final dx = position.x - origin.x;
    final dy = position.y - origin.y;
    final distance = position.distanceTo(origin);

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

  void updateState() {
    for (final point in points) {
      point.updateState();
    }
  }

  void draw(ui.Canvas canvas) {
    for (final point in points) {
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
