import 'package:boxy/boxy.dart';
import 'dart:math' as math;
import 'package:flutter/rendering.dart';

/// read the father's constraints, and layout the child at the [originalSize],
/// but scale it to fit in the father's constraints according to the [alignment]
/// and [scaleLowerLimit] and [scaleUpperLimit]
class AutoFittedBoxyDelegate extends BoxyDelegate {
  AutoFittedBoxyDelegate({
    required this.originalSize,
    this.alignment = Alignment.center,
    this.scaleLowerLimit = 0.8,
    this.scaleUpperLimit = 1.2,
  });

  final Alignment alignment;
  Size originalSize;
  final double scaleUpperLimit;

  final double scaleLowerLimit;

  @override
  Size layout() {
    assert(children.length == 1);
    final child = children[0];
    final Size fatherSize = constraints.biggest;

    //按照原来的大小让子组件布局，得到应有的大小
    Size childSize = child.layout(BoxConstraints(maxWidth: originalSize.width, maxHeight: originalSize.height));

    //依据原来的大小，取长宽缩放的最小值计算出缩放比例，将constraints填满，同时不超过上下限
    final scale = math
        .min(fatherSize.width / child.size.width, fatherSize.height / child.size.height)
        .clamp(scaleLowerLimit, scaleUpperLimit);
    childSize *= scale;

    //将子组件放置到父视图对应的alignment位置
    final offset = alignment.inscribe(childSize, (Offset.zero & fatherSize)).topLeft;
    final matrix = Matrix4.translationValues(offset.dx, offset.dy, 0);

    //缩放子组件
    child.setTransform(matrix.scaled(scale, scale));

    //返回父组件的大小
    return fatherSize;
  }
}
