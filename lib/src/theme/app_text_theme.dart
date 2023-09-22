import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum AppFontWeight {
  regular(FontWeight.w400),
  medium(FontWeight.w500),
  semibold(FontWeight.w600),
  bold(FontWeight.w700);

  final FontWeight weight;

  const AppFontWeight(this.weight);
}

final class AppFontFamily {
  final String? regular;

  final String? medium;

  final String? semibold;

  final String? bold;

  final List<String> fallback;

  const AppFontFamily(this.regular, this.medium, this.semibold, this.bold, this.fallback);

  String? adjustWithFontWeight(AppFontWeight fontWeight) => switch (fontWeight) {
        AppFontWeight.regular => regular,
        AppFontWeight.medium => medium,
        AppFontWeight.semibold => semibold,
        AppFontWeight.bold => bold
      };
}
