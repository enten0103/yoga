import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// 尺寸定义
abstract class HtmlSize {
  const HtmlSize();
}

class FixedSize extends HtmlSize {
  final double value;
  const FixedSize(this.value);
}

class PercentSize extends HtmlSize {
  final double value;
  const PercentSize(this.value);
}

class MaxContent extends HtmlSize {
  const MaxContent();
}

class MinContent extends HtmlSize {
  const MinContent();
}

class FitContent extends HtmlSize {
  const FitContent();
}

class AutoSize extends HtmlSize {
  const AutoSize();
}

// Border 定义
enum HtmlBoxSizing { borderBox, contentBox }

enum HtmlBorderStyle { hidden, dotted, dashed, solid, double }

abstract class HtmlBorderWidth {
  const HtmlBorderWidth();
}

class FixedBorderWidth extends HtmlBorderWidth {
  final double value;
  const FixedBorderWidth(this.value);
}

class PercentBorderWidth extends HtmlBorderWidth {
  final double value;
  const PercentBorderWidth(this.value);
}

enum BorderWidthKeyword { thin, medium, thick }

class KeywordBorderWidth extends HtmlBorderWidth {
  final BorderWidthKeyword keyword;
  const KeywordBorderWidth(this.keyword);
}

class HtmlBorderSide {
  final HtmlBorderWidth width;
  final HtmlBorderStyle style;
  final Color color;

  const HtmlBorderSide({
    this.width = const KeywordBorderWidth(BorderWidthKeyword.medium),
    this.style = HtmlBorderStyle.solid,
    this.color = const Color(0xFF000000),
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HtmlBorderSide &&
        other.width == width &&
        other.style == style &&
        other.color == color;
  }

  @override
  int get hashCode => Object.hash(width, style, color);
}

class HtmlBorder {
  final HtmlBorderSide top;
  final HtmlBorderSide right;
  final HtmlBorderSide bottom;
  final HtmlBorderSide left;

  const HtmlBorder({
    this.top = const HtmlBorderSide(style: HtmlBorderStyle.hidden),
    this.right = const HtmlBorderSide(style: HtmlBorderStyle.hidden),
    this.bottom = const HtmlBorderSide(style: HtmlBorderStyle.hidden),
    this.left = const HtmlBorderSide(style: HtmlBorderStyle.hidden),
    D,
  });

  factory HtmlBorder.all({
    HtmlBorderWidth width = const KeywordBorderWidth(BorderWidthKeyword.medium),
    HtmlBorderStyle style = HtmlBorderStyle.solid,
    Color color = const Color(0xFF000000),
  }) {
    final side = HtmlBorderSide(width: width, style: style, color: color);
    return HtmlBorder(top: side, right: side, bottom: side, left: side);
  }

  bool get isUniform => top == right && right == bottom && bottom == left;
}

class HtmlBorderRadius {
  final Radius topLeft;
  final Radius topRight;
  final Radius bottomLeft;
  final Radius bottomRight;

  const HtmlBorderRadius.all(Radius radius)
      : topLeft = radius,
        topRight = radius,
        bottomLeft = radius,
        bottomRight = radius;

  const HtmlBorderRadius.only({
    this.topLeft = Radius.zero,
    this.topRight = Radius.zero,
    this.bottomLeft = Radius.zero,
    this.bottomRight = Radius.zero,
  });

  const HtmlBorderRadius.vertical({
    Radius top = Radius.zero,
    Radius bottom = Radius.zero,
  }) : topLeft = top,
       topRight = top,
       bottomLeft = bottom,
       bottomRight = bottom;

  const HtmlBorderRadius.horizontal({
    Radius left = Radius.zero,
    Radius right = Radius.zero,
  }) : topLeft = left,
       topRight = right,
       bottomLeft = left,
       bottomRight = right;

  BorderRadius toBorderRadius() {
    return BorderRadius.only(
      topLeft: topLeft,
      topRight: topRight,
      bottomLeft: bottomLeft,
      bottomRight: bottomRight,
    );
  }
}

class HtmlDiv extends MultiChildRenderObjectWidget {
  final HtmlSize width;
  final HtmlSize height;
  final HtmlBorder? border;
  final HtmlBorderRadius? borderRadius;
  final HtmlBoxSizing boxSizing;

  const HtmlDiv({
    super.key,
    this.width = const AutoSize(),
    this.height = const AutoSize(),
    this.border,
    this.borderRadius,
    this.boxSizing = HtmlBoxSizing.contentBox,
    super.children = const [],
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderHtmlDiv(
      width: width,
      height: height,
      border: border,
      borderRadius: borderRadius,
      boxSizing: boxSizing,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderHtmlDiv renderObject) {
    renderObject
      ..width = width
      ..height = height
      ..border = border
      ..borderRadius = borderRadius
      ..boxSizing = boxSizing;
  }
}

class HtmlDivParentData extends ContainerBoxParentData<RenderBox> {}

class RenderHtmlDiv extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, HtmlDivParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, HtmlDivParentData> {
  HtmlSize _width;
  HtmlSize _height;
  HtmlBorder? _border;
  HtmlBorderRadius? _borderRadius;
  HtmlBoxSizing _boxSizing;

  EdgeInsets _computedBorderWidths = EdgeInsets.zero;

  RenderHtmlDiv({
    required HtmlSize width,
    required HtmlSize height,
    HtmlBorder? border,
    HtmlBorderRadius? borderRadius,
    HtmlBoxSizing boxSizing = HtmlBoxSizing.contentBox,
  }) : _width = width,
       _height = height,
       _border = border,
       _borderRadius = borderRadius,
       _boxSizing = boxSizing;

  HtmlSize get width => _width;
  set width(HtmlSize value) {
    if (_width != value) {
      _width = value;
      markNeedsLayout();
    }
  }

  HtmlSize get height => _height;
  set height(HtmlSize value) {
    if (_height != value) {
      _height = value;
      markNeedsLayout();
    }
  }

  HtmlBorder? get border => _border;
  set border(HtmlBorder? value) {
    if (_border != value) {
      _border = value;
      markNeedsLayout();
      markNeedsPaint();
    }
  }

  HtmlBorderRadius? get borderRadius => _borderRadius;
  set borderRadius(HtmlBorderRadius? value) {
    if (_borderRadius != value) {
      _borderRadius = value;
      markNeedsPaint();
    }
  }

  HtmlBoxSizing get boxSizing => _boxSizing;
  set boxSizing(HtmlBoxSizing value) {
    if (_boxSizing != value) {
      _boxSizing = value;
      markNeedsLayout();
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! HtmlDivParentData) {
      child.parentData = HtmlDivParentData();
    }
  }

  double _getSideWidth(HtmlBorderSide side, double containerWidth) {
    if (side.style == HtmlBorderStyle.hidden) return 0.0;
    final w = side.width;
    if (w is FixedBorderWidth) return w.value;
    if (w is KeywordBorderWidth) {
      switch (w.keyword) {
        case BorderWidthKeyword.thin:
          return 1.0;
        case BorderWidthKeyword.medium:
          return 3.0;
        case BorderWidthKeyword.thick:
          return 5.0;
      }
    }
    if (w is PercentBorderWidth) {
      return containerWidth * w.value / 100.0;
    }
    return 0.0;
  }

  EdgeInsets _calculateBorderWidths(double containerWidth) {
    if (_border == null) return EdgeInsets.zero;
    return EdgeInsets.fromLTRB(
      _getSideWidth(_border!.left, containerWidth),
      _getSideWidth(_border!.top, containerWidth),
      _getSideWidth(_border!.right, containerWidth),
      _getSideWidth(_border!.bottom, containerWidth),
    );
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    EdgeInsets borderW = _calculateBorderWidths(0);
    double borderHorizontal = borderW.horizontal;
    double contentW = 0;
    if (_width is FixedSize) {
      contentW = (_width as FixedSize).value;
    } else {
      RenderBox? child = firstChild;
      while (child != null) {
        contentW = math.max(contentW, child.getMinIntrinsicWidth(height));
        child = (child.parentData as HtmlDivParentData).nextSibling;
      }
    }

    if (_boxSizing == HtmlBoxSizing.contentBox) {
      return contentW + borderHorizontal;
    } else {
      return math.max(contentW, borderHorizontal);
    }
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    EdgeInsets borderW = _calculateBorderWidths(0);
    double borderHorizontal = borderW.horizontal;
    double contentW = 0;
    if (_width is FixedSize) {
      contentW = (_width as FixedSize).value;
    } else {
      RenderBox? child = firstChild;
      while (child != null) {
        contentW = math.max(contentW, child.getMaxIntrinsicWidth(height));
        child = (child.parentData as HtmlDivParentData).nextSibling;
      }
    }

    if (_boxSizing == HtmlBoxSizing.contentBox) {
      return contentW + borderHorizontal;
    } else {
      return math.max(contentW, borderHorizontal);
    }
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    EdgeInsets borderW = _calculateBorderWidths(width.isFinite ? width : 0);
    double borderVertical = borderW.vertical;
    double contentH = 0;
    if (_height is FixedSize) {
      contentH = (_height as FixedSize).value;
    } else {
      RenderBox? child = firstChild;
      while (child != null) {
        contentH += child.getMinIntrinsicHeight(width);
        child = (child.parentData as HtmlDivParentData).nextSibling;
      }
    }

    if (_boxSizing == HtmlBoxSizing.contentBox) {
      return contentH + borderVertical;
    } else {
      return math.max(contentH, borderVertical);
    }
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    EdgeInsets borderW = _calculateBorderWidths(width.isFinite ? width : 0);
    double borderVertical = borderW.vertical;
    double contentH = 0;
    if (_height is FixedSize) {
      contentH = (_height as FixedSize).value;
    } else {
      RenderBox? child = firstChild;
      while (child != null) {
        contentH += child.getMaxIntrinsicHeight(width);
        child = (child.parentData as HtmlDivParentData).nextSibling;
      }
    }

    if (_boxSizing == HtmlBoxSizing.contentBox) {
      return contentH + borderVertical;
    } else {
      return math.max(contentH, borderVertical);
    }
  }

  @override
  void performLayout() {
    double containerWidth = constraints.hasBoundedWidth
        ? constraints.maxWidth
        : 0.0;
    _computedBorderWidths = _calculateBorderWidths(containerWidth);
    double borderHorizontal = _computedBorderWidths.horizontal;
    double borderVertical = _computedBorderWidths.vertical;

    double? targetWidth;
    if (_width is FixedSize) {
      targetWidth = (_width as FixedSize).value;
    } else if (_width is PercentSize) {
      if (constraints.hasBoundedWidth) {
        targetWidth =
            constraints.maxWidth * (_width as PercentSize).value / 100;
      }
    } else if (_width is AutoSize) {
      if (constraints.hasBoundedWidth) {
        targetWidth = constraints.maxWidth;
      }
    }

    double contentWidth;
    if (targetWidth != null) {
      if (_boxSizing == HtmlBoxSizing.borderBox) {
        contentWidth = math.max(0.0, targetWidth - borderHorizontal);
      } else {
        contentWidth = targetWidth;
      }
    } else {
      double intrinsicWidth;
      if (_width is MinContent) {
        intrinsicWidth = computeMinIntrinsicWidth(double.infinity);
      } else if (_width is MaxContent || _width is AutoSize) {
        intrinsicWidth = computeMaxIntrinsicWidth(double.infinity);
      } else if (_width is FitContent) {
        double minI = computeMinIntrinsicWidth(double.infinity);
        double maxI = computeMaxIntrinsicWidth(double.infinity);
        double available = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : double.infinity;
        intrinsicWidth = math.min(maxI, math.max(minI, available));
      } else {
        intrinsicWidth = 0;
      }

      double totalWidth = intrinsicWidth;
      if (_boxSizing == HtmlBoxSizing.contentBox) {
        contentWidth = math.max(0, totalWidth - borderHorizontal);
      } else {
        contentWidth = math.max(0, totalWidth - borderHorizontal);
      }
      targetWidth = totalWidth;
    }

    targetWidth = constraints.constrainWidth(targetWidth);

    if (_boxSizing == HtmlBoxSizing.borderBox) {
      contentWidth = math.max(0.0, targetWidth - borderHorizontal);
    } else {
      contentWidth = targetWidth;
    }

    BoxConstraints childConstraints = BoxConstraints(maxWidth: contentWidth);

    double yOffset = _computedBorderWidths.top;
    double xOffset = _computedBorderWidths.left;
    double maxChildWidth = 0;
    double currentY = yOffset;

    RenderBox? child = firstChild;
    while (child != null) {
      final HtmlDivParentData childParentData =
          child.parentData as HtmlDivParentData;
      child.layout(childConstraints, parentUsesSize: true);
      childParentData.offset = Offset(xOffset, currentY);
      currentY += child.size.height;
      maxChildWidth = math.max(maxChildWidth, child.size.width);
      child = childParentData.nextSibling;
    }

    double contentHeight = currentY - yOffset;

    double targetHeight;
    if (_height is FixedSize) {
      targetHeight = (_height as FixedSize).value;
    } else if (_height is PercentSize && constraints.hasBoundedHeight) {
      targetHeight =
          constraints.maxHeight * (_height as PercentSize).value / 100;
    } else {
      targetHeight = contentHeight;
    }

    double finalHeight;
    if (_height is FixedSize ||
        (_height is PercentSize && constraints.hasBoundedHeight)) {
      if (_boxSizing == HtmlBoxSizing.borderBox) {
        finalHeight = targetHeight;
      } else {
        finalHeight = targetHeight + borderVertical;
      }
    } else {
      finalHeight = contentHeight + borderVertical;
    }

    double finalWidth;
    if (_boxSizing == HtmlBoxSizing.borderBox) {
      finalWidth = targetWidth;
    } else {
      finalWidth = targetWidth + borderHorizontal;
    }

    size = constraints.constrain(Size(finalWidth, finalHeight));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_border != null) {
      if (_border!.isUniform) {
        _paintUniformBorder(context, offset);
      } else {
        _paintMixedBorder(context, offset);
      }
    }
    defaultPaint(context, offset);
  }

  void _paintUniformBorder(PaintingContext context, Offset offset) {
    final HtmlBorderSide side = _border!.top;
    final double width = _computedBorderWidths.top;

    if (side.style == HtmlBorderStyle.hidden || width <= 0) return;

    final Paint paint = Paint()
      ..color = side.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;

    final Rect borderRect = (offset & size).deflate(width / 2.0);
    RRect? borderRRect;
    if (_borderRadius != null) {
      borderRRect = _borderRadius!.toBorderRadius().toRRect(borderRect);
    }

    switch (side.style) {
      case HtmlBorderStyle.solid:
        if (borderRRect != null) {
          context.canvas.drawRRect(borderRRect, paint);
        } else {
          context.canvas.drawRect(borderRect, paint);
        }
        break;
      case HtmlBorderStyle.double:
        double third = width / 3.0;
        paint.strokeWidth = third;
        if (borderRRect != null) {
          context.canvas.drawRRect(borderRRect.deflate(third), paint);
          context.canvas.drawRRect(borderRRect.deflate(-third), paint);
        } else {
          context.canvas.drawRect((offset & size).deflate(third / 2.0), paint);
          context.canvas.drawRect(
            (offset & size).deflate(width - third / 2.0),
            paint,
          );
        }
        break;
      case HtmlBorderStyle.dotted:
      case HtmlBorderStyle.dashed:
        if (borderRRect != null) {
          _drawDashedRRect(context.canvas, borderRRect, paint, side.style);
        } else {
          _drawDashedRect(context.canvas, borderRect, paint, side.style);
        }
        break;
      default:
        break;
    }
  }

  void _paintMixedBorder(PaintingContext context, Offset offset) {
    final Rect outer = offset & size;
    final Rect inner = Rect.fromLTRB(
      outer.left + _computedBorderWidths.left,
      outer.top + _computedBorderWidths.top,
      outer.right - _computedBorderWidths.right,
      outer.bottom - _computedBorderWidths.bottom,
    );

    _paintSide(
      context.canvas,
      _border!.top,
      outer.topLeft,
      outer.topRight,
      inner.topRight,
      inner.topLeft,
    );
    _paintSide(
      context.canvas,
      _border!.right,
      outer.topRight,
      outer.bottomRight,
      inner.bottomRight,
      inner.topRight,
    );
    _paintSide(
      context.canvas,
      _border!.bottom,
      outer.bottomRight,
      outer.bottomLeft,
      inner.bottomLeft,
      inner.bottomRight,
    );
    _paintSide(
      context.canvas,
      _border!.left,
      outer.bottomLeft,
      outer.topLeft,
      inner.topLeft,
      inner.bottomLeft,
    );
  }

  void _paintSide(
    Canvas canvas,
    HtmlBorderSide side,
    Offset p1,
    Offset p2,
    Offset p3,
    Offset p4,
  ) {
    if (side.style == HtmlBorderStyle.hidden) return;

    final Paint paint = Paint()..color = side.color;
    paint.style = PaintingStyle.fill;
    final Path path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..lineTo(p4.dx, p4.dy)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawDashedRect(
    Canvas canvas,
    Rect rect,
    Paint paint,
    HtmlBorderStyle style,
  ) {
    final Path path = Path()..addRect(rect);
    _drawDashedPath(canvas, path, paint, style);
  }

  void _drawDashedRRect(
    Canvas canvas,
    RRect rrect,
    Paint paint,
    HtmlBorderStyle style,
  ) {
    final Path path = Path()..addRRect(rrect);
    _drawDashedPath(canvas, path, paint, style);
  }

  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint,
    HtmlBorderStyle style,
  ) {
    final double dashWidth = style == HtmlBorderStyle.dotted
        ? paint.strokeWidth
        : paint.strokeWidth * 3;
    final double dashSpace = style == HtmlBorderStyle.dotted
        ? paint.strokeWidth
        : paint.strokeWidth * 2;

    final ui.PathMetrics metrics = path.computeMetrics();
    for (ui.PathMetric metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}
