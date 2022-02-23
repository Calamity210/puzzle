import 'dart:math';
import 'dart:ui';

import 'package:puzzle/utils/colors.dart';

class Confetti {
  Confetti({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
  });

  double x;
  double y;
  double speed;
  final double size;

  final rand = Random();
  late double time = rand.nextDouble() * 100;
  late Color color =
      AppColors.confettiColors[rand.nextInt(AppColors.confettiColors.length)];
  late int amp = rand.nextInt(28) + 2;
  late double phase = (rand.nextDouble() * 1.5) + 0.5;
  late final form = rand.nextDouble().round();

  void draw(Canvas c) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    c.save();
    c.translate(x, y);
    c.translate(amp * sin(time * phase), speed * cos(2 * time * phase));
    c.rotate(time);
    c.scale(cos(time * 0.25), sin(time * 0.25));
    if (form == 0) {
      c.drawRect(
        Rect.fromCenter(center: Offset.zero, width: size, height: size / 2),
        paint,
      );
    } else {
      c.drawCircle(Offset.zero, size / 2, paint);
    }
    c.restore();
    time += 0.1;
    speed += 0.005;
    y += speed;
  }
}
