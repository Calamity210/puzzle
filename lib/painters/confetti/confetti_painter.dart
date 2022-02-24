import 'dart:math';

import 'package:flutter/material.dart';
import 'package:puzzle/painters/confetti/confetti.dart';

class ConfettiPainter extends CustomPainter {
  const ConfettiPainter(this.confettis);
  final List<Confetti> confettis;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < confettis.length; i++) {
      final confetti = confettis[i];
      confetti.draw(canvas);
      if (confetti.y > size.height) {
        final rand = Random();
        confettis[i] = Confetti(
          x: rand.nextDouble() * size.width,
          y: rand.nextDouble() * -size.height,
          speed: rand.nextInt(2) - 1,
          size: rand.nextDouble() * (size.height / 50 - size.width / 25) +
              size.width / 25,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
