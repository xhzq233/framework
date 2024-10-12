/// framework - custom_child_layout
/// Created by xhz on 10/11/24

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Expand child's overlay area, surrounding parent.
/// The first child is the parent, the second child is the overlay.
/// The overlay layout at the specified [offset] and [alignment].
class SurroundingOverlay extends MultiChildRenderObjectWidget {
  const SurroundingOverlay({
    super.key,
    this.offset = Offset.zero,
    this.alignment = Alignment.center,
    required super.children,
  }) : assert(children.length == 2, 'SurroundingPosition should have exactly 2 children.');

  final Offset offset;
  final Alignment alignment;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderSurroundingPositionBox(alignment, offset);
  }

  @override
  void updateRenderObject(BuildContext context, covariant RenderObject renderObject) {
    (renderObject as _RenderSurroundingPositionBox)
      ..alignment = alignment
      ..offset = offset;
  }
}

class _SurroundingPositionParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderSurroundingPositionBox extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _SurroundingPositionParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _SurroundingPositionParentData> {
  _RenderSurroundingPositionBox(this._alignment, this._offset);

  Offset _offset;

  set offset(Offset value) {
    if (_offset == value) {
      return;
    }
    _offset = value;
    markNeedsLayout();
  }

  Alignment _alignment;

  set alignment(Alignment value) {
    if (_alignment == value) {
      return;
    }
    _alignment = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _SurroundingPositionParentData) {
      child.parentData = _SurroundingPositionParentData();
    }
  }

  @override
  void performLayout() {
    final RenderBox? parent = firstChild;
    final RenderBox? child = lastChild;
    if (parent == null || child == null) {
      size = Size.zero;
      return;
    }
    parent.layout(constraints, parentUsesSize: true);
    final parentSize = parent.size;
    size = parentSize;
    child.layout(constraints, parentUsesSize: true);
    final childSize = child.size;
    final alignRect = Rect.fromLTRB(
        -childSize.width, -childSize.height, parentSize.width + childSize.width, parentSize.height + childSize.height);
    (child.parentData as _SurroundingPositionParentData).offset =
        _offset + _alignment.inscribe(childSize, alignRect).topLeft;
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return firstChild?.getDryLayout(constraints) ?? Size.zero;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}
