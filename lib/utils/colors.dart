import 'package:flutter/material.dart';

abstract class AppColors {
  static const Color darkBlue = Color(0xFF061547);
  static const Color skyBlue = Color(0xFF13B9FD);
  static const Color lightBlue = Color(0xFFC9F6F8);
  static const Color purple = Color(0xFF122164);
  static final Color translucentBlack = Colors.black.withOpacity(0.5);
  static const List<Color> backgroundColors = [
    Color(0xFF02569B),
    Color(0xFF13B9FD),
    Color(0xFF671DE5),
    Color(0xFF750BB1),
    Color(0xFFD5D7DA),
  ];
  static const List<Color> confettiColors = [
    Color(0xFF00AEEF),
    Color(0xFFEC008C),
    Color(0xFF72C8B6),
    Color(0xFFFDFF6A),
    darkBlue,
  ];
}
