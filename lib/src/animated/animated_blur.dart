import 'dart:ui';

import 'package:flutter/material.dart';

class AnimatedBlur extends StatefulWidget {
  const AnimatedBlur({
    Key? key,
    required this.sigma,
    required this.child,
    this.curve = Curves.linear,
    this.duration = const Duration(milliseconds: 200),
    this.reverseDuration,
  }) : super(key: key);

  final double sigma;
  final Widget child;
  final Duration duration;
  final Curve curve;
  final Duration? reverseDuration;

  @override
  State<AnimatedBlur> createState() => _AnimatedTransformState();
}

class _AnimatedTransformState extends State<AnimatedBlur> with SingleTickerProviderStateMixin {
  @protected
  AnimationController get controller => _controller;
  late final AnimationController _controller;
  late Animation<double> _animation;

  late Tween<double> _tween;

  @override
  Widget build(BuildContext context) {
    final sigma = _tween.evaluate(_animation);
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: sigma,
        sigmaY: sigma,
      ),
      child: widget.child,
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      reverseDuration: widget.reverseDuration,
      vsync: this,
    );
    _controller.addListener(() {
      setState(() {});
    });
    _tween = Tween(begin: widget.sigma);
    _updateCurve();
  }

  void _updateCurve() {
    _animation = CurvedAnimation(parent: _controller, curve: widget.curve);
  }

  @override
  void didUpdateWidget(AnimatedBlur oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.curve != oldWidget.curve) _updateCurve();
    _controller.duration = widget.duration;
    _controller.reverseDuration = widget.reverseDuration;
    //正在执行过渡动画
    if (widget.sigma != (_tween.end ?? _tween.begin)) {
      _tween
        ..begin = _tween.evaluate(_animation)
        ..end = widget.sigma;

      _controller
        ..value = 0.0
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
