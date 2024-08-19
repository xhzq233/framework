import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StatusBarRegion extends StatelessWidget {
  const StatusBarRegion({super.key, required this.child, this.background});

  final Widget child;

  final Color? background;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness;
    if (background != null) {
      brightness = ThemeData.estimateBrightnessForColor(background!);
    } else {
      brightness = Theme.of(context).brightness;
    }
    final res = AnnotatedRegion(
      value: brightness == Brightness.dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: AnimatedDefaultTextStyle(
        style: Theme.of(context).textTheme.bodyMedium!,
        duration: kThemeChangeDuration,
        child: SafeArea(child: child),
      ),
    );
    if (background != null) {
      return ColoredBox(color: background!, child: res);
    }
    return res;
  }
}
