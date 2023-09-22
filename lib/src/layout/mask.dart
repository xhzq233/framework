import 'dart:math';

import 'package:boxy/boxy.dart';
import 'package:flutter/widgets.dart';

class OverlayAtLeastChildSize extends StatelessWidget {
  const OverlayAtLeastChildSize({super.key, required this.child, required this.overlay});

  final Widget child;
  final Widget overlay;

  @override
  Widget build(BuildContext context) {
    return CustomBoxy(
      delegate: _OverlayAtLeastChildSize(),
      children: [
        child,
        overlay,
      ],
    );
  }
}

class BackgroundAtLeastChildSize extends StatelessWidget {
  const BackgroundAtLeastChildSize({super.key, required this.child, required this.background});

  final Widget child;
  final Widget background;

  @override
  Widget build(BuildContext context) {
    return CustomBoxy(
      delegate: _BackgroundAtLeastChildSize(),
      children: [
        background,
        child,
      ],
    );
  }
}

class _OverlayAtLeastChildSize extends BoxyDelegate {
  @override
  Size layout() {
    final overlay = children[1];
    final child = children[0];

    final childSize = child.layout(constraints);
    final overlayConstraints = constraints.copyWith(minHeight: childSize.height, minWidth: childSize.width);
    final overlaySize = overlay.layout(overlayConstraints);

    return Size(max(overlaySize.width, childSize.width), max(overlaySize.height, childSize.height));
  }
}

class _BackgroundAtLeastChildSize extends BoxyDelegate {
  @override
  Size layout() {
    final child = children[1];
    final background = children[0];
    final childSize = child.layout(constraints);
    final backgroundConstraints = constraints.copyWith(minHeight: childSize.height, minWidth: childSize.width);
    final backgroundSize = background.layout(backgroundConstraints);

    return Size(max(childSize.width, backgroundSize.width), max(childSize.height, backgroundSize.height));
  }
}
