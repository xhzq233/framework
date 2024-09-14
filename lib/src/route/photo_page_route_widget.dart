part of 'photo_page_route.dart';

class _PhotoPageRouteWidget extends StatefulWidget {
  const _PhotoPageRouteWidget({
    required this.navigator,
    required this.navigationTransitionProgress,
    required this.draggableChild,
    required this.background,
    required this.foreground,
    required this.minScale,
    required this.maxScale,
  });

  final Widget? foreground;
  final NavigatorState navigator;
  final Animation<double> navigationTransitionProgress;
  final Widget draggableChild;
  final double minScale;
  final double maxScale;

  final Widget background;

  @override
  State<_PhotoPageRouteWidget> createState() => _PhotoPageRouteWidgetState();
}

class _PhotoPageRouteWidgetState extends State<_PhotoPageRouteWidget>
    with TickerProviderStateMixin<_PhotoPageRouteWidget> {
  final _tapGestureRecognizer = TapGestureRecognizer();
  final _doubleTapGestureRecognizer = CustomDoubleTapGestureRecognizer();
  final _scaleGestureRecognizer = ScaleGestureRecognizer();
  late final gestureTransitionProgress = AnimationController(value: 1.0, vsync: widget.navigator);

  Offset? _normalizedPosition;
  double? _scaleBeforeGestureStart;
  double scale = 1.0;
  Offset position = Offset.zero;
  Offset probablyDoubleTapPosition = Offset.zero;

  final ValueNotifier<Matrix4> transform = ValueNotifier(Matrix4.identity());
  late final AnimationController _scaleAnimationController = AnimationController(vsync: this);
  Animation<double>? _scaleAnimation;

  late final AnimationController _positionAnimationController = AnimationController(vsync: this);
  Animation<Offset>? _positionAnimation;

  bool? verticalDrag;

  void _setState() {
    final newVal = Matrix4.identity()
      ..translate(position.dx, position.dy)
      ..scale(scale);

    transform.value = newVal;
  }

  void _onScaleStart(ScaleStartDetails details) {
    _scaleBeforeGestureStart = scale;
    _normalizedPosition = details.focalPoint - position;
    _scaleAnimationController.stop();
    _positionAnimationController.stop();
    verticalDrag = null;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    final double newScale = _scaleBeforeGestureStart! * details.scale;
    final Offset delta = details.focalPoint - _normalizedPosition!;

    scale = newScale;
    position = delta;

    if (details.pointerCount >= 2) {
      // scale
    }
    if (details.pointerCount == 1) {
      // drag
      if (_scaleBeforeGestureStart == 1.0) {
        // If drag up, no opacity change
        if (position.dy < 0) {
        } else {
          // the initial drag, can fast pop
          // update draggable child's scale and opacity by dy
          scale *= (1 - position.dy.abs() / _kOffset2ScaleDivider).clamp(_kPopMinScale, 1.0);
          verticalDrag ??= details.focalPointDelta.dx.abs() < details.focalPointDelta.dy.abs();
          // other parts' opacity
          gestureTransitionProgress.value =
              (1.0 - position.dy.abs() / _kOffset2TransitionProgressDivider).clamp(0.0, 1.0);
        }
      }
    }
    _setState();
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (dragEndIfPopped(details.velocity.pixelsPerSecond)) {
      return;
    }

    //animate back to maxScale if gesture exceeded the maxScale specified
    if (scale > widget.maxScale) {
      final double scaleComebackRatio = widget.maxScale / scale;
      animateScale(scale, widget.maxScale);
      final Offset clampedPosition = clampPosition(
        position: position * scaleComebackRatio,
        scale: widget.maxScale,
      );
      animatePosition(position, clampedPosition);
      return;
    }
    if (scale < widget.minScale) {
      //animate back to minScale if gesture fell smaller than the minScale specified
      final double scaleComebackRatio = widget.minScale / scale;
      animateScale(scale, widget.minScale);
      animatePosition(
        position,
        clampPosition(
          position: position * scaleComebackRatio,
          scale: widget.minScale,
        ),
      );
      return;
    }

    // get magnitude from gesture velocity
    final double magnitude = details.velocity.pixelsPerSecond.distance;

    // animate velocity only if there is no scale change and a significant magnitude
    // if (_scaleBeforeGestureStart! / scale == 1.0 && magnitude >= 400.0) {
    //
    // }
    final Offset direction = details.velocity.pixelsPerSecond / magnitude;
    animatePosition(
      position,
      clampPosition(position: position + direction * 100.0),
    );
  }

  late Size _size;

  (double, double) cornersY({double? scale}) {
    final double scale0 = scale ?? this.scale;

    final double computedHeight = _size.width * scale0;
    final double screenHeight = _size.width;

    const double positionY = 0;
    final double heightDiff = computedHeight - screenHeight;

    final double minY = ((positionY - 1).abs() / 2) * heightDiff * -1;
    final double maxY = ((positionY + 1).abs() / 2) * heightDiff;
    return (minY, maxY);
  }

  (double, double) cornersX({double? scale}) {
    final double scale0 = scale ?? this.scale;

    final double computedWidth = _size.width * scale0;
    final double screenWidth = _size.width;

    const double positionX = 0;
    final double widthDiff = computedWidth - screenWidth;

    final double minX = ((positionX - 1).abs() / 2) * widthDiff * -1;
    final double maxX = ((positionX + 1).abs() / 2) * widthDiff;
    return (minX, maxX);
  }

  Offset clampPosition({Offset? position, double? scale}) {
    final double scale0 = scale ?? this.scale;
    final Offset position0 = position ?? this.position;

    final double computedWidth = _size.width * scale0;
    final double computedHeight = _size.width * scale0;

    final double screenWidth = _size.width;
    final double screenHeight = _size.height;

    double finalX = 0.0;
    if (screenWidth < computedWidth) {
      final cornersX = this.cornersX(scale: scale0);
      finalX = position0.dx.clamp(cornersX.$1, cornersX.$2);
    }

    double finalY = 0.0;
    if (screenHeight < computedHeight) {
      final cornersY = this.cornersY(scale: scale0);
      finalY = position0.dy.clamp(cornersY.$1, cornersY.$2);
    }

    return Offset(finalX, finalY);
  }

  void _onDoubleTap() {
    if (scale > 1.0) {
      // return to 1x
      animateScale(scale, 1.0);
      animatePosition(position, Offset.zero);
    } else {
      // scale to 2x
      // todo: probablyDoubleTapPosition is not correct
      animatePosition(position, -probablyDoubleTapPosition);
      animateScale(scale, 2.5);
    }
  }

  void animateScale(double from, double to) {
    _scaleAnimation = Tween<double>(begin: from, end: to).animate(_scaleAnimationController);
    _scaleAnimationController
      ..value = 0.0
      ..fling(velocity: 0.4);
  }

  void animatePosition(Offset from, Offset to) {
    _positionAnimation = Tween<Offset>(begin: from, end: to).animate(_positionAnimationController);
    _positionAnimationController
      ..value = 0.0
      ..fling(velocity: 0.4);
  }

  bool dragEndIfPopped(Offset velocity) {
    final navigator = widget.navigator;
    // Fling in the appropriate direction.
    // AnimationController.fling is guaranteed to
    // take at least one frame.
    //
    // This curve has been determined through rigorously eyeballing native iOS
    // animations.
    const Curve animationCurve = Curves.fastLinearToSlowEaseIn;
    final bool animateForward;

    if (velocity.dy < 0) {
      animateForward = true;
    } else if (velocity.dy.abs() / navigator.context.size!.height >= _kMinFlingVelocity) {
      // If the user releases the page with sufficient velocity,
      animateForward = false;
    } else {
      // If the user releases the page with sufficient distance,
      animateForward = gestureTransitionProgress.value > _kCloseOpacity;
    }
    if (animateForward) {
      // The closer the panel is to dismissing, the shorter the animation is.
      // We want to cap the animation time, but we want to use a linear curve
      // to determine it.
      final int droppedPageForwardAnimationTime = min(
        lerpDouble(_kMaxDroppedSwipePageForwardAnimationTime, 0, gestureTransitionProgress.value)!.floor(),
        _kMaxPageBackAnimationTime,
      );
      gestureTransitionProgress.animateTo(1.0,
          duration: Duration(milliseconds: droppedPageForwardAnimationTime), curve: animationCurve);
      return false;
    } else {
      // This route is destined to pop at this point. Reuse navigator's pop.
      navigator.pop();
      return true;
    }
  }

  void _handleOnPointerDown(PointerDownEvent event) {
    _scaleGestureRecognizer.addPointer(event);
    _tapGestureRecognizer.addPointer(event);
    _doubleTapGestureRecognizer.addPointer(event);
  }

  @override
  void initState() {
    super.initState();
    _tapGestureRecognizer.onTap = widget.navigator.pop;
    _scaleAnimationController.addListener(() {
      scale = _scaleAnimation!.value;
      _setState();
    });
    _positionAnimationController.addListener(() {
      position = _positionAnimation!.value;
      _setState();
    });
    _doubleTapGestureRecognizer
      ..onDoubleTap = _onDoubleTap
      ..onDoubleTapDown = (TapDownDetails details) {
        // save the position of the double tap
        // relative to the draggable child center
        probablyDoubleTapPosition = (details.localPosition - position) - _size.center(Offset.zero);
      };
    _scaleGestureRecognizer
      ..onStart = _onScaleStart
      ..onUpdate = _onScaleUpdate
      ..onEnd = _onScaleEnd;
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.sizeOf(context);
    final opacityListenable = Listenable.merge([gestureTransitionProgress, widget.navigationTransitionProgress]);
    return Stack(
      fit: StackFit.expand,
      children: [
        ListenableBuilder(
          listenable: opacityListenable,
          builder: (ctx, c) => Opacity(
            opacity: gestureTransitionProgress.value * widget.navigationTransitionProgress.value,
            child: widget.background,
          ),
        ),
        ValueListenableBuilder(
          valueListenable: transform,
          builder: (context, transform, child) => Transform(
            alignment: Alignment.center,
            transform: transform,
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: _handleOnPointerDown,
              child: child,
            ),
          ),
          child: widget.draggableChild,
        ),
        if (widget.foreground != null)
          ListenableBuilder(
            listenable: opacityListenable,
            builder: (ctx, c) => Opacity(
              opacity: gestureTransitionProgress.value * widget.navigationTransitionProgress.value,
              child: widget.foreground,
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _scaleGestureRecognizer.dispose();
    _tapGestureRecognizer.dispose();
    gestureTransitionProgress.dispose();
    _scaleAnimationController.dispose();
    _positionAnimationController.dispose();
    _doubleTapGestureRecognizer.dispose();
    transform.dispose();
    super.dispose();
  }
}
