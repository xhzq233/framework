import 'dart:async';
import 'dart:ui';
import 'package:flutter/widgets.dart';

final class Device {
  Device(BuildContext context) {
    //listen window padding change
    final FlutterView view = View.of(context);
    Zone.root.run(() {
      final old = view.platformDispatcher.onMetricsChanged;
      void update() {
        devicePixelRatio = view.devicePixelRatio;
        viewPadding = EdgeInsets.only(
          bottom: view.viewPadding.bottom / devicePixelRatio,
          left: view.viewPadding.left / devicePixelRatio,
          right: view.viewPadding.right / devicePixelRatio,
          top: view.viewPadding.top / devicePixelRatio,
        );
        screenSize = view.physicalSize / devicePixelRatio;
        old?.call();
      }

      update();
      view.platformDispatcher.onMetricsChanged = update;
    });
  }

  double devicePixelRatio = 0;
  EdgeInsets viewPadding = EdgeInsets.zero;
  Size screenSize = Size.zero;

  bool get isLargeScreen {
    return screenSize.height >= 390;
  }
}
