import 'package:flutter/material.dart';

class CustomCupertinoButton extends StatefulWidget {
  const CustomCupertinoButton({
    Key? key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.disabledOpacity = 0.4,
  }) : super(key: key);

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double disabledOpacity;

  @override
  State<CustomCupertinoButton> createState() => _CustomCupertinoButtonState();
}

class _CustomCupertinoButtonState extends State<CustomCupertinoButton> with SingleTickerProviderStateMixin {
  static const Duration kFadeOutDuration = Duration(milliseconds: 120);
  static const Duration kFadeInDuration = Duration(milliseconds: 180);
  static const double kEndOpacity = 0.45;

  bool pressed = false;
  late final AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  bool get enabled => widget.onTap != null || widget.onLongPress != null;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      value: 0.0,
      vsync: this,
    );
    _opacityAnimation =
        _animationController.drive(CurveTween(curve: Curves.decelerate)).drive(Tween(begin: 1.0, end: kEndOpacity));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _animate() {
    if (_animationController.isAnimating) {
      return;
    }
    final bool wasHeldDown = pressed;
    final TickerFuture ticker = pressed
        ? _animationController.animateTo(1.0, duration: kFadeOutDuration, curve: Curves.easeInOutCubicEmphasized)
        : _animationController.animateTo(0.0, duration: kFadeInDuration, curve: Curves.easeOutCubic);
    ticker.then<void>((void value) {
      if (mounted && wasHeldDown != pressed) {
        _animate();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Animation<double> opacity;
    final MouseCursor cursor;
    if (enabled) {
      opacity = _opacityAnimation;
      cursor = SystemMouseCursors.click;
    } else {
      opacity = AlwaysStoppedAnimation<double>(widget.disabledOpacity);
      cursor = SystemMouseCursors.basic;
    }

    // there is always only one tree
    return IgnorePointer(
      ignoring: !enabled,
      child: MouseRegion(
        cursor: cursor,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) {
            if (!pressed) {
              pressed = true;
              _animate();
            }
          },
          onTapUp: (_) {
            if (pressed) {
              pressed = false;
              _animate();
            }
          },
          onTapCancel: () async {
            if (pressed) {
              pressed = false;
              _animate();
            }
          },
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          child: FadeTransition(
            opacity: opacity,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
