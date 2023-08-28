import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const _pressedColor = CupertinoColors.systemGrey5;

const _unPressedColor = Colors.transparent;

class NavigationLink extends StatefulWidget {
  final VoidCallback? onPressed;

  final VoidCallback? onLongPressed;

  final BorderRadius? borderRadius;

  final EdgeInsets padding;

  final Widget child;

  const NavigationLink({
    super.key,
    required this.child,
    this.onPressed,
    this.onLongPressed,
    this.borderRadius,
    this.padding = const EdgeInsets.only(left: 10, right: 16),
  });

  @override
  State<NavigationLink> createState() => _NavigationLinkState();
}

class _NavigationLinkState extends State<NavigationLink> {
  bool _isPressing = false;
  Timer? _postPressTimer;

  Color get _backgroundColor => _isPressing ? _pressedColor : _unPressedColor;

  void _updateIsPressing(bool isPressing) {
    if (!mounted) {
      return;
    }
    if (_isPressing == isPressing) {
      return;
    }
    setState(() {
      _isPressing = isPressing;
    });
  }

  void cancelPressing(_) {
    _postPressTimer?.cancel();
    _postPressTimer = null;
    _updateIsPressing(false);
  }

  @override
  Widget build(BuildContext context) => Listener(
        onPointerDown: (_) {
          _postPressTimer = Timer(
            const Duration(milliseconds: 20),
            () => _updateIsPressing(true),
          );
        },
        onPointerMove: cancelPressing,
        onPointerUp: cancelPressing,
        child: GestureDetector(
          onTap: widget.onPressed,
          onLongPress: widget.onLongPressed,
          child: Container(
            padding: widget.padding,
            decoration: BoxDecoration(
              color: _backgroundColor,
              borderRadius: widget.borderRadius,
            ),
            child: widget.child,
          ),
        ),
      );
}
