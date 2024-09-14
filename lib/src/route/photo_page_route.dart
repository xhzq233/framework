import 'dart:math';
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'custom_double_tap_recog.dart';

part 'photo_page_route_widget.dart';

const double _kMinFlingVelocity = 1.0; // Screen widths per second.

// An eyeballed value for the maximum time it takes for a page to animate forward
// if the user releases a page mid swipe.
const int _kMaxDroppedSwipePageForwardAnimationTime = 800; // Milliseconds.

// The maximum time for a page to get reset to it's original position if the
// user releases a page mid swipe.
const int _kMaxPageBackAnimationTime = 300; // Milliseconds.

const int _kOffset2TransitionProgressDivider = 200;
const double _kCloseOpacity = 0.25;
const int _kOffset2ScaleDivider = 330;
const double _kPopMinScale = 0.55;

class PhotoPageRoute extends PageRoute<void> {
  PhotoPageRoute({
    super.settings,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.barrierColor,
    this.barrierLabel,
    required this.draggableChild,
    required this.heroTag,
    this.systemOverlayStyle = SystemUiOverlayStyle.light,
    this.maxScale = 2.4,
    this.minScale = 1.0,
    this.background = const ColoredBox(color: Color(0xFF000000)),
    this.foreground,
    super.fullscreenDialog,
    super.allowSnapshotting = true,
  });

  @override
  bool get opaque => false;

  @override
  Color? barrierColor;

  @override
  String? barrierLabel;

  @override
  bool maintainState = true;

  @override
  Duration transitionDuration;

  final Widget draggableChild;

  final Widget background;
  final Widget? foreground;
  final Object heroTag;
  final double maxScale;
  final double minScale;
  final SystemUiOverlayStyle systemOverlayStyle;

  @override
  @protected
  Widget buildPage(BuildContext context, Animation<double> animation, secondaryAnimation) {
    return AnnotatedRegion(
      value: systemOverlayStyle,
      child: _PhotoPageRouteWidget(
        navigator: navigator!,
        navigationTransitionProgress: animation,
        draggableChild: Hero(tag: heroTag, child: FittedBox(child: draggableChild)),
        background: background,
        foreground: foreground,
        maxScale: maxScale,
        minScale: minScale,
      ),
    );
  }
}
