import 'package:flutter/cupertino.dart';

mixin CupertinoTransitionWithoutPopGesture {
  static Widget buildPageTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return CupertinoPageTransition(
      primaryRouteAnimation: animation,
      secondaryRouteAnimation: secondaryAnimation,
      linearTransition: false,
      child: child,
    );
  }
}

class CupertinoPageRouteWithoutPopGesture extends PageRoute {
  CupertinoPageRouteWithoutPopGesture({required this.builder, super.settings});

  final WidgetBuilder builder;

  @override
  bool get maintainState => true;

  @override
  Color? get barrierColor => fullscreenDialog ? null : const Color(0x18000000);

  @override
  String? get barrierLabel => null;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 500);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    final Widget child = builder(context);
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: child,
    );
  }

  @override
  Widget buildTransitions(
      BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return CupertinoTransitionWithoutPopGesture.buildPageTransitions(
      this,
      context,
      animation,
      secondaryAnimation,
      child,
    );
  }
}
