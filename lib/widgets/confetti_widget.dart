import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:puzzle/painters/confetti/confetti.dart';
import 'package:puzzle/painters/confetti/confetti_painter.dart';

class ConfettiWidget extends StatefulWidget {
  const ConfettiWidget({Key? key}) : super(key: key);

  @override
  _ConfettiWidgetState createState() => _ConfettiWidgetState();
}

class _ConfettiWidgetState extends State<ConfettiWidget> {
  Timer? _timer;
  List<Confetti>? confettis;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    confettis ??= List.generate(100, (i) {
      final rand = Random();
      return Confetti(
        x: rand.nextDouble() * size.width,
        y: rand.nextDouble() * -size.height,
        speed: rand.nextInt(2) - 1,
        size:
        rand.nextDouble() * ((size.height / 50) - (size.width / 25)) +
            (size.width / 25),
      );
    });

    return CustomPaint(
      painter: ConfettiPainter(confettis!),
      size: size,
    );
  }
}
