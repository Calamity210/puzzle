import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:puzzle/colors/colors.dart';

class BackgroundPainter extends CustomPainter {
  const BackgroundPainter();

  List<Color> get colors => AppColors.backgroundColors;

  math.Random get random => math.Random();

  List<Path> generateRandomPolygonOrCircle(Size size) {
    final paths = <Path>[];

    for (var i = 0; i < 5; i++) {
      final path = Path();
      final radius = random.nextInt(size.width ~/ 2).toDouble();
      final angle = random.nextDouble() * math.pi * 2;
      final center = Offset(size.width / 2, size.height / 2);
      path.addPolygon(
        [
          center + Offset(radius * math.cos(angle), radius * math.sin(angle)),
          center +
              Offset(
                radius * math.cos(angle + math.pi / 3),
                radius * math.sin(angle + math.pi / 3),
              ),
          center +
              Offset(
                radius * math.cos(angle + math.pi * 2 / 3),
                radius * math.sin(angle + math.pi * 2 / 3),
              ),
          center +
              Offset(
                radius * math.cos(angle + math.pi * 5 / 3),
                radius * math.sin(angle + math.pi * 5 / 3),
              ),
          center +
              Offset(
                radius * math.cos(angle + math.pi * 4 / 3),
                radius * math.sin(angle + math.pi * 4 / 3),
              ),
        ],
        true,
      );
      paths.add(path);
    }

    return paths;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paths = generateRandomPolygonOrCircle(size);

    for (final path in paths) {
      final paint = Paint()
        ..color = colors[random.nextInt(colors.length)].withOpacity(0.85);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
