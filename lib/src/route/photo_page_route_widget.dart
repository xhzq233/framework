part of 'photo_page_route.dart';

const double _kMaxScale = 1.6;
const double _kMinScale = 1.0;

class _PhotoPageRouteWidget extends StatefulWidget {
  const _PhotoPageRouteWidget({
    required this.navigator,
    required this.realTransitionProgress,
    required this.draggableChild,
    required this.background,
    this.foreground,
  });

  final Widget? foreground;
  final NavigatorState navigator;
  final Animation<double> realTransitionProgress;
  final Widget draggableChild;

  final Widget background;

  @override
  State<_PhotoPageRouteWidget> createState() => _PhotoPageRouteWidgetState();
}

class _PhotoPageRouteWidgetState extends State<_PhotoPageRouteWidget>
    with TickerProviderStateMixin, _PhotoPageRouteWidgetStateMixin {
  final _tapGestureRecognizer = TapGestureRecognizer();

  late final _transitionProgress =
      AnimationController(value: 1.0, vsync: widget.navigator);

  @override
  bool dragEnd(Offset velocity) {
    final navigator = widget.navigator;
    // Fling in the appropriate direction.
    // AnimationController.fling is guaranteed to
    // take at least one frame.
    //
    // This curve has been determined through rigorously eyeballing native iOS
    // animations.
    const Curve animationCurve = Curves.fastLinearToSlowEaseIn;
    final bool animateForward;

    // If the user releases the page with sufficient velocity,
    if (velocity.dy.abs() / navigator.context.size!.height >=
        _kMinFlingVelocity) {
      animateForward = false;
    } else {
      animateForward = _transitionProgress.value > _kCloseOpacity;
    }
    if (animateForward) {
      // The closer the panel is to dismissing, the shorter the animation is.
      // We want to cap the animation time, but we want to use a linear curve
      // to determine it.
      final int droppedPageForwardAnimationTime = min(
        lerpDouble(_kMaxDroppedSwipePageForwardAnimationTime, 0,
                _transitionProgress.value)!
            .floor(),
        _kMaxPageBackAnimationTime,
      );
      _transitionProgress.animateTo(1.0,
          duration: Duration(milliseconds: droppedPageForwardAnimationTime),
          curve: animationCurve);
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
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ValueListenableBuilder(
          valueListenable: _transitionProgress,
          builder: (ctx, val, c) => ValueListenableBuilder(
            valueListenable: widget.realTransitionProgress,
            builder: (ctx, animationVal, c) => Opacity(
              opacity: animationVal * val,
              child: widget.background,
            ),
          ),
        ),
        ValueListenableBuilder(
          valueListenable: transform,
          builder: (context, transform, child) => Transform(
            alignment: Alignment.center,
            transform: transform,
            child: Listener(onPointerDown: _handleOnPointerDown, child: child),
          ),
          child: widget.draggableChild,
        ),
        if (widget.foreground != null)
          ValueListenableBuilder(
            valueListenable: _transitionProgress,
            builder: (ctx, val, c) => ValueListenableBuilder(
              valueListenable: widget.realTransitionProgress,
              builder: (ctx, animationVal, c) => Opacity(
                opacity: animationVal * val,
                child: widget.foreground,
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _scaleGestureRecognizer.dispose();
    _tapGestureRecognizer.dispose();
    _transitionProgress.dispose();
    super.dispose();
  }

  @override
  void dragUpdate(Offset offset) {
    _transitionProgress.value =
        (1.0 - offset.dy.abs() / _kOffset2TransitionProgressDivider)
            .clamp(0.0, 1.0);
  }
}

mixin _PhotoPageRouteWidgetStateMixin
    on TickerProviderStateMixin<_PhotoPageRouteWidget> {
  final _doubleTapGestureRecognizer = CustomDoubleTapGestureRecognizer();
  final _scaleGestureRecognizer = ScaleGestureRecognizer();

  Offset? _normalizedPosition;
  double? _scaleBeforeGestureStart;
  double scale = 1.0;
  Offset position = Offset.zero;
  Offset probablyDoubleTapPosition = Offset.zero;

  final ValueNotifier<Matrix4> transform = ValueNotifier(Matrix4.identity());
  late final AnimationController _scaleAnimationController =
      AnimationController(vsync: this);
  Animation<double>? _scaleAnimation;

  late final AnimationController _positionAnimationController =
      AnimationController(vsync: this);
  Animation<Offset>? _positionAnimation;

  bool? verticalDrag;
  bool? isScale;

  @override
  void dispose() {
    _scaleAnimationController.removeStatusListener(onAnimationStatus);
    _scaleAnimationController.dispose();
    _positionAnimationController.dispose();
    _doubleTapGestureRecognizer.dispose();
    _scaleGestureRecognizer.dispose();
    transform.dispose();
    super.dispose();
  }

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
    isScale = null;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    final double newScale = _scaleBeforeGestureStart! * details.scale;
    final Offset delta = details.focalPoint - _normalizedPosition!;

    if (details.pointerCount == 2) {
      // scale
      scale = newScale;
      position = delta;
      isScale ??= true;
      _setState();
    } else if (details.pointerCount == 1) {
      if (_scaleBeforeGestureStart == 1.0 && verticalDrag != false) {
        scale = (1 - position.dy.abs() / _kOffset2ScaleDivider).clamp(0.6, 1.0);
        position = delta;
        verticalDrag ??=
            details.focalPointDelta.dx.abs() < details.focalPointDelta.dy.abs();
        isScale = false;
        // drag
        dragUpdate(delta);
        _setState();
      } else {
        // drag after scale
        position = delta;
        isScale ??= true;
        _setState();
      }
    }
  }

  // return is popped
  bool dragEnd(Offset velocity);

  void dragUpdate(Offset offset);

  void _onScaleEnd(ScaleEndDetails details) {
    if (dragEnd(details.velocity.pixelsPerSecond)) {
      return;
    }

    //animate back to maxScale if gesture exceeded the maxScale specified
    if (scale > _kMaxScale) {
      final double scaleComebackRatio = _kMaxScale / scale;
      animateScale(scale, _kMaxScale);
      final Offset clampedPosition = clampPosition(
        position: position * scaleComebackRatio,
        scale: _kMaxScale,
      );
      animatePosition(position, clampedPosition);
      return;
    }
    if (scale < _kMinScale) {
      //animate back to minScale if gesture fell smaller than the minScale specified
      final double scaleComebackRatio = _kMinScale / scale;
      animateScale(scale, _kMinScale);
      animatePosition(
        position,
        clampPosition(
          position: position * scaleComebackRatio,
          scale: _kMinScale,
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

  late final Size _size;

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
      // animatePosition(position, probablyDoubleTapPosition);
      animateScale(scale, 2.0);
    }
  }

  void animateScale(double from, double to) {
    _scaleAnimation = Tween<double>(
      begin: from,
      end: to,
    ).animate(_scaleAnimationController);
    _scaleAnimationController
      ..value = 0.0
      ..fling(velocity: 0.4);
  }

  void animatePosition(Offset from, Offset to) {
    _positionAnimation = Tween<Offset>(begin: from, end: to)
        .animate(_positionAnimationController);
    _positionAnimationController
      ..value = 0.0
      ..fling(velocity: 0.4);
  }

  void onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      /// Check if scale is equal to initial after scale animation update
      // if (scaleStateController.scaleState != PhotoViewScaleState.initial && scale == scaleBoundaries.initialScale) {
      //   scaleStateController.setInvisibly(PhotoViewScaleState.initial);
      // }
    }
  }

  @override
  void initState() {
    super.initState();
    _scaleAnimationController
      ..addStatusListener(onAnimationStatus)
      ..addListener(() {
        scale = _scaleAnimation!.value;
        _setState();
      });
    _positionAnimationController.addListener(() {
      position = _positionAnimation!.value;
      _setState();
    });
    _doubleTapGestureRecognizer
      ..onDoubleTap = _onDoubleTap
      ..onDoubleTapDown = (details) {
        probablyDoubleTapPosition = details.localPosition - position;
      };
    _scaleGestureRecognizer
      ..onStart = _onScaleStart
      ..onUpdate = _onScaleUpdate
      ..onEnd = _onScaleEnd;

    _size = View.of(context).screenSize;
  }
}
