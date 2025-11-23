import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import '../yoga_ffi.dart';
import '../yoga_node.dart';
import '../yoga_value.dart';
import '../yoga_border.dart';

class YogaLayoutParentData extends ContainerBoxParentData<RenderBox> {
  YogaNode? yogaNode;

  // Cache for diffing
  double? flexGrow;
  double? flexShrink;
  double? flexBasis;
  YogaDisplay? display;
  YogaValue? width;
  YogaValue? height;
  YogaEdgeInsets? margin;
  YogaBorder? border;
  YogaBoxSizing? boxSizing;
  int? alignSelf;
  List<YogaBoxShadow>? boxShadow;

  // Effective margin after collapsing (runtime only, not set by user)
  EdgeInsets? effectiveMargin;

  // Border Image Runtime Data
  ImageStream? _borderImageStream;
  ImageInfo? _borderImageInfo;
  ImageStreamListener? _borderImageListener;

  @override
  String toString() => '${super.toString()}; yogaNode=$yogaNode';

  @override
  void detach() {
    _borderImageStream?.removeListener(_borderImageListener!);
    _borderImageStream = null;
    _borderImageListener = null;
    _borderImageInfo = null;
    super.detach();
  }
}

class RenderYogaLayout extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, YogaLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, YogaLayoutParentData> {
  late final YogaNode _rootNode;
  late final YogaConfig _config;
  bool _enableMarginCollapsing = false;
  YogaEdgeInsets? _padding;
  EdgeInsets _borderWidth = EdgeInsets.zero;
  YogaValue? _width;
  YogaValue? _height;

  RenderYogaLayout() {
    _config = YogaConfig();
    _rootNode = YogaNode();
    _rootNode.setConfig(_config);
  }

  YogaNode get rootNode => _rootNode;

  set width(YogaValue? value) {
    if (_width != value) {
      _width = value;
      markNeedsLayout();
    }
  }

  set height(YogaValue? value) {
    if (_height != value) {
      _height = value;
      markNeedsLayout();
    }
  }

  set useWebDefaults(bool value) {
    _config.useWebDefaults = value;
    markNeedsLayout();
  }

  set enableMarginCollapsing(bool value) {
    if (_enableMarginCollapsing != value) {
      _enableMarginCollapsing = value;
      markNeedsLayout();
    }
  }

  set padding(YogaEdgeInsets? value) {
    _padding = value;
    _applyPadding(_rootNode, value);
    markNeedsLayout();
  }

  set borderWidth(EdgeInsets? value) {
    // Deprecated or mapped to internal border logic if needed.
    // For now, we keep it for backward compatibility or remove it if we fully switch.
    // But RenderYogaLayout uses _borderWidth for collapsing logic on the root node.
    // The root node is configured by YogaLayout widget properties.
    // YogaLayout widget still has borderWidth property?
    // Let's check YogaLayout widget.
    _borderWidth = value ?? EdgeInsets.zero;
    if (value != null) {
      _rootNode.setBorder(YGEdge.left, value.left);
      _rootNode.setBorder(YGEdge.top, value.top);
      _rootNode.setBorder(YGEdge.right, value.right);
      _rootNode.setBorder(YGEdge.bottom, value.bottom);
    } else {
      _rootNode.setBorder(YGEdge.all, 0);
    }
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! YogaLayoutParentData) {
      child.parentData = YogaLayoutParentData();
    }
  }

  @override
  void insert(RenderBox child, {RenderBox? after}) {
    super.insert(child, after: after);
    final childParentData = child.parentData as YogaLayoutParentData;
    childParentData.yogaNode ??= YogaNode();
    final childNode = childParentData.yogaNode!;
    childNode.setConfig(_config);

    int index = 0;
    RenderBox? current = firstChild;
    while (current != null && current != child) {
      index++;
      current = (current.parentData as YogaLayoutParentData).nextSibling;
    }
    _rootNode.insertChild(childNode, index);
  }

  @override
  void remove(RenderBox child) {
    final childParentData = child.parentData as YogaLayoutParentData;
    if (childParentData.yogaNode != null) {
      _rootNode.removeChild(childParentData.yogaNode!);
    }
    super.remove(child);
  }

  @override
  void dispose() {
    _rootNode.dispose(recursive: false);
    _config.dispose();
    super.dispose();
  }

  @override
  void performLayout() {
    // 1. Sync Root Constraints
    if (_width != null) {
      _applyWidth(_rootNode, _width!);
    } else if (constraints.hasBoundedWidth) {
      _rootNode.width = constraints.maxWidth;
    } else {
      _rootNode.setWidthAuto();
    }

    if (_height != null) {
      _applyHeight(_rootNode, _height!);
    } else if (constraints.hasBoundedHeight) {
      _rootNode.height = constraints.maxHeight;
    } else {
      _rootNode.setHeightAuto();
    }

    // 2. Sync Children Size
    RenderBox? child = firstChild;
    while (child != null) {
      final childParentData = child.parentData as YogaLayoutParentData;
      final childNode = childParentData.yogaNode!;

      // Apply Border Widths to YogaNode
      double borderTop = 0;
      double borderRight = 0;
      double borderBottom = 0;
      double borderLeft = 0;

      if (childParentData.border != null) {
        // We assume LTR for now for layout purposes if direction is not available in context easily here?
        // Actually RenderBox has no directionality unless we look up.
        // But YogaNode needs physical edges.
        // Let's assume LTR for layout calculation or try to get direction.
        // In a real implementation we should pass direction to performLayout or store it.
        // For now, default to LTR.
        final resolvedBorder = childParentData.border!.resolve(
          TextDirection.ltr,
        );
        final flutterBorder = resolvedBorder.toFlutterBorder();

        borderTop = flutterBorder.top.width;
        borderRight = flutterBorder.right.width;
        borderBottom = flutterBorder.bottom.width;
        borderLeft = flutterBorder.left.width;

        childNode.setBorder(YGEdge.top, borderTop);
        childNode.setBorder(YGEdge.right, borderRight);
        childNode.setBorder(YGEdge.bottom, borderBottom);
        childNode.setBorder(YGEdge.left, borderLeft);
      } else {
        childNode.setBorder(YGEdge.all, 0);
      }

      // Apply Box Sizing (Content-Box adjustment)
      // Yoga defaults to Border-Box behavior (width specifies the node's total width).
      // If box-sizing is content-box, we need to add border width to the specified width.
      if (childParentData.boxSizing == YogaBoxSizing.contentBox) {
        if (childParentData.width != null &&
            childParentData.width!.unit == YogaUnit.point) {
          childNode.width =
              childParentData.width!.value + borderLeft + borderRight;
        }
        if (childParentData.height != null &&
            childParentData.height!.unit == YogaUnit.point) {
          childNode.height =
              childParentData.height!.value + borderTop + borderBottom;
        }
      } else {
        // Ensure we reset to original value if we switched back to border-box
        // or if we are just ensuring consistency.
        // However, YogaItem.applyParentData sets the value.
        // If we don't touch it here, it stays as set by YogaItem.
        // But if we previously set it to (width + border), and now we want (width),
        // we rely on YogaItem.applyParentData to have reset it?
        // No, applyParentData is only called when widget config changes.
        // If only layout happens (e.g. parent size change), applyParentData is NOT called.
        // So we MUST reset/re-apply the width from childParentData here to be safe,
        // OR ensure that we always set it.

        // To be safe and stateless, we should re-apply the width/height from parentData
        // if it is a fixed point value.
        if (childParentData.width != null &&
            childParentData.width!.unit == YogaUnit.point) {
          childNode.width = childParentData.width!.value;
        }
        if (childParentData.height != null &&
            childParentData.height!.unit == YogaUnit.point) {
          childNode.height = childParentData.height!.value;
        }
      }

      // If the user didn't specify an explicit size, we try to measure the child's content size
      // and set it on the Yoga node. This is a simplified "Auto" sizing.
      // Note: We must NOT overwrite width/height if width/height is set (unless it's auto).

      bool widthIsSet =
          childParentData.width != null &&
          childParentData.width!.unit != YogaUnit.auto &&
          childParentData.width!.unit != YogaUnit.undefined;
      bool heightIsSet =
          childParentData.height != null &&
          childParentData.height!.unit != YogaUnit.auto &&
          childParentData.height!.unit != YogaUnit.undefined;

      if (!widthIsSet || !heightIsSet) {
        final Size childSize = child.getDryLayout(const BoxConstraints());
        if (!widthIsSet) {
          childNode.width = childSize.width.ceilToDouble();
        }
        if (!heightIsSet) {
          childNode.height = childSize.height.ceilToDouble();
        }
      }

      child = childParentData.nextSibling;
    }

    if (_enableMarginCollapsing) {
      _collapseMarginsRecursive(this);
    } else {
      // Ensure margins are reset if collapsing is disabled
      _resetMarginsRecursive(this);
    }

    // 3. Calculate Layout
    _rootNode.calculateLayout(
      availableWidth: constraints.hasBoundedWidth
          ? constraints.maxWidth
          : double.nan,
      availableHeight: constraints.hasBoundedHeight
          ? constraints.maxHeight
          : double.nan,
    );

    // 4. Apply Layout to Children
    child = firstChild;
    while (child != null) {
      final childParentData = child.parentData as YogaLayoutParentData;
      final childNode = childParentData.yogaNode!;

      final double x = childNode.left;
      final double y = childNode.top;
      final double w = childNode.layoutWidth;
      final double h = childNode.layoutHeight;

      // Yoga might return NaN if something went wrong or if dimensions are undefined.
      // We must ensure we pass valid constraints to Flutter.
      final double safeW = w.isNaN ? 0.0 : w;
      final double safeH = h.isNaN ? 0.0 : h;

      // We must layout the child with exact constraints given by Yoga
      child.layout(
        BoxConstraints.tightFor(width: safeW, height: safeH),
        parentUsesSize: true,
      );
      childParentData.offset = Offset(x, y);

      child = childParentData.nextSibling;
    }

    final double rootW = _rootNode.layoutWidth;
    final double rootH = _rootNode.layoutHeight;

    size = constraints.constrain(
      Size(rootW.isNaN ? 0.0 : rootW, rootH.isNaN ? 0.0 : rootH),
    );
  }

  void _applyWidth(YogaNode node, YogaValue width) {
    switch (width.unit) {
      case YogaUnit.point:
        node.width = width.value;
        break;
      case YogaUnit.percent:
        node.setWidthPercent(width.value);
        break;
      case YogaUnit.auto:
        node.setWidthAuto();
        break;
      case YogaUnit.undefined:
        node.setWidthAuto();
        break;
    }
  }

  void _applyHeight(YogaNode node, YogaValue height) {
    switch (height.unit) {
      case YogaUnit.point:
        node.height = height.value;
        break;
      case YogaUnit.percent:
        node.setHeightPercent(height.value);
        break;
      case YogaUnit.auto:
        node.setHeightAuto();
        break;
      case YogaUnit.undefined:
        node.setHeightAuto();
        break;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    RenderBox? child = firstChild;
    while (child != null) {
      final childParentData = child.parentData as YogaLayoutParentData;

      // Paint shadow
      if (childParentData.boxShadow != null) {
        _paintShadows(
          context,
          offset + childParentData.offset,
          child.size,
          childParentData.boxShadow!,
        );
      }

      // Paint child
      context.paintChild(child, childParentData.offset + offset);

      // Paint border
      if (childParentData.border != null) {
        // Resolve border image if present (now that child has been laid out)
        if (childParentData.border!.image != null) {
          _resolveBorderImage(child, childParentData);
        }

        _paintBorder(
          context,
          offset + childParentData.offset,
          child.size,
          childParentData.border!,
          childParentData._borderImageInfo,
        );
      }

      child = childParentData.nextSibling;
    }
  }

  void _paintBorder(
    PaintingContext context,
    Offset offset,
    Size size,
    YogaBorder border,
    ImageInfo? borderImageInfo,
  ) {
    // Resolve border (assuming LTR for now, ideally pass TextDirection)
    final resolvedBorder = border.resolve(TextDirection.ltr);
    final flutterBorder = resolvedBorder.toFlutterBorder();
    final borderRadius = resolvedBorder.borderRadius;

    // Paint border image if available
    if (border.image != null && borderImageInfo != null) {
      _paintBorderImage(context, offset, size, border.image!, borderImageInfo);
      return; // If border image is painted, do we paint standard border? CSS says border-image replaces border-style.
    }

    // Paint border on top of child
    // Note: paintBorder paints inside the rect.
    // Since Yoga includes border in size, the child size includes the border area.
    // So painting inside (offset & size) is correct for border-box.

    if (borderRadius != BorderRadius.zero) {
      // If we have radius, we use paintBorder with radius
      flutterBorder.paint(
        context.canvas,
        offset & size,
        borderRadius: borderRadius,
      );
    } else {
      flutterBorder.paint(context.canvas, offset & size);
    }
  }

  void _paintBorderImage(
    PaintingContext context,
    Offset offset,
    Size size,
    YogaBorderImage borderImage,
    ImageInfo imageInfo,
  ) {
    final Rect rect = offset & size;
    final double imgW = imageInfo.image.width.toDouble();
    final double imgH = imageInfo.image.height.toDouble();

    // 1. Resolve Slices (Source)
    final double sliceL = _resolveValue(borderImage.slice.left, imgW);
    final double sliceT = _resolveValue(borderImage.slice.top, imgH);
    final double sliceR = _resolveValue(borderImage.slice.right, imgW);
    final double sliceB = _resolveValue(borderImage.slice.bottom, imgH);

    // 2. Resolve Outsets
    final double outsetL = _resolveValue(borderImage.outset.left, size.width);
    final double outsetT = _resolveValue(borderImage.outset.top, size.height);
    final double outsetR = _resolveValue(borderImage.outset.right, size.width);
    final double outsetB = _resolveValue(
      borderImage.outset.bottom,
      size.height,
    );

    final Rect destRect = Rect.fromLTRB(
      rect.left - outsetL,
      rect.top - outsetT,
      rect.right + outsetR,
      rect.bottom + outsetB,
    );

    // 3. Resolve Border Widths (Destination)
    // Use borderImage.width if available, otherwise fallback to slice size (common behavior if width not set)
    // or 0 if we want to be strict. For this implementation, we use the provided width or slice.
    double borderL = _resolveValue(
      borderImage.width?.left ?? YogaValue.point(sliceL),
      destRect.width,
    );
    double borderT = _resolveValue(
      borderImage.width?.top ?? YogaValue.point(sliceT),
      destRect.height,
    );
    double borderR = _resolveValue(
      borderImage.width?.right ?? YogaValue.point(sliceR),
      destRect.width,
    );
    double borderB = _resolveValue(
      borderImage.width?.bottom ?? YogaValue.point(sliceB),
      destRect.height,
    );

    // Source Rects
    final Rect srcTL = Rect.fromLTWH(0, 0, sliceL, sliceT);
    final Rect srcTR = Rect.fromLTWH(imgW - sliceR, 0, sliceR, sliceT);
    final Rect srcBL = Rect.fromLTWH(0, imgH - sliceB, sliceL, sliceB);
    final Rect srcBR = Rect.fromLTWH(
      imgW - sliceR,
      imgH - sliceB,
      sliceR,
      sliceB,
    );

    final Rect srcTop = Rect.fromLTWH(
      sliceL,
      0,
      imgW - sliceL - sliceR,
      sliceT,
    );
    final Rect srcBottom = Rect.fromLTWH(
      sliceL,
      imgH - sliceB,
      imgW - sliceL - sliceR,
      sliceB,
    );
    final Rect srcLeft = Rect.fromLTWH(
      0,
      sliceT,
      sliceL,
      imgH - sliceT - sliceB,
    );
    final Rect srcRight = Rect.fromLTWH(
      imgW - sliceR,
      sliceT,
      sliceR,
      imgH - sliceT - sliceB,
    );

    final Rect srcCenter = Rect.fromLTWH(
      sliceL,
      sliceT,
      imgW - sliceL - sliceR,
      imgH - sliceT - sliceB,
    );

    // Destination Rects
    final Rect dstTL = Rect.fromLTWH(
      destRect.left,
      destRect.top,
      borderL,
      borderT,
    );
    final Rect dstTR = Rect.fromLTWH(
      destRect.right - borderR,
      destRect.top,
      borderR,
      borderT,
    );
    final Rect dstBL = Rect.fromLTWH(
      destRect.left,
      destRect.bottom - borderB,
      borderL,
      borderB,
    );
    final Rect dstBR = Rect.fromLTWH(
      destRect.right - borderR,
      destRect.bottom - borderB,
      borderR,
      borderB,
    );

    final Rect dstTop = Rect.fromLTWH(
      destRect.left + borderL,
      destRect.top,
      math.max(0, destRect.width - borderL - borderR),
      borderT,
    );
    final Rect dstBottom = Rect.fromLTWH(
      destRect.left + borderL,
      destRect.bottom - borderB,
      math.max(0, destRect.width - borderL - borderR),
      borderB,
    );
    final Rect dstLeft = Rect.fromLTWH(
      destRect.left,
      destRect.top + borderT,
      borderL,
      math.max(0, destRect.height - borderT - borderB),
    );
    final Rect dstRight = Rect.fromLTWH(
      destRect.right - borderR,
      destRect.top + borderT,
      borderR,
      math.max(0, destRect.height - borderT - borderB),
    );

    final Rect dstCenter = Rect.fromLTWH(
      destRect.left + borderL,
      destRect.top + borderT,
      math.max(0, destRect.width - borderL - borderR),
      math.max(0, destRect.height - borderT - borderB),
    );

    final Paint paint = Paint();
    final Canvas canvas = context.canvas;

    // Draw Corners (Always stretch/scale to fit corner box)
    if (!dstTL.isEmpty && !srcTL.isEmpty) {
      canvas.drawImageRect(imageInfo.image, srcTL, dstTL, paint);
    }
    if (!dstTR.isEmpty && !srcTR.isEmpty) {
      canvas.drawImageRect(imageInfo.image, srcTR, dstTR, paint);
    }
    if (!dstBL.isEmpty && !srcBL.isEmpty) {
      canvas.drawImageRect(imageInfo.image, srcBL, dstBL, paint);
    }
    if (!dstBR.isEmpty && !srcBR.isEmpty) {
      canvas.drawImageRect(imageInfo.image, srcBR, dstBR, paint);
    }

    // Draw Edges
    _drawTile(
      canvas,
      imageInfo.image,
      srcTop,
      dstTop,
      borderImage.repeat,
      isHorizontal: true,
    );
    _drawTile(
      canvas,
      imageInfo.image,
      srcBottom,
      dstBottom,
      borderImage.repeat,
      isHorizontal: true,
    );
    _drawTile(
      canvas,
      imageInfo.image,
      srcLeft,
      dstLeft,
      borderImage.repeat,
      isHorizontal: false,
    );
    _drawTile(
      canvas,
      imageInfo.image,
      srcRight,
      dstRight,
      borderImage.repeat,
      isHorizontal: false,
    );

    // Draw Center
    if (borderImage.fill) {
      // For center, we should ideally tile in both directions.
      // For now, let's just stretch or simple tile.
      // Implementing full 2D tiling for center is complex and rarely used with complex repeats.
      // Let's use stretch for center if fill is true, or simple stretch.
      // Or reuse _drawTile logic but it's 1D.
      // Let's just stretch center for now as a simplification, or use paintImage.
      if (!dstCenter.isEmpty && !srcCenter.isEmpty) {
        canvas.drawImageRect(imageInfo.image, srcCenter, dstCenter, paint);
      }
    }
  }

  void _drawTile(
    Canvas canvas,
    ui.Image image,
    Rect src,
    Rect dst,
    YogaBorderImageRepeat repeat, {
    required bool isHorizontal,
  }) {
    if (dst.isEmpty || src.isEmpty) return;

    if (repeat == YogaBorderImageRepeat.stretch) {
      canvas.drawImageRect(image, src, dst, Paint());
      return;
    }

    canvas.save();
    canvas.clipRect(dst);

    final double srcW = src.width;
    final double srcH = src.height;
    final double dstW = dst.width;
    final double dstH = dst.height;

    if (repeat == YogaBorderImageRepeat.round) {
      if (isHorizontal) {
        double count = (dstW / srcW).roundToDouble();
        if (count < 1) count = 1;
        double tileW = dstW / count;
        for (int i = 0; i < count; i++) {
          canvas.drawImageRect(
            image,
            src,
            Rect.fromLTWH(dst.left + i * tileW, dst.top, tileW, dstH),
            Paint(),
          );
        }
      } else {
        double count = (dstH / srcH).roundToDouble();
        if (count < 1) count = 1;
        double tileH = dstH / count;
        for (int i = 0; i < count; i++) {
          canvas.drawImageRect(
            image,
            src,
            Rect.fromLTWH(dst.left, dst.top + i * tileH, dstW, tileH),
            Paint(),
          );
        }
      }
    } else if (repeat == YogaBorderImageRepeat.repeat) {
      // Centered tiling
      if (isHorizontal) {
        double x = dst.center.dx - srcW / 2;
        // Draw center one
        canvas.drawImageRect(
          image,
          src,
          Rect.fromLTWH(x, dst.top, srcW, dstH),
          Paint(),
        );

        // Draw left
        double currX = x - srcW;
        while (currX + srcW > dst.left) {
          canvas.drawImageRect(
            image,
            src,
            Rect.fromLTWH(currX, dst.top, srcW, dstH),
            Paint(),
          );
          currX -= srcW;
        }

        // Draw right
        currX = x + srcW;
        while (currX < dst.right) {
          canvas.drawImageRect(
            image,
            src,
            Rect.fromLTWH(currX, dst.top, srcW, dstH),
            Paint(),
          );
          currX += srcW;
        }
      } else {
        // Vertical centered tiling
        double y = dst.center.dy - srcH / 2;
        canvas.drawImageRect(
          image,
          src,
          Rect.fromLTWH(dst.left, y, dstW, srcH),
          Paint(),
        );

        // Draw up
        double currY = y - srcH;
        while (currY + srcH > dst.top) {
          canvas.drawImageRect(
            image,
            src,
            Rect.fromLTWH(dst.left, currY, dstW, srcH),
            Paint(),
          );
          currY -= srcH;
        }

        // Draw down
        currY = y + srcH;
        while (currY < dst.bottom) {
          canvas.drawImageRect(
            image,
            src,
            Rect.fromLTWH(dst.left, currY, dstW, srcH),
            Paint(),
          );
          currY += srcH;
        }
      }
    } else {
      // Space or others, fallback to stretch
      canvas.drawImageRect(image, src, dst, Paint());
    }

    canvas.restore();
  }

  void _resolveBorderImage(
    RenderBox child,
    YogaLayoutParentData childParentData,
  ) {
    final borderImage = childParentData.border?.image;
    if (borderImage == null) {
      _disposeBorderImage(childParentData);
      return;
    }

    final ImageConfiguration config = ImageConfiguration(
      size: child.size,
      textDirection: TextDirection.ltr,
    );
    final ImageStream newStream = borderImage.source.resolve(config);

    if (newStream.key != childParentData._borderImageStream?.key) {
      _disposeBorderImage(childParentData);
      childParentData._borderImageStream = newStream;
      childParentData._borderImageListener = ImageStreamListener((
        ImageInfo imageInfo,
        bool synchronousCall,
      ) {
        childParentData._borderImageInfo = imageInfo;
        markNeedsPaint();
      });
      newStream.addListener(childParentData._borderImageListener!);
    }
  }

  void _disposeBorderImage(YogaLayoutParentData childParentData) {
    if (childParentData._borderImageStream != null) {
      childParentData._borderImageStream!.removeListener(
        childParentData._borderImageListener!,
      );
      childParentData._borderImageStream = null;
      childParentData._borderImageListener = null;
      childParentData._borderImageInfo = null;
    }
  }

  void _paintShadows(
    PaintingContext context,
    Offset offset,
    Size size,
    List<YogaBoxShadow> shadows,
  ) {
    for (int i = shadows.length - 1; i >= 0; i--) {
      final shadow = shadows[i];
      final Paint paint = Paint()
        ..color = shadow.color
        ..maskFilter = MaskFilter.blur(
          shadow.blurStyle,
          _resolveValue(shadow.blurRadius, size.width),
        );

      final double dx = _resolveValue(shadow.offsetDX, size.width);
      final double dy = _resolveValue(shadow.offsetDY, size.height);
      final double spread = _resolveValue(shadow.spreadRadius, size.width);

      final Rect rect = (offset & size).inflate(spread).shift(Offset(dx, dy));

      // We assume rectangular shadow for now as YogaItem doesn't know about borderRadius.
      // If we want rounded shadows, we need to add borderRadius to YogaItem.
      context.canvas.drawRect(rect, paint);
    }
  }

  double _resolveValue(YogaValue value, double base) {
    switch (value.unit) {
      case YogaUnit.point:
        return value.value;
      case YogaUnit.percent:
        return value.value * base / 100.0;
      case YogaUnit.auto:
      case YogaUnit.undefined:
        return 0;
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  void _resetMarginsRecursive(RenderYogaLayout renderLayout) {
    RenderBox? child = renderLayout.firstChild;
    while (child != null) {
      final childParentData = child.parentData as YogaLayoutParentData;
      // Reset effective margin
      childParentData.effectiveMargin = null;

      if (childParentData.yogaNode != null) {
        _resetMargins(childParentData.yogaNode!, childParentData.margin);
      }

      if (child is RenderYogaLayout) {
        _resetMarginsRecursive(child);
      }
      child = childParentData.nextSibling;
    }
  }

  void _resetMargins(YogaNode node, YogaEdgeInsets? margin) {
    _setMarginEdge(node, YGEdge.left, margin?.left);
    _setMarginEdge(node, YGEdge.top, margin?.top);
    _setMarginEdge(node, YGEdge.right, margin?.right);
    _setMarginEdge(node, YGEdge.bottom, margin?.bottom);
  }

  void _setMarginEdge(YogaNode node, int edge, YogaValue? value) {
    if (value == null) {
      node.setMargin(edge, 0);
      return;
    }
    switch (value.unit) {
      case YogaUnit.point:
        node.setMargin(edge, value.value);
        break;
      case YogaUnit.percent:
        node.setMarginPercent(edge, value.value);
        break;
      case YogaUnit.auto:
        node.setMarginAuto(edge);
        break;
      case YogaUnit.undefined:
        node.setMargin(edge, 0);
        break;
    }
  }

  void _collapseMarginsRecursive(RenderYogaLayout renderLayout) {
    // 1. Recurse first (Post-order traversal)
    RenderBox? child = renderLayout.firstChild;
    while (child != null) {
      final childParentData = child.parentData as YogaLayoutParentData;

      // Reset margins for this child
      childParentData.effectiveMargin = null;
      if (childParentData.yogaNode != null) {
        _resetMargins(childParentData.yogaNode!, childParentData.margin);
      }

      if (child is RenderYogaLayout) {
        _collapseMarginsRecursive(child);
      }
      child = childParentData.nextSibling;
    }

    // 2. Apply Sibling Collapsing (My children)
    renderLayout._applySiblingCollapsing();

    // 3. Apply Parent-Child Collapsing (Me and my children)
    renderLayout._applyParentChildCollapsing();
  }

  EdgeInsets _getEffectiveMargin(YogaLayoutParentData pd) {
    // Convert YogaEdgeInsets to EdgeInsets for calculation if possible
    // Note: We can only collapse point values in Dart.
    // If margin is percent, we can't easily collapse it here without knowing parent width.
    // So we fallback to 0 or whatever is safe.

    // If effectiveMargin is set, use it.
    if (pd.effectiveMargin != null) return pd.effectiveMargin!;

    // Otherwise convert pd.margin
    final margin = pd.margin;
    if (margin == null) return EdgeInsets.zero;

    return EdgeInsets.only(
      left: margin.left.unit == YogaUnit.point ? margin.left.value : 0,
      top: margin.top.unit == YogaUnit.point ? margin.top.value : 0,
      right: margin.right.unit == YogaUnit.point ? margin.right.value : 0,
      bottom: margin.bottom.unit == YogaUnit.point ? margin.bottom.value : 0,
    );
  }

  void _updateEffectiveMargin(YogaLayoutParentData pd, int edge, double value) {
    EdgeInsets current = _getEffectiveMargin(pd);
    if (edge == YGEdge.top) {
      pd.effectiveMargin = current.copyWith(top: value);
    } else if (edge == YGEdge.bottom) {
      pd.effectiveMargin = current.copyWith(bottom: value);
    }
  }

  void _applySiblingCollapsing() {
    // Margin collapsing only applies to vertical flow (column/column-reverse)
    final flexDirection = _rootNode.flexDirection;
    if (flexDirection != YGFlexDirection.column) {
      return;
    }

    RenderBox? child = firstChild;
    while (child != null) {
      final childParentData = child.parentData as YogaLayoutParentData;
      final nextChild = childParentData.nextSibling;

      if (nextChild != null) {
        final nextParentData = nextChild.parentData as YogaLayoutParentData;

        final childNode = childParentData.yogaNode!;
        final nextNode = nextParentData.yogaNode!;

        // Skip collapsing if either margin is percentage-based
        if ((childParentData.margin?.bottom.unit == YogaUnit.percent) ||
            (nextParentData.margin?.top.unit == YogaUnit.percent)) {
          child = nextChild;
          continue;
        }

        // Get effective margins
        final marginBottom = _getEffectiveMargin(childParentData).bottom;
        final marginTop = _getEffectiveMargin(nextParentData).top;

        // Calculate collapsed margin
        final collapsedMargin = _collapse(marginBottom, marginTop);

        // Apply to nodes and update effective margins
        childNode.setMargin(YGEdge.bottom, collapsedMargin);
        _updateEffectiveMargin(childParentData, YGEdge.bottom, collapsedMargin);

        nextNode.setMargin(YGEdge.top, 0);
        _updateEffectiveMargin(nextParentData, YGEdge.top, 0);
      }

      child = nextChild;
    }
  }

  void _applyParentChildCollapsing() {
    final flexDirection = _rootNode.flexDirection;
    if (flexDirection != YGFlexDirection.column) {
      return;
    }

    // Top Collapsing
    if (_isZero(_padding?.top) && _borderWidth.top == 0) {
      final firstChild = this.firstChild;
      if (firstChild != null) {
        final childParentData = firstChild.parentData as YogaLayoutParentData;
        final childNode = childParentData.yogaNode!;

        // Skip if child has percentage top margin
        if (childParentData.margin?.top.unit == YogaUnit.percent) {
          // Do nothing
        } else {
          // My top margin
          double myMarginTop = 0.0;
          bool myMarginIsPercent = false;
          if (parentData is YogaLayoutParentData) {
            final pd = parentData as YogaLayoutParentData;
            myMarginTop = _getEffectiveMargin(pd).top;
            if (pd.margin?.top.unit == YogaUnit.percent) {
              myMarginIsPercent = true;
            }
          }

          if (!myMarginIsPercent) {
            final childMarginTop = _getEffectiveMargin(childParentData).top;

            final collapsed = _collapse(myMarginTop, childMarginTop);

            _rootNode.setMargin(YGEdge.top, collapsed);
            if (parentData is YogaLayoutParentData) {
              _updateEffectiveMargin(
                parentData as YogaLayoutParentData,
                YGEdge.top,
                collapsed,
              );
            }

            childNode.setMargin(YGEdge.top, 0);
            _updateEffectiveMargin(childParentData, YGEdge.top, 0);
          }
        }
      }
    }

    // Bottom Collapsing
    if (!constraints.hasBoundedHeight &&
        _isZero(_padding?.bottom) &&
        _borderWidth.bottom == 0) {
      final lastChild = this.lastChild;
      if (lastChild != null) {
        final childParentData = lastChild.parentData as YogaLayoutParentData;
        final childNode = childParentData.yogaNode!;

        // Skip if child has percentage bottom margin
        if (childParentData.margin?.bottom.unit == YogaUnit.percent) {
          // Do nothing
        } else {
          double myMarginBottom = 0.0;
          bool myMarginIsPercent = false;
          if (parentData is YogaLayoutParentData) {
            final pd = parentData as YogaLayoutParentData;
            myMarginBottom = _getEffectiveMargin(pd).bottom;
            if (pd.margin?.bottom.unit == YogaUnit.percent) {
              myMarginIsPercent = true;
            }
          }

          if (!myMarginIsPercent) {
            final childMarginBottom = _getEffectiveMargin(
              childParentData,
            ).bottom;

            final collapsed = _collapse(myMarginBottom, childMarginBottom);

            _rootNode.setMargin(YGEdge.bottom, collapsed);
            if (parentData is YogaLayoutParentData) {
              _updateEffectiveMargin(
                parentData as YogaLayoutParentData,
                YGEdge.bottom,
                collapsed,
              );
            }

            childNode.setMargin(YGEdge.bottom, 0);
            _updateEffectiveMargin(childParentData, YGEdge.bottom, 0);
          }
        }
      }
    }
  }

  void _applyPadding(YogaNode node, YogaEdgeInsets? padding) {
    _setPaddingEdge(node, YGEdge.left, padding?.left);
    _setPaddingEdge(node, YGEdge.top, padding?.top);
    _setPaddingEdge(node, YGEdge.right, padding?.right);
    _setPaddingEdge(node, YGEdge.bottom, padding?.bottom);
  }

  void _setPaddingEdge(YogaNode node, int edge, YogaValue? value) {
    if (value == null) {
      node.setPadding(edge, 0);
      return;
    }
    switch (value.unit) {
      case YogaUnit.point:
        node.setPadding(edge, value.value);
        break;
      case YogaUnit.percent:
        node.setPaddingPercent(edge, value.value);
        break;
      case YogaUnit.auto:
        // Padding auto is not really a thing in CSS/Yoga usually, treats as 0?
        // Yoga doesn't have setPaddingAuto.
        node.setPadding(edge, 0);
        break;
      case YogaUnit.undefined:
        node.setPadding(edge, 0);
        break;
    }
  }

  bool _isZero(YogaValue? value) {
    if (value == null) return true;
    if (value.unit == YogaUnit.point && value.value == 0) return true;
    if (value.unit == YogaUnit.percent && value.value == 0) return true;
    return false;
  }

  double _collapse(double m1, double m2) {
    if (m1 >= 0 && m2 >= 0) {
      // Both positive: max
      return math.max(m1, m2);
    } else if (m1 < 0 && m2 < 0) {
      // Both negative: min (most negative)
      return math.min(m1, m2);
    } else {
      // One positive, one negative: sum
      return m1 + m2;
    }
  }
}
