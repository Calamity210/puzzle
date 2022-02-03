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

  FlameAudio.bgm.initialize();

  await FlameAudio.audioCache.loadAll([
    'sfx/click.mp3',
    'sfx/restart.wav',
    'sfx/win.wav',
    'sfx/place.flac',
    'sfx/beep.wav',
    'sfx/slider-click.wav',
  ]);

  await FlameAudio.bgm.load('bg.mp3');

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
        return Material(
          color: const Color(0xFF061547),
          child: CustomPaint(
            isComplex: true,
            painter: const BackgroundPainter(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                LeftBar(width: c.maxWidth / 4),
                const Spacer(flex: 8),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: DashParticles(imageSize: (c.maxHeight * 0.8).toInt()),
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

class LeftBar extends StatefulWidget {
  const LeftBar({required this.width, Key? key}) : super(key: key);

  final double width;

  @override
  _LeftBarState createState() => _LeftBarState();
}

class _LeftBarState extends State<LeftBar> {
  var _mapSize = 10.0;
  var _boxCount = 3.0;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        color: Colors.black.withOpacity(0.5),
        width: widget.width,
        child: SliderTheme(
          data: const SliderThemeData(
            showValueIndicator: ShowValueIndicator.never,
            thumbShape: _ThumbShape(),
            valueIndicatorColor: Color(0xFF13B9FD),
            activeTrackColor: Color(0xFF13B9FD),
          ),
          child: Column(
            children: [
              const Spacer(),
              const Text(
                'Map Size',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Slider(
                label: '${_mapSize.toInt()}',
                value: _mapSize,
                min: 10,
                max: 15,
                divisions: 5,
                onChanged: (value) {
                  FlameAudio.audioCache.play('sfx/slider-click.wav');
                  setState(() => _mapSize = value);
                },
              ),
              const Spacer(),
              const Text(
                'Box Count',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Slider(
                label: '${_boxCount.toInt()}',
                value: _boxCount,
                min: 3,
                max: 6,
                divisions: 3,
                onChanged: (value) {
                  FlameAudio.audioCache.play('sfx/slider-click.wav');
                  setState(() => _boxCount = value);
                },
              ),
              const Spacer(),
              TextButton(
                onPressed: () async {
                  FlameAudio.audioCache.play('sfx/beep.wav');
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GamePage(
                        mapSize: _mapSize.toInt(),
                        boxCount: _boxCount.toInt(),
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Start',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF13B9FD),
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThumbShape extends RoundSliderThumbShape {
  const _ThumbShape();

  PaddleSliderValueIndicatorShape get _indicatorShape =>
      const PaddleSliderValueIndicatorShape();

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    super.paint(
      context,
      center,
      activationAnimation: activationAnimation,
      enableAnimation: enableAnimation,
      isDiscrete: isDiscrete,
      labelPainter: labelPainter,
      parentBox: parentBox,
      sliderTheme: sliderTheme,
      textDirection: textDirection,
      value: value,
      textScaleFactor: textScaleFactor,
      sizeWithOverflow: sizeWithOverflow,
    );
    _indicatorShape.paint(
      context,
      center,
      activationAnimation: const AlwaysStoppedAnimation(1),
      enableAnimation: enableAnimation,
      isDiscrete: isDiscrete,
      labelPainter: labelPainter,
      parentBox: parentBox,
      sliderTheme: sliderTheme,
      textDirection: textDirection,
      value: value,
      textScaleFactor: textScaleFactor,
      sizeWithOverflow: sizeWithOverflow,
    );
  }
}
