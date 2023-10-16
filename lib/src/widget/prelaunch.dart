/// framework - prelaunch
/// Created by xhz on 10/15/23

import 'package:flutter/material.dart';

class PreLaunch extends StatefulWidget {
  const PreLaunch({super.key, required this.app, required this.preLaunch, this.splash});

  final Widget app;

  final Widget? splash;

  final Future<void> Function() preLaunch;

  @override
  State<PreLaunch> createState() => _PreLaunchState();
}

class _PreLaunchState extends State<PreLaunch> {
  @override
  void initState() {
    super.initState();
    widget.preLaunch().then((_) => setState(() => _canLaunch = true));
  }

  bool _canLaunch = false;

  @override
  Widget build(BuildContext context) {
    if (!_canLaunch) {
      final platformBrightness = View.of(context).platformDispatcher.platformBrightness;
      final color = platformBrightness == Brightness.light ? Colors.white : Colors.black;
      return ColoredBox(
        color: color,
        child: Align(
          child: widget.splash,
        ),
      );
    } else {
      return widget.app;
    }
  }
}
