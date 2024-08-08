import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BarLessScaffold extends StatelessWidget {
  const BarLessScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final background = Theme.of(context).colorScheme.background;
    final brightness = ThemeData.estimateBrightnessForColor(background);
    return AnnotatedRegion(
      value: brightness == Brightness.dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Material(
        color: background,
        child: SafeArea(child: child),
      ),
    );
  }
}
