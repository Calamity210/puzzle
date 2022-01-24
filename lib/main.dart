import 'package:bonfire/bonfire.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
  late final ValueNotifier<double> _time;
  late final Ticker _ticker;

  var _mouseX = 0.0;
  var _mouseY = 0.0;

  ImageParticles ip = ImageParticles(
    img.decodeImage(imageBytes.buffer.asUint8List().buffer.asUint8List())!,
  );

  @override
  void initState() {
    super.initState();

    _time = ValueNotifier(0);
    _ticker = createTicker(_update);

    _ticker.start();
  }

  @override
  void dispose() {
    _time.dispose();
    _ticker.dispose();

    super.dispose();
  }

  void _update(Duration elapsed) {
    _time.value = elapsed.inMicroseconds / 1e6;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: MouseRegion(
        onHover: (event) {
          repulsionChangeDistance = 150;
          _mouseX = event.position.dx;
          _mouseY = event.position.dy;
          setState(() {});
        },
        child: CustomPaint(
          willChange: _ticker.isActive,
          painter: ImageParticlesPainter(ip, _time, _mouseX, _mouseY),
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
    );
  }
}
