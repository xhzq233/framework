/// framework - progress
/// Created by xhz on 9/2/24

import 'package:flutter/material.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'dart:async';

class NNProgress extends StatefulWidget {
  const NNProgress({super.key, this.value});

  final double? value;

  @override
  State<NNProgress> createState() => _NNProgressState();
}

class _NNProgressState extends State<NNProgress> with SingleTickerProviderStateMixin {
  double angle = 0;

  late final AnimationController _animationController;
  static const _twoPi = 2 * 3.1415926535;
  static const _periodInMilliSecond = 400;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: _periodInMilliSecond));
    if (widget.value != null) {
      angle = _twoPi * widget.value!;
    } else {
      _animationController.repeat();
      _animationController.addListener(_update);
    }
  }

  void _update() {
    setState(() {
      angle = _twoPi * _animationController.value;
    });
  }

  @override
  void didUpdateWidget(covariant NNProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != null) {
      if (_animationController.isAnimating) {
        _animationController.stop();
        _animationController.removeListener(_update);
      }
      angle = _twoPi * widget.value!;
    } else if (!_animationController.isAnimating) {
      _animationController.repeat();
      _animationController.addListener(_update);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Transform.rotate(
        angle: angle,
        child: const Icon(Icons.refresh, size: 24, color: Colors.blue),
      ),
    );
  }
}

class NNRefreshIndicator extends StatelessWidget {
  const NNRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
    this.onLoad,
    this.hasMore = true,
  });

  final FutureOr<void> Function() onRefresh;
  final FutureOr Function()? onLoad;
  final bool hasMore;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return EasyRefresh(
      header: const BuilderHeader(
          triggerOffset: 0,
          clamping: false,
          processedDuration: Duration.zero,
          position: IndicatorPosition.behind,
          hapticFeedback: true,
          builder: _builder),
      footer: onLoad != null
          ? const BuilderFooter(
        builder: _builder,
        triggerOffset: 0,
        clamping: false,
        processedDuration: Duration.zero,
        position: IndicatorPosition.behind,
        hapticFeedback: true,
      )
          : null,
      onLoad: hasMore ? onLoad : null,
      onRefresh: onRefresh,
      child: child,
    );
  }
}

Widget _builder(BuildContext context, IndicatorState state) {
  switch (state.mode) {
    case IndicatorMode.inactive:
    case IndicatorMode.processed:
    case IndicatorMode.done:
      return const SizedBox.shrink();
    case IndicatorMode.drag:
    case IndicatorMode.armed:
      return Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 16),
        child: Align(child: NNProgress(value: state.offset / 64)),
      );
    case IndicatorMode.ready:
    case IndicatorMode.processing:
    case IndicatorMode.secondaryArmed:
    case IndicatorMode.secondaryReady:
    case IndicatorMode.secondaryOpen:
    case IndicatorMode.secondaryClosing:
      return const Padding(
        padding: EdgeInsets.only(top: 16, bottom: 16),
        child: Align(child: NNProgress()),
      );
  }
}
