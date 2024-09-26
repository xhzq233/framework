/// EcsMerchantApp - text_button
/// Created by xhz on 8/21/24

import 'package:flutter/material.dart';

import '../../cupertino.dart';

enum EMTextButtonStyle {
  primary,
  onPrimary,
  secondary;

  Color fillColor(ThemeData theme) {
    switch (this) {
      case EMTextButtonStyle.primary:
        return theme.colorScheme.primary;
      case EMTextButtonStyle.secondary:
        return theme.colorScheme.secondary;
      case EMTextButtonStyle.onPrimary:
        return theme.colorScheme.onPrimary;
    }
  }

  Color textColor(ThemeData theme) {
    switch (this) {
      case EMTextButtonStyle.primary:
        return theme.colorScheme.onPrimary;
      case EMTextButtonStyle.secondary:
        return theme.colorScheme.onSurface;
      case EMTextButtonStyle.onPrimary:
        return theme.colorScheme.primary;
    }
  }
}

enum EMTextButtonSize {
  large(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 13), radius: 8, minWidth: 184, textSize: 17),
  medium(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10.5), radius: 6, minWidth: 120, textSize: 15),
  small(padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12), radius: 6, textSize: 14, minWidth: 80),
  navigationBarItem(padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12), radius: 6, textSize: 14, minWidth: 52),
  ;

  const EMTextButtonSize({
    required this.padding,
    required this.radius,
    required this.minWidth,
    required this.textSize,
  });

  final EdgeInsets padding;
  final double radius;
  final double minWidth;
  final double textSize;
}

class EMTextButton extends StatelessWidget {
  const EMTextButton({
    super.key,
    this.onPressed,
    required this.title,
    this.style = EMTextButtonStyle.primary,
    this.size = EMTextButtonSize.large,
  });

  final VoidCallback? onPressed;

  final String title;

  final EMTextButtonStyle style;

  final EMTextButtonSize size;

  @override
  Widget build(BuildContext context) {
    const defaultStyle = TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.w500);
    final ThemeData theme = Theme.of(context);
    final enable = onPressed != null;
    final textStyle = defaultStyle.copyWith(
      fontSize: size.textSize,
      color: enable ? style.textColor(theme) : const Color(0x26000000),
    );

    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: size.minWidth),
      child: CustomCupertinoButton(
        onTap: onPressed,
        disabledOpacity: 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: enable ? style.fillColor(theme) : const Color(0x0D000000),
            borderRadius: BorderRadius.all(Radius.circular(size.radius)),
          ),
          child: Padding(
            padding: size.padding,
            child: Align(
              widthFactor: 1,
              heightFactor: 1,
              child: Text(
                title,
                style: textStyle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
