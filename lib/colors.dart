import 'package:flutter/material.dart';

enum ThemeModeType { whiteMode, blackMode }

final appColorsEnum = {
  ThemeModeType.whiteMode: {
    'popup-text': Colors.black,
    'popup-h1': Colors.black,
    'popup-h2': Colors.black87,
    'popup-background': Colors.white,
    'button-color': Colors.blue,
    'bg': Colors.white,
    'text': Colors.black,
  },
  ThemeModeType.blackMode: {
    'popup-text': Colors.white,
    'popup-h1': Colors.white,
    'popup-h2': Colors.white70,
    'popup-background': Colors.blueGrey,
    'button-color': Color(0xFF0369A1),
    'bg': Colors.black,
    'text': Colors.white,
  },
};
