import 'dart:async' as async;
import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:puzzle/painters/particles/particle_circles.dart';

class DashParticles extends StatefulWidget {
  const DashParticles({required this.imageSize, Key? key}) : super(key: key);

  final int imageSize;

  @override
  _DashParticlesState createState() => _DashParticlesState();
}

class _DashParticlesState extends State<DashParticles> {
  late Future<ImageParticles> getIP = getImageParticles();

  @override
  void didUpdateWidget(DashParticles oldWidget) {
    super.didUpdateWidget(oldWidget);
    getIP = getImageParticles();
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
            return DashWidget(
              imagePainter: snapshot.data!,
              imageSize: widget.imageSize.toDouble(),
            );
          }

          return const CircularProgressIndicator();
        },
      ),
    );
  }
}

class DashWidget extends StatefulWidget {
  const DashWidget({
    required this.imagePainter,
    required this.imageSize,
    Key? key,
  }) : super(key: key);

  final ImageParticles imagePainter;
  final double imageSize;

  @override
  _DashWidgetState createState() => _DashWidgetState();
}

class _DashWidgetState extends State<DashWidget> {
  async.Timer? _timer;

  var _mouseX = 0.0;
  var _mouseY = 0.0;

  double repulsionChangeDistance = 150;

  @override
  void initState() {
    super.initState();
    _timer = async.Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (repulsionChangeDistance != 0 || widget.imagePainter.points
          .where((p) => p.velocity.distanceTo(Vector2.zero()) > 0.5)
          .isNotEmpty) {
        setState(() {
          repulsionChangeDistance = max(0, repulsionChangeDistance - 0.75);
        });
      }
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
    return CustomPaint(
      isComplex: true,
      willChange: true,
      foregroundPainter: ImageParticlesPainter(
        widget.imagePainter,
        _mouseX,
        _mouseY,
        repulsionChangeDistance,
      ),
      child: SizedBox.square(
        dimension: widget.imageSize,
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
}
