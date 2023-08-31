part of 'context_menu.dart';

extension on GlobalKey {
  Rect get _globalRect {
    assert(currentContext != null);
    final RenderBox renderBoxContainer = currentContext!.findRenderObject()! as RenderBox;
    return Rect.fromPoints(
        renderBoxContainer.localToGlobal(
          renderBoxContainer.paintBounds.topLeft,
        ),
        renderBoxContainer.localToGlobal(renderBoxContainer.paintBounds.bottomRight));
  }
}

bool _menuPositionIsBelow(Rect childRect, EdgeInsets padding, Size screenSize) {
  final availableHeight = screenSize.height - padding.bottom - padding.top;
  if (childRect.height > (availableHeight / 2)) {
    // 如果child高度大于高度的一半，直接放在child下面
    return true;
  }
  final double spaceBelow = screenSize.height - padding.bottom - childRect.bottom;
  final double spaceAbove = childRect.top - padding.top;
  return spaceBelow > spaceAbove;
}

(double, double) _getMenuOrigin(Rect childRect, Size menuSize, EdgeInsets padding, Size screenSize) {
  // 根据剩余空间将menu布置到child下/上面+_ContextMenuRouteStaticState._kPadding，位置居中
  final bool isBelow = _menuPositionIsBelow(childRect, padding, screenSize);
  final menuOriginY = isBelow
      ? childRect.bottom + _ContextMenuRouteStaticState._kPadding
      : childRect.top - menuSize.height - _ContextMenuRouteStaticState._kPadding;
  final menuOriginX = childRect.left + childRect.width / 2 - menuSize.width / 2;
  return (menuOriginX, menuOriginY);
}

class _ContextMenuLayoutDelegate extends BoxyDelegate {
  _ContextMenuLayoutDelegate({
    required this.childGlobalRect,
    required this.maxScale,
    required this.padding,
    required this.screenSize,
  });

  final Rect childGlobalRect;

  final double maxScale;

  EdgeInsets padding;
  Size screenSize;

  @override
  Size layout() {
    final child = children[0];
    final menu = children[1];
    final childLocalOrigin = childGlobalRect.topLeft.translate(0, -padding.top);
    final fatherSize = constraints.biggest;
    final double maxHeight = fatherSize.height;
    final double maxWidth = fatherSize.width;
    // 限制大小
    final childWidth = childGlobalRect.width;
    final childHeight = childGlobalRect.height;

    // 待定
    final Offset childOrigin;
    final double menuOriginY;
    final double menuOriginX;
    // 计算menu大小
    final menuSize = menu.layout(BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight));
    Size childSize = child.layout(BoxConstraints(maxWidth: childWidth, maxHeight: childHeight));

    final Matrix4 childTransform;

    // 拉伸child大小
    final childLimitWidth = math.min(maxWidth - 36, childGlobalRect.width * maxScale);
    final childLimitHeight = math.min(maxHeight, childGlobalRect.height * maxScale);
    final childScale = math.min(childLimitWidth / childSize.width, childLimitHeight / childSize.height);
    childSize *= childScale;

    /// 1. 超出屏幕，缩放child到合适大小
    /// 2. 被屏幕边缘遮挡，不需要缩放，origin延用之前的rect中心，clamp到屏幕边缘
    /// 3. 正常情况，没有超出就延用之前的rect的y坐标，x居中
    final bool overflow = (childSize.height + menuSize.height + _ContextMenuRouteStaticState._kPadding) > maxHeight;
    if (overflow) {
      final double scale = (maxHeight - menuSize.height - _ContextMenuRouteStaticState._kPadding) / childSize.height;
      childSize = childSize * scale;
      // 超出就使用constraints原点
      childOrigin = Offset(fatherSize.width / 2 - childSize.width / 2, 0);
      // 设置child的位置
      childTransform = Matrix4.translationValues(childOrigin.dx, childOrigin.dy, 0);
      childTransform.scale(scale * childScale, scale * childScale);
    } else if (
        // 条件1，整体底部超出safeArea（以global为坐标系）
        (childGlobalRect.bottom + _ContextMenuRouteStaticState._kPadding + menuSize.height) >
                (screenSize.height - padding.bottom) ||
            // 条件2，child顶部超出safeArea
            childLocalOrigin.dy < 0) {
      childOrigin = Offset(
        maxWidth / 2 - childSize.width / 2,
        // *整体*限制在0~maxHeight
        childLocalOrigin.dy
            .clamp(0, maxHeight - childSize.height - menuSize.height - _ContextMenuRouteStaticState._kPadding),
      );
      childTransform = Matrix4.translationValues(childOrigin.dx, childOrigin.dy, 0);
      childTransform.scale(childScale, childScale);
    } else {
      childOrigin = Offset(
        maxWidth / 2 - childSize.width / 2,
        childLocalOrigin.dy + childGlobalRect.height / 2 - childSize.height / 2,
      );
      childTransform = Matrix4.translationValues(childOrigin.dx, childOrigin.dy, 0);
      childTransform.scale(childScale, childScale);
    }

    (menuOriginX, menuOriginY) = _getMenuOrigin(childOrigin & childSize, menuSize, padding, screenSize);
    final menuTransform = Matrix4.translationValues(menuOriginX, menuOriginY, 0);

    // 设置位置
    menu.setTransform(menuTransform);
    child.setTransform(childTransform);

    return fatherSize;
  }
}
