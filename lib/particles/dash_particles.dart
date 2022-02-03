import 'dart:async' as async;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:puzzle/particles/particle_circles.dart';

class DashParticles extends StatefulWidget {
  const DashParticles({required this.imageSize, Key? key}) : super(key: key);

  final int imageSize;

  @override
  _DashParticlesState createState() => _DashParticlesState();
}

class _DashParticlesState extends State<DashParticles> {
  late final Future<ImageParticles> getIP = getImageParticles();
  async.Timer? _timer;

  var _mouseX = 0.0;
  var _mouseY = 0.0;

  double repulsionChangeDistance = 100;

  @override
  void initState() {
    super.initState();
    _timer = async.Timer.periodic(const Duration(milliseconds: 34), (timer) {
      setState(() {
        repulsionChangeDistance = max(0, repulsionChangeDistance - 1.5);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;

    super.dispose();
  }

  Future<ImageParticles> getImageParticles() async {
    final dashImageBytes = await rootBundle.load('assets/images/dash/dash.png');
    return ImageParticles(
      img.copyResize(
        img.decodePng(dashImageBytes.buffer.asUint8List())!,
        height: widget.imageSize,
        width: widget.imageSize,
      ),
      (widget.imageSize * 0.03).toInt(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: FutureBuilder<ImageParticles>(
        future: getIP,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return CustomPaint(
              isComplex: true,
              willChange: true,
              painter: ImageParticlesPainter(
                snapshot.data!,
                _mouseX,
                _mouseY,
                repulsionChangeDistance,
              ),
              child: SizedBox(
                height: widget.imageSize.toDouble(),
                width: widget.imageSize.toDouble(),
                child: GestureDetector(
                  excludeFromSemantics: true,
                  onPanUpdate: (details) {
                    repulsionChangeDistance = 150;
                    _mouseX = details.localPosition.dx;
                    _mouseY = details.localPosition.dy;
                  },
                ),
              ),
            );
          }

          return const CircularProgressIndicator();
        },
      ),
    );
  }
}
