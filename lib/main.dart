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

  runApp(const MaterialApp(home: HomePage()));
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  async.Timer? _timer;

  var _mouseX = 0.0;
  var _mouseY = 0.0;

  late final image = img.decodeImage(
    imageBytes.buffer.asUint8List().buffer.asUint8List(),
  )!;

  late ImageParticles ip = ImageParticles(image);

  @override
  void initState() {
    super.initState();
    _timer = async.Timer.periodic(const Duration(milliseconds: 17), (timer) {
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
      color: Colors.white,
      child: Container(
        color: Colors.black,
        height: image.height + padding * 2,
        width: image.width + padding * 2,
        child: MouseRegion(
          onHover: (event) {
            repulsionChangeDistance = 150;
            _mouseX = event.position.dx;
            _mouseY = event.position.dy;
          },
          child: CustomPaint(
            willChange: true,
            painter: ImageParticlesPainter(ip, _mouseX, _mouseY),
            child: Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
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
            ),
          ),
        ),
      ),
    );
  }
}
