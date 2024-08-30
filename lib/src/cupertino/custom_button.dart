import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

abstract class PressAnimatable<T extends StatefulWidget> extends State<T> with SingleTickerProviderStateMixin {
  static const Duration kFadeOutDuration = Duration(milliseconds: 120);
  static const Duration kFadeInDuration = Duration(milliseconds: 180);

  bool pressed = false;
  late final AnimationController animationController;
  late final TapGestureRecognizer _tapGestureRecognizer;

  VoidCallback? get onPressed;

  bool get enabled => onPressed != null;

  @override
  @mustCallSuper
  void initState() {
    super.initState();
    animationController = AnimationController(duration: const Duration(milliseconds: 200), value: 0.0, vsync: this);
    _tapGestureRecognizer = TapGestureRecognizer()
      ..onTap = _onTap
      ..onTapDown = _onTapDown
      ..onTapUp = _onTapUp
      ..onTapCancel = _onTapCancel;
  }

  @override
  void dispose() {
    animationController.dispose();
    _tapGestureRecognizer.dispose();
    super.dispose();
  }

  void _onTap() {
    onPressed?.call();
  }

  void _onTapDown(TapDownDetails details) {
    if (!pressed) {
      pressed = true;
      _animate();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (pressed) {
      pressed = false;
      _animate();
    }
  }

  void _onTapCancel() {
    if (pressed) {
      pressed = false;
      _animate();
    }
  }

  void _animate() {
    if (animationController.isAnimating) {
      return;
    }
    final bool wasHeldDown = pressed;
    final TickerFuture ticker = pressed
        ? animationController.animateTo(1.0, duration: kFadeOutDuration, curve: Curves.easeInOutCubicEmphasized)
        : animationController.animateTo(0.0, duration: kFadeInDuration, curve: Curves.easeOutCubic);
    ticker.then<void>((void value) {
      if (mounted && wasHeldDown != pressed) {
        _animate();
      }
    });
  }

  Widget buildContent(BuildContext context);

  @override
  @protected
  Widget build(BuildContext context) => IgnorePointer(
    ignoring: !enabled,
    child: MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
      child: Semantics(
        button: true,
        child: Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: _tapGestureRecognizer.addPointer,
          child: buildContent(context),
        ),
      ),
    ),
  );
}

class CustomCupertinoButton extends StatefulWidget {
  const CustomCupertinoButton({
    Key? key,
    required this.child,
    this.onTap,
    this.disabledOpacity = 0.4,
  }) : super(key: key);

  final Widget child;
  final VoidCallback? onTap;
  final double disabledOpacity;

  @override
  State<CustomCupertinoButton> createState() => _CustomCupertinoButtonState();
}

class _CustomCupertinoButtonState extends PressAnimatable<CustomCupertinoButton> {
  static const double kEndOpacity = 0.45;

  late final Animation<double> _opacityAnimation;

  @override
  VoidCallback? get onPressed => widget.onTap;

  @override
  void initState() {
    super.initState();
    _opacityAnimation =
        animationController.drive(CurveTween(curve: Curves.decelerate)).drive(Tween(begin: 1.0, end: kEndOpacity));
  }

  @override
  Widget buildContent(BuildContext context) {
    final Animation<double> opacity;
    if (enabled) {
      opacity = _opacityAnimation;
    } else {
      opacity = AlwaysStoppedAnimation<double>(widget.disabledOpacity);
    }

    return FadeTransition(
      opacity: opacity,
      child: widget.child,
    );
  }
}

class CustomCupertinoFillButton extends StatefulWidget {
  const CustomCupertinoFillButton({
    Key? key,
    required this.child,
    this.onTap,
    this.borderRadius = const BorderRadius.all(Radius.circular(4)),
  }) : super(key: key);

  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius borderRadius;

  @override
  State<CustomCupertinoFillButton> createState() => _CustomCupertinoFillButtonState();
}

class _CustomCupertinoFillButtonState extends PressAnimatable<CustomCupertinoFillButton> {
  @override
  VoidCallback? get onPressed => widget.onTap;

  Color get fillColor {
    if (Theme.of(context).brightness == Brightness.light) {
      return const Color(0x0F000000);
    } else {
      return const Color(0x0FFFFFFF);
    }
  }

  @override
  void initState() {
    super.initState();
    animationController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget buildContent(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Color.lerp(Colors.transparent, fillColor, animationController.value),
        borderRadius: widget.borderRadius,
      ),
      child: widget.child,
    );
  }
}
