import 'package:flutter/material.dart';

class ImplicitlyTransition<T> extends StatefulWidget {
  const ImplicitlyTransition({
    Key? key,
    required this.begin,
    required this.end,
    this.child,
    this.duration = const Duration(milliseconds: 300),
    required this.builder,
    this.curve = Curves.easeInOut,
  }) : super(key: key);
  final T begin;
  final T end;
  final Widget? child;
  final Duration duration;
  final Widget Function(BuildContext context, Widget? child, T value) builder;
  final Curve curve;

  @override
  State<ImplicitlyTransition> createState() => _ImplicitlyTransitionState<T>();
}

class _ImplicitlyTransitionState<T> extends State<ImplicitlyTransition<T>> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final Tween<T> tween = Tween<T>();
  late final Animatable animatable;

  // animate when widget is created
  @override
  void initState() {
    _controller = AnimationController(vsync: this, duration: widget.duration);
    animatable = tween.chain(CurveTween(curve: widget.curve));
    tween.begin = widget.begin;
    tween.end = widget.end;
    _controller.addListener(() {
      setState(() {});
    });
    _controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // animate when widget is unmounted

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, widget.child, animatable.evaluate(_controller));
  }
}
