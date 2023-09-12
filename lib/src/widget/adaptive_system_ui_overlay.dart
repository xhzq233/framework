import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class AdaptiveSystemUIOverlay extends StatelessWidget {
  final Widget child;

  const AdaptiveSystemUIOverlay({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = CupertinoTheme.of(context).brightness ?? MediaQuery.platformBrightnessOf(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: brightness == Brightness.light ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light, child: child);
  }
}
