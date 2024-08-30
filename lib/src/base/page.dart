/// framework - page
/// Created by xhz on 8/30/24

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:framework/cupertino.dart';

class _DefaultBg extends StatelessWidget {
  const _DefaultBg();

  @override
  Widget build(BuildContext context) {
    final BoxDecoration decoration;
    decoration = BoxDecoration(color: CupertinoColors.systemBackground.resolveFrom(context));

    return Positioned.fill(child: DecoratedBox(decoration: decoration));
  }
}

void _handleStatusBarTap(BuildContext context) {
  final ScrollController? primaryScrollController = PrimaryScrollController.maybeOf(context);
  if (primaryScrollController != null && primaryScrollController.hasClients) {
    primaryScrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutCirc,
    );
  }
}

class CustomPage extends StatelessWidget {
  static const kNavigationBarHeight = 44.0;

  // 默认全自定义，不带特殊背景
  const CustomPage({
    super.key,
    required this.child,
    this.background,
    this.title,
    this.bodyPadding = EdgeInsets.zero,
  });

  // 带导航栏
  const CustomPage.withNavigationBar({
    super.key,
    required this.child,
    required this.title,
    this.bodyPadding = EdgeInsets.zero,
  })  : background = const _DefaultBg(),
        assert(title != null);

  final Widget child;
  final Widget? background;
  final String? title;
  final EdgeInsets bodyPadding;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;

    final top = MediaQuery.viewPaddingOf(context).top;
    EdgeInsets bodyPadding_ = bodyPadding + EdgeInsets.only(top: top);
    if (title != null) {
      bodyPadding_ = const EdgeInsets.only(top: kNavigationBarHeight) + bodyPadding_;
    }

    final canPop = ModalRoute.of(context)?.canPop == true;
    Widget backButton;

    if (canPop) {
      backButton = Positioned(
        top: top,
        left: 16,
        height: kNavigationBarHeight,
        child: CustomCupertinoButton(
          onTap: Navigator.of(context).pop,
          child: const Align(child: Icon(Icons.arrow_back_ios, size: 21)),
        ),
      );
    } else {
      backButton = const SizedBox();
    }

    return AnnotatedRegion(
      value: brightness == Brightness.dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: AnimatedDefaultTextStyle(
        style: Theme.of(context).textTheme.bodyMedium!,
        duration: kThemeChangeDuration,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (background != null) background!,
            Padding(padding: bodyPadding_, child: child),
            backButton,
            if (title != null)
              Positioned(
                top: top,
                left: 0,
                right: 0,
                height: kNavigationBarHeight,
                child: Align(
                  child: Text(
                    title!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: top,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _handleStatusBarTap(context),
                child: const SizedBox.expand(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
