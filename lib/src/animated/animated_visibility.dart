/// framework - animated_visibility
/// Created by xhz on 10/12/24

import 'package:flutter/widgets.dart';

/// A widget that animate the visibility of its child.
class AnimatedVisibility extends StatefulWidget {
  const AnimatedVisibility({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.axis = Axis.vertical,
    required this.visible,
  });

  final bool visible;
  final Widget child;
  final Duration duration;
  final Axis axis;

  @override
  State<AnimatedVisibility> createState() => _AnimatedVisibilityState();
}

class _AnimatedVisibilityState extends State<AnimatedVisibility> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _controller.addListener(_rebuild);
    if (widget.visible) {
      _controller.forward(from: 0.0);
    }
  }

  void _rebuild() {
    if (mounted) (context as Element).markNeedsBuild();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AnimatedVisibility oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible != oldWidget.visible) {
      _controller.duration = widget.duration;
      if (widget.visible) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Align(
        alignment: AlignmentDirectional.center,
        heightFactor: widget.axis == Axis.vertical ? _controller.value : null,
        widthFactor: widget.axis == Axis.horizontal ? _controller.value : null,
        child: Opacity(
          opacity: _controller.value,
          child: widget.child,
        ),
      ),
    );
  }
}
