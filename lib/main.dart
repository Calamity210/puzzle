import 'dart:async' as async;

import 'package:bonfire/bonfire.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:puzzle/background/background_painter.dart';
import 'package:puzzle/game/game_page.dart';
import 'package:puzzle/particles/dash_particles.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await Flame.device.setLandscape();
    await Flame.device.fullScreen();
  }

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

  runApp(const MaterialApp(home: HomePage()));
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        print('layout');
        return Container(
          color: const Color(0xFF061547),
          child: CustomPaint(
            painter: BackgroundPainter(),
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
                DashParticles(imageSize: (c.maxHeight * 0.75).toInt()),
              ],
            ),
          ),
        );
      },
    );
  }
}
