import 'dart:io';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'dart:async';

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

Size getTextSize(String text, TextStyle textStyle) {
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

extension CompressedImage on Uint8List {
  Future<ByteData?> compressedImage(ImageByteFormat format) async {
    final ImmutableBuffer buffer = await ImmutableBuffer.fromUint8List(this);
    final Codec codec = await PaintingBinding.instance.instantiateImageCodecWithSize(buffer);
    final FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image.toByteData(format: format);
  }
}

extension CompressedImageFileGetter on File {
  Future<ByteData?> compressedImage(ImageByteFormat format) async {
    final ImmutableBuffer buffer = await ImmutableBuffer.fromFilePath(path);

    final Codec codec = await PaintingBinding.instance.instantiateImageCodecWithSize(buffer);
    final FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image.toByteData(format: format);
  }
}

extension CompressedImageAssetsGetter on String {
  Future<ByteData?> compressedImage(ImageByteFormat format) async {
    final ImmutableBuffer buffer = await ImmutableBuffer.fromAsset(this);

    final Codec codec = await PaintingBinding.instance.instantiateImageCodecWithSize(buffer);
    final FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image.toByteData(format: format);
  }
}

extension GetImageFromWidget on BuildContext {
  /// Layout at current context size and return the image.
  Future<ui.Image> toUiImage(
    Widget widget, {
    Duration delay = const Duration(seconds: 1),
    double? pixelRatio,
    Size? targetSize,
  }) async {
    Widget child = widget;
    BuildContext context = this;

    final FlutterView view = View.of(context);
    final double realPixelRatio = pixelRatio ?? view.devicePixelRatio;
    final Size realLogicalSize = targetSize ?? context.size ?? view.screenSize;

    ///
    ///Inherit Theme and MediaQuery of app
    ///
    child = InheritedTheme.captureAll(
      context,
      MediaQuery(data: MediaQueryData.fromView(view), child: Material(color: Colors.transparent, child: child)),
    );

    final RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();

    final RenderView renderView = RenderView(
      view: view,
      child: RenderPositionedBox(alignment: Alignment.center, child: repaintBoundary),
      configuration: ViewConfiguration(
        physicalConstraints: BoxConstraints.tight(realLogicalSize) * view.devicePixelRatio,
        logicalConstraints: BoxConstraints.tight(realLogicalSize),
        devicePixelRatio: realPixelRatio,
      ),
    );

    final PipelineOwner pipelineOwner = PipelineOwner();
    final BuildOwner buildOwner = BuildOwner(focusManager: FocusManager(), onBuildScheduled: () {});

    pipelineOwner.rootNode = renderView;
    renderView.prepareInitialFrame();

    final RenderObjectToWidgetElement<RenderBox> rootElement = RenderObjectToWidgetAdapter<RenderBox>(
        container: repaintBoundary,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: child,
        )).attachToRenderTree(buildOwner);
    ////
    ///Render Widget
    ///

    buildOwner.buildScope(rootElement);
    buildOwner.finalizeTree();

    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();

    ui.Image image = await repaintBoundary.toImage(pixelRatio: realPixelRatio);

    /// Dispose All widgets
    // rootElement.visitChildren((Element element) {
    //   rootElement.deactivateChild(element);
    // });
    buildOwner.finalizeTree();

    return image; // Adapted to directly return the image and not the Uint8List
  }
}

extension GetImageProviderFromUiImage on ui.Image {
  Future<ImageProvider?> imageProvider(ui.ImageByteFormat format) async {
    final ByteData? byteData = await toByteData(format: format);
    if (byteData == null) return null;
    return MemoryImage(byteData.buffer.asUint8List());
  }
}
