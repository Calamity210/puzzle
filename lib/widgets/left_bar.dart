import 'package:flutter/material.dart';
import 'package:puzzle/game/game_page.dart';
import 'package:puzzle/utils/audio_utils.dart';
import 'package:puzzle/utils/colors.dart';
import 'package:puzzle/widgets/custom_slider.dart';

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
        color: AppColors.translucentBlack,
        width: widget.width,
        child: SliderTheme(
          data: const SliderThemeData(
            showValueIndicator: ShowValueIndicator.never,
            thumbShape: _ThumbShape(),
            valueIndicatorColor: AppColors.skyBlue,
            activeTrackColor: AppColors.skyBlue,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              CustomSlider(
                label: 'Map Size',
                value: _mapSize,
                min: 10,
                max: 15,
                divisions: 5,
                onChanged: (value) => setState(() => _mapSize = value),
              ),
              CustomSlider(
                label: 'Box Count',
                value: _boxCount,
                min: 3,
                max: 6,
                divisions: 3,
                onChanged: (value) => setState(() => _boxCount = value),
              ),
              TextButton(
                onPressed: () async {
                  AudioUtils.playBeep();
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
                    color: AppColors.skyBlue,
                  ),
                ),
              ),
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
