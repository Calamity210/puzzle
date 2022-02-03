import 'package:flutter/material.dart';
import 'package:puzzle/utils/audio_utils.dart';

class CustomSlider extends StatelessWidget {
  const CustomSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Slider(
          label: '${value.toInt()}',
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: (value) {
            AudioUtils.playSliderClick();
            onChanged(value);
          },
        ),
      ],
    );
  }
}
