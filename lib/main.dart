import 'dart:async' as async;
import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:puzzle/game/game_page.dart';
import 'package:puzzle/particles/particle_circles.dart';

late ByteData imageBytes;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await Flame.device.setLandscape();
    await Flame.device.fullScreen();
  }

  imageBytes = await rootBundle.load('assets/images/dash/dash.png');
  await FlameAudio.audioCache.loadAll(['sfx/click.mp3']);

  async.unawaited(
    Flame.images.loadAll([
      'dash/dash_idle.png',
      'dash/dash_jump.png',
      'dash/dash_run_down.png',
      'dash/dash_run_left.png',
      'dash/dash_run_right.png',
      'dash/dash_run_up.png',
      'floor/destination.png',
      'floor/floor0.png',
      'floor/floor1.png',
      'floor/floor2.png',
      'floor/floor3.png',
      'floor/floor4.png',
      'floor/floor5.png',
      'floor/floor6.png',
      'items/box.png',
      'items/box_activated.png',
      'items/box_animation.png',
      'items/box_animation.png',
      'wall/wall.png',
      'wall/wall0.png',
      'wall/wall1.png',
      'wall/wall2.png',
      'wall/wall3.png',
      'wall/wall4.png',
      'wall/wall5.png',
      'wall/wall6.png',
      'wall/wall7.png',
      'wall/wall_cracked0.png',
      'wall/wall_cracked1.png',
      'wall/wall_cracked2.png',
      'wall/wall_cracked3.png',
      'wall/wall_cracked4.png',
      'wall/wall_cracked5.png',
      'wall/wall_cracked6.png',
      'wall/wall_cracked7.png',
      'box_help.png',
      'restart.png',
    ]),
  );

  runApp(
    LayoutBuilder(
      builder: (context, c) {
        return MaterialApp(
          home: HomePage(imageSize: (c.maxHeight * 0.75).toInt()),
        );
      },
    ),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({required this.imageSize, Key? key}) : super(key: key);

  final int imageSize;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  async.Timer? _timer;

  var _mouseX = 0.0;
  var _mouseY = 0.0;

  late final image = img.copyResize(
    img.decodeImage(
      imageBytes.buffer.asUint8List().buffer.asUint8List(),
    )!,
    height: widget.imageSize,
    width: widget.imageSize,
  );

  late ImageParticles ip = ImageParticles(
    image,
    (widget.imageSize * 0.03).toInt(),
  );

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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          TextButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GamePage(),
                ),
              );
            },
            child: const Text(
              'Start',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          CustomPaint(
            isComplex: true,
            willChange: true,
            painter: ImageParticlesPainter(ip, _mouseX, _mouseY),
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
          ),
        ],
      ),
    );
  }
}
