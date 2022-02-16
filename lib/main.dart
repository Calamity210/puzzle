import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:puzzle/background/background_painter.dart';
import 'package:puzzle/colors/colors.dart';
import 'package:puzzle/particles/dash_particles.dart';
import 'package:puzzle/utils/audio_utils.dart';
import 'package:puzzle/widgets/left_bar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await flameSetup();
  runApp(MaterialApp(home: HomePage()));
}

Future<void> flameSetup() async {
  await Future.wait([
    if (!kIsWeb) ...[
      Flame.device.fullScreen(),
      Flame.device.setLandscape(),
    ],
    AudioUtils.loadAll(),
    Flame.images.loadAll([
      'dash/dash_idle.png',
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
  ]);
}

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final maxSize = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        return Material(
          color: AppColors.darkBlue,
          child: CustomPaint(
            painter: const BackgroundPainter(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                LeftBar(width: c.maxWidth / 4),
                const Spacer(flex: 8),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'TAP & DRAG OVER ME',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      DashParticles(
                        imageSize: (min(c.maxHeight, c.maxWidth) * 0.8).toInt(),
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        );
      },
    );
  }
}
