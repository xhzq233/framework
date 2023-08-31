import 'dart:ui';

import 'package:flutter/widgets.dart';

import '../../logger/logger.dart';

extension GetRectOnRenderBox on GlobalKey {
  Rect get globalRect {
    assert(currentContext != null);
    final RenderBox renderBoxContainer = currentContext!.findRenderObject()! as RenderBox;
    return Rect.fromPoints(
        renderBoxContainer.localToGlobal(
          renderBoxContainer.paintBounds.topLeft,
        ),
        renderBoxContainer.localToGlobal(renderBoxContainer.paintBounds.bottomRight));
  }
}

Color colorFromHex(String hexString) {
  try {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  } catch (e, s) {
    logger.e('color', 'parse color error $hexString', e, s);
    return const Color(0x00000000);
  }
}

Size getTextSize(String text, TextStyle textStyle, BuildContext context) {
  return (TextPainter(
    text: TextSpan(text: text, style: textStyle),
    textDirection: TextDirection.ltr,
    maxLines: 1,
  )..layout())
      .size;
}

extension FlutterViewExt on FlutterView {
  EdgeInsets get realPadding => EdgeInsets.fromViewPadding(
        padding,
        devicePixelRatio,
      );

  Size get screenSize => physicalSize / devicePixelRatio;
}

// for debug purposes
extension WidgetExtensions on Widget {
  Widget onTap(void Function() function) => GestureDetector(
        onTap: function,
        child: this,
      );

  Widget centralized() => Center(
        child: this,
      );

  Widget decorated(BoxDecoration boxDecoration) => DecoratedBox(
        decoration: boxDecoration,
        child: this,
      );

  Widget sized({double? width, double? height}) => SizedBox(
        width: width,
        height: height,
        child: this,
      );

  Widget border({
    EdgeInsets? margin,
    EdgeInsets? padding,
    Color color = const Color(0xFF448AFF),
  }) =>
      Container(
        margin: margin,
        padding: padding,
        decoration: BoxDecoration(border: Border.all(color: color, width: 0.5)),
        child: this,
      );

  Widget clipped([BorderRadius borderRadius = BorderRadius.zero]) => ClipRRect(
        borderRadius: borderRadius,
        child: this,
      );

  Widget unconstrained() => UnconstrainedBox(
        child: this,
      );
}
