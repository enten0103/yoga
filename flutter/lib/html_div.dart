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

class HtmlBorder {
  final HtmlBorderWidth width;
  final HtmlBorderStyle style;
  final Color color;
  final ImageProvider? image;

  const HtmlBorder({
    this.width = const KeywordBorderWidth(BorderWidthKeyword.medium),
    this.style = HtmlBorderStyle.solid,
    this.color = const Color(0xFF000000),
    this.image,
  });
}

class HtmlDiv extends MultiChildRenderObjectWidget {
  final HtmlSize width;
  final HtmlSize height;
  final HtmlBorder? border;
  final HtmlBoxSizing boxSizing;

  const HtmlDiv({
    super.key,
    this.width = const AutoSize(),
    this.height = const AutoSize(),
    this.border,
    this.boxSizing = HtmlBoxSizing.contentBox,
    super.children = const [],
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderHtmlDiv(
      width: width,
      height: height,
      border: border,
      boxSizing: boxSizing,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderHtmlDiv renderObject) {
    renderObject
      ..width = width
      ..height = height
      ..border = border
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
  HtmlBoxSizing _boxSizing;

  double _computedBorderWidth = 0.0;

  RenderHtmlDiv({
    required HtmlSize width,
    required HtmlSize height,
    HtmlBorder? border,
    HtmlBoxSizing boxSizing = HtmlBoxSizing.contentBox,
  }) : _width = width,
       _height = height,
       _border = border,
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

  double _calculateBorderWidth(double containerWidth) {
    if (_border == null || _border!.style == HtmlBorderStyle.hidden) return 0.0;
    final w = _border!.width;
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

  @override
  double computeMinIntrinsicWidth(double height) {
    double borderW = _calculateBorderWidth(0);
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
      return contentW + 2 * borderW;
    } else {
      return math.max(contentW, 2 * borderW);
    }
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    double borderW = _calculateBorderWidth(0);
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
      return contentW + 2 * borderW;
    } else {
      return math.max(contentW, 2 * borderW);
    }
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    double borderW = _calculateBorderWidth(width.isFinite ? width : 0);
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
      return contentH + 2 * borderW;
    } else {
      return math.max(contentH, 2 * borderW);
    }
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    double borderW = _calculateBorderWidth(width.isFinite ? width : 0);
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
      return contentH + 2 * borderW;
    } else {
      return math.max(contentH, 2 * borderW);
    }
  }

  @override
  void performLayout() {
    double containerWidth = constraints.hasBoundedWidth
        ? constraints.maxWidth
        : 0.0;
    _computedBorderWidth = _calculateBorderWidth(containerWidth);
    double borderDouble = 2 * _computedBorderWidth;

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
        contentWidth = math.max(0.0, targetWidth - borderDouble);
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
        contentWidth = math.max(0, totalWidth - borderDouble);
      } else {
        contentWidth = math.max(0, totalWidth - borderDouble);
      }
      targetWidth = totalWidth;
    }

    targetWidth = constraints.constrainWidth(targetWidth);

    if (_boxSizing == HtmlBoxSizing.borderBox) {
      contentWidth = math.max(0.0, targetWidth - borderDouble);
    } else {
      contentWidth = targetWidth;
    }

    BoxConstraints childConstraints = BoxConstraints(maxWidth: contentWidth);

    double yOffset = _computedBorderWidth;
    double xOffset = _computedBorderWidth;
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
        finalHeight = targetHeight + borderDouble;
      }
    } else {
      finalHeight = contentHeight + borderDouble;
    }

    double finalWidth;
    if (_boxSizing == HtmlBoxSizing.borderBox) {
      finalWidth = targetWidth;
    } else {
      finalWidth = targetWidth + borderDouble;
    }

    size = constraints.constrain(Size(finalWidth, finalHeight));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_border != null &&
        _border!.style != HtmlBorderStyle.hidden &&
        _computedBorderWidth > 0) {
      final Paint paint = Paint()
        ..color = _border!.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = _computedBorderWidth;

      final Rect borderRect = (offset & size).deflate(
        _computedBorderWidth / 2.0,
      );

      switch (_border!.style) {
        case HtmlBorderStyle.solid:
          context.canvas.drawRect(borderRect, paint);
          break;
        case HtmlBorderStyle.double:
          double third = _computedBorderWidth / 3.0;
          paint.strokeWidth = third;
          context.canvas.drawRect((offset & size).deflate(third / 2.0), paint);
          context.canvas.drawRect(
            (offset & size).deflate(_computedBorderWidth - third / 2.0),
            paint,
          );
          break;
        case HtmlBorderStyle.dotted:
        case HtmlBorderStyle.dashed:
          _drawDashedRect(context.canvas, borderRect, paint, _border!.style);
          break;
        default:
          break;
      }
    }
    defaultPaint(context, offset);
  }

  void _drawDashedRect(
    Canvas canvas,
    Rect rect,
    Paint paint,
    HtmlBorderStyle style,
  ) {
    final Path path = Path()..addRect(rect);
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
