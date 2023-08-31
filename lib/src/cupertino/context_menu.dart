import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:boxy/boxy.dart';
import 'package:flutter/cupertino.dart' hide CupertinoContextMenu, CupertinoContextMenuAction;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart' show GestureDisposition, TapGestureRecognizer, kMinFlingVelocity;
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import '../util/widget/widget_util.dart';
import '../layout/auto_fitted_box.dart';

part 'context_menu_layout.dart';

const double _kOpenScale = 1.1;

const Duration _kModalPopupTransitionDuration = Duration(milliseconds: 216);

const Duration _previewLongPressTimeout = Duration(milliseconds: 448);

final int _animationDuration = _previewLongPressTimeout.inMilliseconds + _kModalPopupTransitionDuration.inMilliseconds;

AlignmentDirectional get kSheetAlignment => AlignmentDirectional.topCenter;

const List<BoxShadow> _endBoxShadow = <BoxShadow>[
  BoxShadow(
    color: Color(0x40000000),
    blurRadius: 10.0,
    spreadRadius: 0.5,
  ),
];

const Color _borderColor = CupertinoDynamicColor.withBrightness(
  color: Color(0xFFA9A9AF),
  darkColor: Color(0xFF57585A),
);

typedef _DismissCallback = void Function(
  BuildContext context,
  double scale,
  double opacity,
);

typedef ContextMenuPreviewBuilder = Widget Function(
  BuildContext context,
  Animation<double> animation,
  Widget child,
);

typedef CupertinoContextMenuBuilder = Widget Function(
  BuildContext context,
  Animation<double> animation,
);

class CustomCupertinoContextMenu extends StatefulWidget {
  CustomCupertinoContextMenu({
    super.key,
    required this.actions,
    required this.child,
    this.borderRadius,
    this.previewMaxScale = _kOpenScale,
  }) : assert(actions.isNotEmpty);

  static const List<BoxShadow> kEndBoxShadow = _endBoxShadow;

  static final double animationOpensAt = _previewLongPressTimeout.inMilliseconds / _animationDuration;

  final Widget child;

  final double previewMaxScale;

  final List<Widget> actions;

  final BorderRadius? borderRadius;

  @override
  State<CustomCupertinoContextMenu> createState() => _CustomCupertinoContextMenuState();
}

class _CustomCupertinoContextMenuState extends State<CustomCupertinoContextMenu> with TickerProviderStateMixin {
  final GlobalKey _childGlobalKey = GlobalKey();
  bool _childHidden = false;

  late final AnimationController _openController = AnimationController(
    duration: _previewLongPressTimeout,
    vsync: this,
    upperBound: CustomCupertinoContextMenu.animationOpensAt,
  );
  Rect? _decoyChildEndRect;
  OverlayEntry? _lastOverlayEntry;
  _ContextMenuRoute<void>? _route;
  final double _midpoint = CustomCupertinoContextMenu.animationOpensAt / 2;
  late final _tapGestureRecognizer = TapGestureRecognizer(debugOwner: this);

  @override
  void initState() {
    super.initState();
    _openController.addStatusListener(_onDecoyAnimationStatusChange);
    _tapGestureRecognizer

      /// we don't need onTap since onTapUp will be called definitely if wins
      ..onTapCancel = _cancelActionIfNeeded
      ..onTapDown = _onTapDown
      ..onTapUp = _onTapUp;
  }

  /// called when animation's value first reaches [_midpoint]
  void _listenerCallback() {
    if (_openController.value >= _midpoint) {
      HapticFeedback.heavyImpact();
      _tapGestureRecognizer.resolve(GestureDisposition.accepted);
      _openController.removeListener(_listenerCallback);
    }
  }

  void _openContextMenu() {
    setState(() {
      _childHidden = true;
    });
    // hide keyboard
    FocusManager.instance.primaryFocus?.unfocus();

    _route = _ContextMenuRoute<void>(
      actions: widget.actions,
      barrierLabel: 'Dismiss',
      // MARK - 改动3，去除没有动画的blur
      filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      previousChildRect: _decoyChildEndRect!,
      previewMaxScale: widget.previewMaxScale,
      builder: (context, Animation<double> animation) => CustomBoxy(
        delegate: AutoFittedBoxyDelegate(
          originalSize: _decoyChildEndRect!.size / _kOpenScale,
          scaleUpperLimit: double.infinity,
          scaleLowerLimit: 0.1,
        ),
        children: [
          if (widget.borderRadius == null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12 * animation.value),
              child: widget.child,
            )
          else
            widget.child
        ],
      ),
    );

    Navigator.of(context, rootNavigator: true).push<void>(_route!);
    _route!.animation!.addStatusListener(_routeAnimationStatusListener);
  }

  void _onDecoyAnimationStatusChange(AnimationStatus animationStatus) {
    switch (animationStatus) {
      case AnimationStatus.dismissed:
        if (_route == null) {
          setState(() {
            _childHidden = false;
          });
        }
        _lastOverlayEntry?.remove();
        _lastOverlayEntry = null;
      case AnimationStatus.completed:
        _openContextMenu();
        // remove decoy child with 1 frame delay in case flashing
        SchedulerBinding.instance.addPostFrameCallback((Duration _) {
          _lastOverlayEntry?.remove();
          _lastOverlayEntry = null;
          _openController.reset();
        });
      case AnimationStatus.forward:
      case AnimationStatus.reverse:
        return;
    }
  }

  void _routeAnimationStatusListener(AnimationStatus status) {
    if (status != AnimationStatus.dismissed) {
      return;
    }
    if (mounted) {
      setState(() {
        _childHidden = false;
      });
    }
    _route!.animation!.removeStatusListener(_routeAnimationStatusListener);
    _route = null;
  }

  void _onTapUp(TapUpDetails details) => _cancelActionIfNeeded();

  void _cancelActionIfNeeded() {
    _openController.removeListener(_listenerCallback);
    if (_openController.isAnimating && _openController.value < _midpoint) {
      _openController.reverse();
    }
  }

  void _onTapDown(TapDownDetails _) {
    _openController.addListener(_listenerCallback);
    setState(() {
      _childHidden = true;
    });

    final Rect childRect = _childGlobalKey._globalRect;
    _decoyChildEndRect = Rect.fromCenter(
      center: childRect.center,
      width: childRect.width * _kOpenScale,
      height: childRect.height * _kOpenScale,
    );

    // MARK - 改动2，overlay，去除builder
    _lastOverlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return _DecoyChild(
          beginRect: childRect,
          controller: _openController,
          endRect: _decoyChildEndRect,
          borderRadius: widget.borderRadius,
          child: widget.child,
        );
      },
    );
    Overlay.of(context, rootOverlay: true, debugRequiredFor: widget).insert(_lastOverlayEntry!);
    _openController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: kIsWeb ? SystemMouseCursors.click : MouseCursor.defer,
      child: Listener(
        onPointerDown: _tapGestureRecognizer.addPointer,
        child: TickerMode(
          enabled: !_childHidden,
          child: Visibility.maintain(
            key: _childGlobalKey,
            visible: !_childHidden,
            child: widget.child,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _openController.dispose();
    _tapGestureRecognizer.dispose();
    // todo(xhz): change this odd strategy of remove
    _lastOverlayEntry?.remove();
    super.dispose();
  }
}

class _DecoyChild extends StatefulWidget {
  const _DecoyChild({
    this.beginRect,
    required this.controller,
    this.endRect,
    this.child,
    this.borderRadius,
  });

  final Rect? beginRect;
  final AnimationController controller;
  final Rect? endRect;
  final Widget? child;
  final BorderRadius? borderRadius;

  @override
  _DecoyChildState createState() => _DecoyChildState();
}

class _DecoyChildState extends State<_DecoyChild> with TickerProviderStateMixin {
  late Animation<Rect?> _rect;
  late Animation<Decoration> _boxDecoration;

  @override
  void initState() {
    super.initState();

    const double beginPause = 1.0;
    const double openAnimationLength = 5.0;
    const double totalOpenAnimationLength = beginPause + openAnimationLength;
    final double endPause =
        ((totalOpenAnimationLength * _animationDuration) / _previewLongPressTimeout.inMilliseconds) -
            totalOpenAnimationLength;

    _rect = TweenSequence<Rect?>(<TweenSequenceItem<Rect?>>[
      TweenSequenceItem<Rect?>(
        tween: RectTween(
          begin: widget.beginRect,
          end: widget.beginRect,
        ).chain(CurveTween(curve: Curves.linear)),
        weight: beginPause,
      ),
      TweenSequenceItem<Rect?>(
        tween: RectTween(
          begin: widget.beginRect,
          end: widget.endRect,
        ).chain(CurveTween(curve: Curves.easeOutSine)),
        weight: openAnimationLength,
      ),
      TweenSequenceItem<Rect?>(
        tween: RectTween(
          begin: widget.endRect,
          end: widget.endRect,
        ).chain(CurveTween(curve: Curves.linear)),
        weight: endPause,
      ),
    ]).animate(widget.controller);

    _boxDecoration = DecorationTween(
      begin: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: widget.borderRadius,
        boxShadow: const <BoxShadow>[],
      ),
      end: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: widget.borderRadius,
        boxShadow: _endBoxShadow,
      ),
    ).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: Interval(0.0, CustomCupertinoContextMenu.animationOpensAt),
      ),
    );
  }

  Widget _buildAnimation(BuildContext context, Widget? child) {
    final scale = _rect.value!.width / widget.beginRect!.width;
    return Positioned(
      top: _rect.value!.top,
      left: _rect.value!.left,
      width: widget.beginRect!.width,
      height: widget.beginRect!.height,
      child: Container(
        transform: Matrix4.identity().scaled(scale, scale),
        decoration: _boxDecoration.value,
        child: widget.child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedBuilder(
          builder: _buildAnimation,
          animation: widget.controller,
        ),
      ],
    );
  }
}

class _ContextMenuRoute<T> extends PopupRoute<T> {
  _ContextMenuRoute({
    required List<Widget> actions,
    this.barrierLabel,
    required this.previewMaxScale,
    CupertinoContextMenuBuilder? builder,
    super.filter,
    required Rect previousChildRect,
    super.settings,
  })  : assert(actions.isNotEmpty),
        _actions = actions,
        _builder = builder,
        _previousChildRect = previousChildRect;

  static const Color _kModalBarrierColor = Color(0x6604040F);

  final List<Widget> _actions;
  final CupertinoContextMenuBuilder? _builder;
  final GlobalKey _childGlobalKey = GlobalKey();
  bool _externalOffstage = false;
  bool _internalOffstage = false;
  final double previewMaxScale;
  final Rect _previousChildRect;
  double? _scale = 1.0;
  final GlobalKey _sheetGlobalKey = GlobalKey();

  // todo(xhz): curves adjustment
  static final CurveTween _curve = CurveTween(curve: Curves.easeOutQuad);
  static final CurveTween _curveReverse = CurveTween(curve: Curves.easeInQuad);

  static final RectTween _rectTween = RectTween();
  static final Animatable<Rect?> _rectAnimatable = _rectTween.chain(_curve);
  static final RectTween _rectTweenReverse = RectTween();
  static final Animatable<Rect?> _rectAnimatableReverse = _rectTweenReverse.chain(
    _curveReverse,
  );
  static final RectTween _sheetRectTween = RectTween();
  final Animatable<Rect?> _sheetRectAnimatable = _sheetRectTween.chain(
    _curve,
  );
  final Animatable<Rect?> _sheetRectAnimatableReverse = _sheetRectTween.chain(
    _curveReverse,
  );
  static final Tween<double> _sheetScaleTween = Tween<double>();
  static final Animatable<double> _sheetScaleAnimatable = _sheetScaleTween.chain(
    _curve,
  );
  static final Animatable<double> _sheetScaleAnimatableReverse = _sheetScaleTween.chain(
    _curveReverse,
  );
  final Tween<double> _opacityTween = Tween<double>(begin: 0.0, end: 1.0);
  late Animation<double> _sheetOpacity;

  @override
  final String? barrierLabel;

  @override
  Color get barrierColor => _kModalBarrierColor;

  @override
  bool get barrierDismissible => true;

  @override
  bool get semanticsDismissible => false;

  @override
  Duration get transitionDuration => _kModalPopupTransitionDuration;

  static Rect _getScaledRect(GlobalKey globalKey, double scale) {
    final Rect childRect = globalKey._globalRect;
    final Size sizeScaled = childRect.size * scale;
    final Offset offsetScaled = Offset(
      childRect.left + (childRect.size.width - sizeScaled.width) / 2,
      childRect.top + (childRect.size.height - sizeScaled.height) / 2,
    );
    return offsetScaled & sizeScaled;
  }

  static Rect _getSheetRectBegin(Rect childRect, Rect sheetRect, EdgeInsets padding, Size screenSize) {
    /// MARK - 改动4，menu弹出位置
    final bool isBelow = _menuPositionIsBelow(childRect, padding, screenSize);

    final Offset target = isBelow ? childRect.bottomCenter : childRect.topCenter;
    final Offset centered = target - Offset(sheetRect.width / 2, 0.0);
    return centered & sheetRect.size;
  }

  void _onDismiss(BuildContext context, double scale, double opacity) {
    _scale = scale;
    _opacityTween.end = opacity;
    _sheetOpacity = _opacityTween.animate(CurvedAnimation(
      parent: animation!,
      curve: const Interval(0.9, 1.0),
    ));
    Navigator.of(context).pop();
  }

  void _updateTweenRects() {
    // MARK - 改动4，更改childRect到当前center
    // 第一帧进行更新
    final Rect childRect = _scale == null ? _childGlobalKey._globalRect : _getScaledRect(_childGlobalKey, _scale!);
    _rectTween.begin = _previousChildRect;
    _rectTween.end = childRect;

    final Rect childRectOriginal = Rect.fromCenter(
      center: _previousChildRect.center,
      width: _previousChildRect.width / _kOpenScale,
      height: _previousChildRect.height / _kOpenScale,
    );

    final Rect sheetRect = _sheetGlobalKey._globalRect;
    // Use flutterView to get padding,
    // since MediaQuery.of(context) will watch changes.
    final flutterView = View.of(_childGlobalKey.currentContext!);

    final Rect sheetRectBegin = _getSheetRectBegin(
      childRectOriginal,
      sheetRect,
      flutterView.realPadding,
      flutterView.screenSize,
    );
    _sheetRectTween.begin = sheetRectBegin;
    _sheetRectTween.end = sheetRect;
    _sheetScaleTween.begin = 0.0;
    _sheetScaleTween.end = _scale;

    _rectTweenReverse.begin = childRectOriginal;
    _rectTweenReverse.end = childRect;
  }

  void _setOffstageInternally() {
    super.offstage = _externalOffstage || _internalOffstage;

    changedInternalState();
  }

  @override
  bool didPop(T? result) {
    _updateTweenRects();
    return super.didPop(result);
  }

  @override
  set offstage(bool value) {
    _externalOffstage = value;
    _setOffstageInternally();
  }

  @override
  TickerFuture didPush() {
    _internalOffstage = true;
    _setOffstageInternally();

    SchedulerBinding.instance.addPostFrameCallback((Duration _) {
      _updateTweenRects();
      _internalOffstage = false;
      _setOffstageInternally();
    });
    return super.didPush();
  }

  @override
  Animation<double> createAnimation() {
    final Animation<double> animation = super.createAnimation();
    _sheetOpacity = _opacityTween.animate(CurvedAnimation(
      parent: animation,
      curve: Curves.linear,
    ));
    return animation;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return const SizedBox.shrink();
  }

  @override
  Widget buildTransitions(
      BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    // Widget res;
    if (!animation.isCompleted) {
      final bool reverse = animation.status == AnimationStatus.reverse;
      final Rect rect = reverse ? _rectAnimatableReverse.evaluate(animation)! : _rectAnimatable.evaluate(animation)!;
      final Rect sheetRect =
          reverse ? _sheetRectAnimatableReverse.evaluate(animation)! : _sheetRectAnimatable.evaluate(animation)!;
      final double sheetScale =
          reverse ? _sheetScaleAnimatableReverse.evaluate(animation) : _sheetScaleAnimatable.evaluate(animation);
      return Stack(
        children: <Widget>[
          Positioned.fromRect(
            key: _childGlobalKey,
            rect: rect,
            child: _builder!(context, animation),
          ),
          Positioned.fromRect(
            rect: sheetRect,
            child: FadeTransition(
              opacity: _sheetOpacity,
              child: Transform.scale(
                alignment: kSheetAlignment,
                scale: sheetScale,
                child: _ContextMenuSheet(
                  key: _sheetGlobalKey,
                  actions: _actions,
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      //动画的第一帧和最后一帧
      return _ContextMenuRouteStatic(
        actions: _actions,
        childGlobalKey: _childGlobalKey,
        onDismiss: _onDismiss,
        previousChildRect: _previousChildRect,
        sheetGlobalKey: _sheetGlobalKey,
        previewMaxScale: previewMaxScale,
        child: _builder!(context, animation),
      );
    }

    // MARK - 改动3，增加blur动画
    // final sigma = animation.value * 5.0;
    // return BackdropFilter(
    //   filter: ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
    //   child: res,
    // );
  }
}

class _ContextMenuRouteStatic extends StatefulWidget {
  const _ContextMenuRouteStatic({
    this.actions,
    required this.child,
    this.childGlobalKey,
    required this.previousChildRect,
    required this.previewMaxScale,
    this.onDismiss,
    this.sheetGlobalKey,
  });

  // MARK - 改动4，增加previousChildRect用于判断位置
  final Rect previousChildRect;
  final double previewMaxScale;
  final List<Widget>? actions;
  final Widget child;
  final GlobalKey? childGlobalKey;
  final _DismissCallback? onDismiss;
  final GlobalKey? sheetGlobalKey;

  @override
  _ContextMenuRouteStaticState createState() => _ContextMenuRouteStaticState();
}

class _ContextMenuRouteStaticState extends State<_ContextMenuRouteStatic> with TickerProviderStateMixin {
  static const double _kMinScale = 0.8;

  static const double _kSheetScaleThreshold = 0.9;
  static const double _kPadding = 20.0;
  static const double _kDamping = 400.0;
  static const Duration _kMoveControllerDuration = Duration(milliseconds: 600);

  late Offset _dragOffset;
  double _lastScale = 1.0;
  late AnimationController _moveController;
  late AnimationController _sheetController;
  late Animation<Offset> _moveAnimation;
  late Animation<double> _sheetScaleAnimation;
  late Animation<double> _sheetOpacityAnimation;

  static double _getScale(double maxDragDistance, double dy) {
    final double dyDirectional = dy <= 0.0 ? dy : -dy;
    return math.max(
      _kMinScale,
      (maxDragDistance + dyDirectional) / maxDragDistance,
    );
  }

  void _onPanStart(DragStartDetails details) {
    _moveController.value = 1.0;
    _setDragOffset(Offset.zero);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _setDragOffset(_dragOffset + details.delta);
  }

  void _onPanEnd(DragEndDetails details) {
    if (details.velocity.pixelsPerSecond.dy.abs() >= kMinFlingVelocity) {
      final bool flingIsAway = details.velocity.pixelsPerSecond.dy > 0;
      final double finalPosition = flingIsAway ? _moveAnimation.value.dy + 100.0 : 0.0;

      if (flingIsAway && _sheetController.status != AnimationStatus.forward) {
        _sheetController.forward();
      } else if (!flingIsAway && _sheetController.status != AnimationStatus.reverse) {
        _sheetController.reverse();
      }

      _moveAnimation = Tween<Offset>(
        begin: Offset(0.0, _moveAnimation.value.dy),
        end: Offset(0.0, finalPosition),
      ).animate(_moveController);
      _moveController.reset();
      _moveController.duration = const Duration(
        milliseconds: 64,
      );
      _moveController.forward();
      _moveController.addStatusListener(_flingStatusListener);
      return;
    }

    if (_lastScale == _kMinScale) {
      widget.onDismiss!(context, _lastScale, _sheetOpacityAnimation.value);
      return;
    }

    _moveController.addListener(_moveListener);
    _moveController.reverse();
  }

  void _moveListener() {
    if (_lastScale > _kSheetScaleThreshold) {
      _moveController.removeListener(_moveListener);
      if (_sheetController.status != AnimationStatus.dismissed) {
        _sheetController.reverse();
      }
    }
  }

  void _flingStatusListener(AnimationStatus status) {
    if (status != AnimationStatus.completed) {
      return;
    }

    _moveController.duration = _kMoveControllerDuration;

    _moveController.removeStatusListener(_flingStatusListener);

    if (_moveAnimation.value.dy == 0.0) {
      return;
    }
    widget.onDismiss!(context, _lastScale, _sheetOpacityAnimation.value);
  }

  void _setDragOffset(Offset dragOffset) {
    final double endX = _kPadding * dragOffset.dx / _kDamping;
    final double endY = dragOffset.dy >= 0.0 ? dragOffset.dy : _kPadding * dragOffset.dy / _kDamping;
    setState(() {
      _dragOffset = dragOffset;
      _moveAnimation = Tween<Offset>(
        begin: Offset.zero,
        end: Offset(
          clampDouble(endX, -_kPadding, _kPadding),
          endY,
        ),
      ).animate(
        CurvedAnimation(
          parent: _moveController,
          curve: Curves.elasticIn,
        ),
      );

      if (_lastScale <= _kSheetScaleThreshold &&
          _sheetController.status != AnimationStatus.forward &&
          _sheetScaleAnimation.value != 0.0) {
        _sheetController.forward();
      } else if (_lastScale > _kSheetScaleThreshold &&
          _sheetController.status != AnimationStatus.reverse &&
          _sheetScaleAnimation.value != 1.0) {
        _sheetController.reverse();
      }
    });
  }

  List<Widget> _getChildren() {
    // MARK - 改动4，更改menu到当前center
    final Widget child = AnimatedBuilder(
      animation: _moveController,
      builder: _buildChildAnimation,
      child: widget.child,
    );

    final Widget sheet = AnimatedBuilder(
      animation: _sheetController,
      builder: _buildSheetAnimation,
      child: _ContextMenuSheet(
        key: widget.sheetGlobalKey,
        actions: widget.actions!,
      ),
    );

    return [child, sheet];
  }

  Widget _buildSheetAnimation(BuildContext context, Widget? child) {
    return Transform.scale(
      alignment: kSheetAlignment,
      scale: _sheetScaleAnimation.value,
      child: FadeTransition(
        opacity: _sheetOpacityAnimation,
        child: child,
      ),
    );
  }

  Widget _buildChildAnimation(BuildContext context, Widget? child) {
    _lastScale = _getScale(MediaQuery.sizeOf(context).height, _moveAnimation.value.dy);
    return Transform.scale(
      key: widget.childGlobalKey,
      scale: _lastScale,
      child: child,
    );
  }

  Widget _buildAnimation(BuildContext context, Widget? child) {
    return Transform.translate(
      offset: _moveAnimation.value,
      child: child,
    );
  }

  @override
  void initState() {
    super.initState();
    _moveController = AnimationController(
      duration: _kMoveControllerDuration,
      value: 1.0,
      vsync: this,
    );
    _sheetController = AnimationController(
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _sheetScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _sheetController,
        curve: Curves.linear,
        reverseCurve: Curves.easeInBack,
      ),
    );
    _sheetOpacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(_sheetController);
    _setDragOffset(Offset.zero);
  }

  @override
  void dispose() {
    _moveController.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = _getChildren();

    return SafeArea(
      child: GestureDetector(
        onPanEnd: _onPanEnd,
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        child: AnimatedBuilder(
          animation: _moveController,
          builder: _buildAnimation,
          child: CustomBoxy(
            delegate: _ContextMenuLayoutDelegate(
              childGlobalRect: widget.previousChildRect,
              maxScale: widget.previewMaxScale,
              padding: MediaQuery.paddingOf(context),
              screenSize: MediaQuery.sizeOf(context),
            ),
            children: children,
          ),
        ),
      ),
    );
  }
}

class _ContextMenuSheet extends StatelessWidget {
  _ContextMenuSheet({
    super.key,
    required this.actions,
  }) : assert(actions.isNotEmpty);

  final List<Widget> actions;

  static const double _kMenuWidth = 210.0;

  List<Widget> getChildren(BuildContext context) {
    final Widget menu = SizedBox(
      width: _kMenuWidth,
      child: IntrinsicHeight(
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(13.0)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              actions.first,
              for (Widget action in actions.skip(1))
                DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: CupertinoDynamicColor.resolve(
                          _borderColor,
                          context,
                        ),
                        width: 0.4,
                      ),
                    ),
                  ),
                  position: DecorationPosition.foreground,
                  child: action,
                ),
            ],
          ),
        ),
      ),
    );

    return [
      const Spacer(),
      menu,
      const Spacer(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: getChildren(context),
    );
  }
}
