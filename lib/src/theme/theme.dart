/// framework - theme
/// Created by xhz on 9/26/24

import 'dart:math';

import 'package:flutter/material.dart';

const chineseFont = 'PingFang SC';

const defaultTextTheme = Typography.blackCupertino;

final _seedColors = [
  Colors.lightGreen,
  Colors.purple,
  Colors.orange,
  Colors.blue,
  Colors.red,
  Colors.teal,
  Colors.pink,
  Colors.indigo,
  Colors.amber,
  Colors.cyan,
  Colors.deepOrange,
  Colors.deepPurple,
  Colors.green,
  Colors.lime,
  Colors.yellow,
  Colors.brown,
  Colors.grey,
  Colors.blueGrey,
];

final _randomSeedColor = _seedColors[Random().nextInt(_seedColors.length)];

final _lightScheme = ColorScheme.fromSeed(seedColor: _randomSeedColor);
final _darkScheme = ColorScheme.fromSeed(seedColor: _randomSeedColor, brightness: Brightness.dark);

class AppThemeData {
  final bool lightMode;

  const AppThemeData({required this.lightMode});

  ThemeData get themeData {
    final colorScheme = lightMode ? _lightScheme : _darkScheme;

    var textTheme = defaultTextTheme;
    textTheme = textTheme.apply(fontFamilyFallback: const [chineseFont]);

    return ThemeData(
      brightness: lightMode ? Brightness.light : Brightness.dark,
      colorScheme: colorScheme,
      textTheme: textTheme,
    );
  }
}
