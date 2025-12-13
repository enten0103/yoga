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
  final HtmlBorderImage? borderImage;
  final HtmlBorderImageSides? borderImageSides;

  const HtmlBorder({
    this.top = const HtmlBorderSide(style: HtmlBorderStyle.hidden),
    this.right = const HtmlBorderSide(style: HtmlBorderStyle.hidden),
    this.bottom = const HtmlBorderSide(style: HtmlBorderStyle.hidden),
    this.left = const HtmlBorderSide(style: HtmlBorderStyle.hidden),
    this.borderImage,
    this.borderImageSides,
  });

  factory HtmlBorder.all({
    HtmlBorderWidth width = const KeywordBorderWidth(BorderWidthKeyword.medium),
    HtmlBorderStyle style = HtmlBorderStyle.solid,
    Color color = const Color(0xFF000000),
    HtmlBorderImage? borderImage,
    HtmlBorderImageSides? borderImageSides,
  }) {
    final side = HtmlBorderSide(width: width, style: style, color: color);
    return HtmlBorder(
      top: side,
      right: side,
      bottom: side,
      left: side,
      borderImage: borderImage,
      borderImageSides: borderImageSides,
    );
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

// Border Image (CSS-aligned model)
//
// Mirrors the main CSS border-image longhands:
// - border-image-source
// - border-image-slice
// - border-image-width
// - border-image-outset
// - border-image-repeat

enum HtmlBorderImageRepeat { stretch, repeat, round, space }

enum HtmlBorderImageUnit { number, px, percent, auto }

class HtmlBorderImageSideValue {
  final double value;
  final HtmlBorderImageUnit unit;

  const HtmlBorderImageSideValue._(this.value, this.unit);

  const HtmlBorderImageSideValue.number(double value)
    : this._(value, HtmlBorderImageUnit.number);

  const HtmlBorderImageSideValue.px(double value)
    : this._(value, HtmlBorderImageUnit.px);

  const HtmlBorderImageSideValue.percent(double value)
    : this._(value, HtmlBorderImageUnit.percent);

  const HtmlBorderImageSideValue.auto() : this._(0, HtmlBorderImageUnit.auto);

  double resolve({required double borderWidth, required double reference}) {
    switch (unit) {
      case HtmlBorderImageUnit.number:
        return value * borderWidth;
      case HtmlBorderImageUnit.px:
        return value;
      case HtmlBorderImageUnit.percent:
        return reference * value / 100.0;
      case HtmlBorderImageUnit.auto:
        return borderWidth;
    }
  }

  double resolveOutset({
    required double borderWidth,
    required double reference,
  }) {
    switch (unit) {
      case HtmlBorderImageUnit.number:
        return value * borderWidth;
      case HtmlBorderImageUnit.px:
        return value;
      case HtmlBorderImageUnit.percent:
        return reference * value / 100.0;
      case HtmlBorderImageUnit.auto:
        // CSS doesn't define `auto` for outset; treat as 0.
        return 0.0;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HtmlBorderImageSideValue &&
        other.value == value &&
        other.unit == unit;
  }

  @override
  int get hashCode => Object.hash(value, unit);
}

class HtmlBorderImageSliceValue {
  final double value;
  final bool isPercent;
  const HtmlBorderImageSliceValue._(this.value, this.isPercent);
  const HtmlBorderImageSliceValue.px(double value) : this._(value, false);
  const HtmlBorderImageSliceValue.percent(double value) : this._(value, true);

  double resolvePx({required double referencePx}) {
    if (isPercent) return referencePx * value / 100.0;
    return value;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HtmlBorderImageSliceValue &&
        other.value == value &&
        other.isPercent == isPercent;
  }

  @override
  int get hashCode => Object.hash(value, isPercent);
}

class HtmlBorderImageSlice {
  final HtmlBorderImageSliceValue top;
  final HtmlBorderImageSliceValue right;
  final HtmlBorderImageSliceValue bottom;
  final HtmlBorderImageSliceValue left;
  final bool fill;

  const HtmlBorderImageSlice({
    required this.top,
    required this.right,
    required this.bottom,
    required this.left,
    this.fill = false,
  });

  const HtmlBorderImageSlice.all(
    HtmlBorderImageSliceValue value, {
    this.fill = false,
  }) : top = value,
       right = value,
       bottom = value,
       left = value;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HtmlBorderImageSlice &&
        other.top == top &&
        other.right == right &&
        other.bottom == bottom &&
        other.left == left &&
        other.fill == fill;
  }

  @override
  int get hashCode => Object.hash(top, right, bottom, left, fill);
}

class HtmlBorderImageSideValues {
  final HtmlBorderImageSideValue top;
  final HtmlBorderImageSideValue right;
  final HtmlBorderImageSideValue bottom;
  final HtmlBorderImageSideValue left;

  const HtmlBorderImageSideValues({
    required this.top,
    required this.right,
    required this.bottom,
    required this.left,
  });

  const HtmlBorderImageSideValues.all(HtmlBorderImageSideValue value)
    : top = value,
      right = value,
      bottom = value,
      left = value;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HtmlBorderImageSideValues &&
        other.top == top &&
        other.right == right &&
        other.bottom == bottom &&
        other.left == left;
  }

  @override
  int get hashCode => Object.hash(top, right, bottom, left);
}

class HtmlBorderImage {
  final ImageProvider image;
  final HtmlBorderImageSlice slice;
  final HtmlBorderImageSideValues width;
  final HtmlBorderImageSideValues outset;
  final HtmlBorderImageRepeat repeatX;
  final HtmlBorderImageRepeat repeatY;

  const HtmlBorderImage({
    required this.image,
    this.slice = const HtmlBorderImageSlice.all(
      HtmlBorderImageSliceValue.percent(100),
    ),
    this.width = const HtmlBorderImageSideValues.all(
      HtmlBorderImageSideValue.auto(),
    ),
    this.outset = const HtmlBorderImageSideValues.all(
      HtmlBorderImageSideValue.px(0),
    ),
    this.repeatX = HtmlBorderImageRepeat.stretch,
    this.repeatY = HtmlBorderImageRepeat.stretch,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HtmlBorderImage &&
        other.image == image &&
        other.slice == slice &&
        other.width == width &&
        other.outset == outset &&
        other.repeatX == repeatX &&
        other.repeatY == repeatY;
  }

  @override
  int get hashCode =>
      Object.hash(image, slice, width, outset, repeatX, repeatY);
}

class HtmlBorderImageSides {
  final HtmlBorderImage? top;
  final HtmlBorderImage? right;
  final HtmlBorderImage? bottom;
  final HtmlBorderImage? left;

  const HtmlBorderImageSides({this.top, this.right, this.bottom, this.left});
}

class _NineSliceSrcRects {
  final Rect topLeft;
  final Rect top;
  final Rect topRight;
  final Rect left;
  final Rect center;
  final Rect right;
  final Rect bottomLeft;
  final Rect bottom;
  final Rect bottomRight;

  const _NineSliceSrcRects({
    required this.topLeft,
    required this.top,
    required this.topRight,
    required this.left,
    required this.center,
    required this.right,
    required this.bottomLeft,
    required this.bottom,
    required this.bottomRight,
  });
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
      imageConfiguration: createLocalImageConfiguration(context),
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
      ..imageConfiguration = createLocalImageConfiguration(context)
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
  ImageConfiguration _imageConfiguration = ImageConfiguration.empty;
  final Map<ImageProvider, ImageStream> _borderImageStreams =
      <ImageProvider, ImageStream>{};
  final Map<ImageProvider, ImageInfo?> _borderImageInfos =
      <ImageProvider, ImageInfo?>{};
  final Map<ImageProvider, ImageStreamListener> _borderImageListeners =
      <ImageProvider, ImageStreamListener>{};
  HtmlBoxSizing _boxSizing;

  EdgeInsets _computedBorderWidths = EdgeInsets.zero;

  RenderHtmlDiv({
    required HtmlSize width,
    required HtmlSize height,
    HtmlBorder? border,
    HtmlBorderRadius? borderRadius,
    ImageConfiguration imageConfiguration = ImageConfiguration.empty,
    HtmlBoxSizing boxSizing = HtmlBoxSizing.contentBox,
  }) : _width = width,
       _height = height,
       _border = border,
       _borderRadius = borderRadius,
       _imageConfiguration = imageConfiguration,
       _boxSizing = boxSizing;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _resolveBorderImages();
  }

  @override
  void detach() {
    _stopListeningToBorderImages();
    super.detach();
  }

  @override
  void dispose() {
    _stopListeningToBorderImages();
    super.dispose();
  }

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
      _resolveBorderImages();
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

  ImageConfiguration get imageConfiguration => _imageConfiguration;
  set imageConfiguration(ImageConfiguration value) {
    if (_imageConfiguration != value) {
      _imageConfiguration = value;
      _resolveBorderImages();
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

  void _stopListeningToBorderImages() {
    for (final entry in _borderImageStreams.entries) {
      final provider = entry.key;
      final stream = entry.value;
      final listener = _borderImageListeners[provider];
      if (listener != null) stream.removeListener(listener);
    }
    _borderImageStreams.clear();
    _borderImageInfos.clear();
    _borderImageListeners.clear();
  }

  Iterable<ImageProvider> _collectBorderImageProviders() sync* {
    final HtmlBorder? b = _border;
    final HtmlBorderImage? base = b?.borderImage;
    if (base == null) return;

    yield base.image;
    final HtmlBorderImageSides? sides = b?.borderImageSides;
    if (sides?.top != null) yield sides!.top!.image;
    if (sides?.right != null) yield sides!.right!.image;
    if (sides?.bottom != null) yield sides!.bottom!.image;
    if (sides?.left != null) yield sides!.left!.image;
  }

  void _resolveBorderImages() {
    if (!attached) return;

    final Set<ImageProvider> required = _collectBorderImageProviders().toSet();

    // Remove old listeners.
    final List<ImageProvider> toRemove = _borderImageStreams.keys
        .where((p) => !required.contains(p))
        .toList(growable: false);
    for (final provider in toRemove) {
      final stream = _borderImageStreams.remove(provider);
      final listener = _borderImageListeners.remove(provider);
      if (stream != null && listener != null) stream.removeListener(listener);
      _borderImageInfos.remove(provider);
    }

    // Add/update required.
    for (final provider in required) {
      final ImageStream newStream = provider.resolve(_imageConfiguration);
      final ImageStream? oldStream = _borderImageStreams[provider];

      if (oldStream?.key == newStream.key &&
          _borderImageListeners.containsKey(provider)) {
        continue;
      }

      final oldListener = _borderImageListeners[provider];
      if (oldStream != null && oldListener != null) {
        oldStream.removeListener(oldListener);
      }

      final listener = ImageStreamListener(
        (ImageInfo image, bool synchronousCall) {
          _borderImageInfos[provider] = image;
          markNeedsPaint();
        },
        onError: (Object exception, StackTrace? stackTrace) {
          _borderImageInfos[provider] = null;
          markNeedsPaint();
        },
      );

      _borderImageStreams[provider] = newStream;
      _borderImageListeners[provider] = listener;
      newStream.addListener(listener);
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
    final bool paintedBorderImage = _paintBorderImageIfNeeded(context, offset);
    if (!paintedBorderImage && _border != null) {
      if (_border!.isUniform) {
        _paintUniformBorder(context, offset);
      } else {
        _paintMixedBorder(context, offset);
      }
    }
    defaultPaint(context, offset);
  }

  bool _paintBorderImageIfNeeded(PaintingContext context, Offset offset) {
    if (_border == null) return false;
    final HtmlBorderImage? base = _border!.borderImage;
    if (base == null) return false;
    if (_computedBorderWidths == EdgeInsets.zero) return false;

    // Per CSS: if border-style is none/hidden, border image shouldn't show.
    if (_border!.top.style == HtmlBorderStyle.hidden &&
        _border!.right.style == HtmlBorderStyle.hidden &&
        _border!.bottom.style == HtmlBorderStyle.hidden &&
        _border!.left.style == HtmlBorderStyle.hidden) {
      return false;
    }

    ImageInfo? infoFor(HtmlBorderImage bi) => _borderImageInfos[bi.image];

    final ImageInfo? baseInfo = infoFor(base);
    if (baseInfo == null) return false;

    HtmlBorderImage pickSide(HtmlBorderImage? override) {
      if (override == null) return base;
      return infoFor(override) == null ? base : override;
    }

    final HtmlBorderImageSides? sideOverrides = _border!.borderImageSides;
    final HtmlBorderImage topBi = pickSide(sideOverrides?.top);
    final HtmlBorderImage rightBi = pickSide(sideOverrides?.right);
    final HtmlBorderImage bottomBi = pickSide(sideOverrides?.bottom);
    final HtmlBorderImage leftBi = pickSide(sideOverrides?.left);

    final ImageInfo topInfo = infoFor(topBi) ?? baseInfo;
    final ImageInfo rightInfo = infoFor(rightBi) ?? baseInfo;
    final ImageInfo bottomInfo = infoFor(bottomBi) ?? baseInfo;
    final ImageInfo leftInfo = infoFor(leftBi) ?? baseInfo;

    final Rect borderBox = offset & size;

    final EdgeInsets borderWidths = _computedBorderWidths;

    final EdgeInsets imageWidths = EdgeInsets.fromLTRB(
      leftBi.width.left.resolve(
        borderWidth: borderWidths.left,
        reference: borderBox.width,
      ),
      topBi.width.top.resolve(
        borderWidth: borderWidths.top,
        reference: borderBox.height,
      ),
      rightBi.width.right.resolve(
        borderWidth: borderWidths.right,
        reference: borderBox.width,
      ),
      bottomBi.width.bottom.resolve(
        borderWidth: borderWidths.bottom,
        reference: borderBox.height,
      ),
    );

    final EdgeInsets outset = EdgeInsets.fromLTRB(
      leftBi.outset.left.resolveOutset(
        borderWidth: borderWidths.left,
        reference: borderBox.width,
      ),
      topBi.outset.top.resolveOutset(
        borderWidth: borderWidths.top,
        reference: borderBox.height,
      ),
      rightBi.outset.right.resolveOutset(
        borderWidth: borderWidths.right,
        reference: borderBox.width,
      ),
      bottomBi.outset.bottom.resolveOutset(
        borderWidth: borderWidths.bottom,
        reference: borderBox.height,
      ),
    );

    final Rect outer = Rect.fromLTRB(
      borderBox.left - outset.left,
      borderBox.top - outset.top,
      borderBox.right + outset.right,
      borderBox.bottom + outset.bottom,
    );

    final Rect inner = Rect.fromLTRB(
      borderBox.left + imageWidths.left,
      borderBox.top + imageWidths.top,
      borderBox.right - imageWidths.right,
      borderBox.bottom - imageWidths.bottom,
    );

    if (outer.width <= 0 || outer.height <= 0) return false;
    if (inner.left > inner.right || inner.top > inner.bottom) return false;

    _NineSliceSrcRects srcFor(HtmlBorderImage bi, ui.Image image) {
      final double imgW = image.width.toDouble();
      final double imgH = image.height.toDouble();
      double sliceTop = bi.slice.top
          .resolvePx(referencePx: imgH)
          .clamp(0.0, imgH);
      double sliceBottom = bi.slice.bottom
          .resolvePx(referencePx: imgH)
          .clamp(0.0, imgH);
      double sliceLeft = bi.slice.left
          .resolvePx(referencePx: imgW)
          .clamp(0.0, imgW);
      double sliceRight = bi.slice.right
          .resolvePx(referencePx: imgW)
          .clamp(0.0, imgW);

      if (sliceLeft + sliceRight > imgW) {
        final double scaleFactor = imgW / (sliceLeft + sliceRight);
        sliceLeft *= scaleFactor;
        sliceRight *= scaleFactor;
      }
      if (sliceTop + sliceBottom > imgH) {
        final double scaleFactor = imgH / (sliceTop + sliceBottom);
        sliceTop *= scaleFactor;
        sliceBottom *= scaleFactor;
      }

      final Rect srcTopLeft = Rect.fromLTWH(0, 0, sliceLeft, sliceTop);
      final Rect srcTop = Rect.fromLTRB(
        sliceLeft,
        0,
        imgW - sliceRight,
        sliceTop,
      );
      final Rect srcTopRight = Rect.fromLTRB(
        imgW - sliceRight,
        0,
        imgW,
        sliceTop,
      );

      final Rect srcLeft = Rect.fromLTRB(
        0,
        sliceTop,
        sliceLeft,
        imgH - sliceBottom,
      );
      final Rect srcCenter = Rect.fromLTRB(
        sliceLeft,
        sliceTop,
        imgW - sliceRight,
        imgH - sliceBottom,
      );
      final Rect srcRight = Rect.fromLTRB(
        imgW - sliceRight,
        sliceTop,
        imgW,
        imgH - sliceBottom,
      );

      final Rect srcBottomLeft = Rect.fromLTRB(
        0,
        imgH - sliceBottom,
        sliceLeft,
        imgH,
      );
      final Rect srcBottom = Rect.fromLTRB(
        sliceLeft,
        imgH - sliceBottom,
        imgW - sliceRight,
        imgH,
      );
      final Rect srcBottomRight = Rect.fromLTRB(
        imgW - sliceRight,
        imgH - sliceBottom,
        imgW,
        imgH,
      );

      return _NineSliceSrcRects(
        topLeft: srcTopLeft,
        top: srcTop,
        topRight: srcTopRight,
        left: srcLeft,
        center: srcCenter,
        right: srcRight,
        bottomLeft: srcBottomLeft,
        bottom: srcBottom,
        bottomRight: srcBottomRight,
      );
    }

    final Rect dstTopLeft = Rect.fromLTRB(
      outer.left,
      outer.top,
      inner.left,
      inner.top,
    );
    final Rect dstTop = Rect.fromLTRB(
      inner.left,
      outer.top,
      inner.right,
      inner.top,
    );
    final Rect dstTopRight = Rect.fromLTRB(
      inner.right,
      outer.top,
      outer.right,
      inner.top,
    );

    final Rect dstLeft = Rect.fromLTRB(
      outer.left,
      inner.top,
      inner.left,
      inner.bottom,
    );
    final Rect dstCenter = Rect.fromLTRB(
      inner.left,
      inner.top,
      inner.right,
      inner.bottom,
    );
    final Rect dstRight = Rect.fromLTRB(
      inner.right,
      inner.top,
      outer.right,
      inner.bottom,
    );

    final Rect dstBottomLeft = Rect.fromLTRB(
      outer.left,
      inner.bottom,
      inner.left,
      outer.bottom,
    );
    final Rect dstBottom = Rect.fromLTRB(
      inner.left,
      inner.bottom,
      inner.right,
      outer.bottom,
    );
    final Rect dstBottomRight = Rect.fromLTRB(
      inner.right,
      inner.bottom,
      outer.right,
      outer.bottom,
    );

    final Canvas canvas = context.canvas;

    // Clip to border box radius if any.
    if (_borderRadius != null) {
      canvas.save();
      final RRect clipRRect = _borderRadius!.toBorderRadius().toRRect(
        borderBox,
      );
      canvas.clipRRect(clipRRect);
    }

    final bool topHidden = _border!.top.style == HtmlBorderStyle.hidden;
    final bool rightHidden = _border!.right.style == HtmlBorderStyle.hidden;
    final bool bottomHidden = _border!.bottom.style == HtmlBorderStyle.hidden;
    final bool leftHidden = _border!.left.style == HtmlBorderStyle.hidden;

    // Corners follow vertical sides (left/right) when overrides differ.
    if (!(topHidden && leftHidden)) {
      final ui.Image cornerImage = leftInfo.image;
      final _NineSliceSrcRects src = srcFor(leftBi, cornerImage);
      _drawImageRectSafe(canvas, cornerImage, src.topLeft, dstTopLeft);
    }
    if (!topHidden) {
      final ui.Image edgeImage = topInfo.image;
      final _NineSliceSrcRects src = srcFor(topBi, edgeImage);
      _drawEdge(
        canvas,
        edgeImage,
        src.top,
        dstTop,
        axis: Axis.horizontal,
        repeat: topBi.repeatX,
        scale: topInfo.scale,
      );
    }
    if (!(topHidden && rightHidden)) {
      final ui.Image cornerImage = rightInfo.image;
      final _NineSliceSrcRects src = srcFor(rightBi, cornerImage);
      _drawImageRectSafe(canvas, cornerImage, src.topRight, dstTopRight);
    }

    if (!leftHidden) {
      final ui.Image edgeImage = leftInfo.image;
      final _NineSliceSrcRects src = srcFor(leftBi, edgeImage);
      _drawEdge(
        canvas,
        edgeImage,
        src.left,
        dstLeft,
        axis: Axis.vertical,
        repeat: leftBi.repeatY,
        scale: leftInfo.scale,
      );
    }

    HtmlBorderImage? fillBi;
    ImageInfo? fillInfo;
    if (topBi.slice.fill) {
      fillBi = topBi;
      fillInfo = topInfo;
    } else if (rightBi.slice.fill) {
      fillBi = rightBi;
      fillInfo = rightInfo;
    } else if (bottomBi.slice.fill) {
      fillBi = bottomBi;
      fillInfo = bottomInfo;
    } else if (leftBi.slice.fill) {
      fillBi = leftBi;
      fillInfo = leftInfo;
    } else if (base.slice.fill) {
      fillBi = base;
      fillInfo = baseInfo;
    }
    if (fillBi != null && fillInfo != null) {
      final ui.Image fillImage = fillInfo.image;
      final _NineSliceSrcRects src = srcFor(fillBi, fillImage);
      _drawImageRectSafe(canvas, fillImage, src.center, dstCenter);
    }

    if (!rightHidden) {
      final ui.Image edgeImage = rightInfo.image;
      final _NineSliceSrcRects src = srcFor(rightBi, edgeImage);
      _drawEdge(
        canvas,
        edgeImage,
        src.right,
        dstRight,
        axis: Axis.vertical,
        repeat: rightBi.repeatY,
        scale: rightInfo.scale,
      );
    }

    if (!(bottomHidden && leftHidden)) {
      final ui.Image cornerImage = leftInfo.image;
      final _NineSliceSrcRects src = srcFor(leftBi, cornerImage);
      _drawImageRectSafe(canvas, cornerImage, src.bottomLeft, dstBottomLeft);
    }
    if (!bottomHidden) {
      final ui.Image edgeImage = bottomInfo.image;
      final _NineSliceSrcRects src = srcFor(bottomBi, edgeImage);
      _drawEdge(
        canvas,
        edgeImage,
        src.bottom,
        dstBottom,
        axis: Axis.horizontal,
        repeat: bottomBi.repeatX,
        scale: bottomInfo.scale,
      );
    }
    if (!(bottomHidden && rightHidden)) {
      final ui.Image cornerImage = rightInfo.image;
      final _NineSliceSrcRects src = srcFor(rightBi, cornerImage);
      _drawImageRectSafe(canvas, cornerImage, src.bottomRight, dstBottomRight);
    }

    if (_borderRadius != null) {
      canvas.restore();
    }

    return true;
  }

  void _drawImageRectSafe(Canvas canvas, ui.Image image, Rect src, Rect dst) {
    if (src.width <= 0 || src.height <= 0) return;
    if (dst.width <= 0 || dst.height <= 0) return;
    canvas.drawImageRect(image, src, dst, Paint());
  }

  void _drawEdge(
    Canvas canvas,
    ui.Image image,
    Rect src,
    Rect dst, {
    required Axis axis,
    required HtmlBorderImageRepeat repeat,
    required double scale,
  }) {
    if (src.width <= 0 || src.height <= 0) return;
    if (dst.width <= 0 || dst.height <= 0) return;

    if (repeat == HtmlBorderImageRepeat.stretch) {
      _drawImageRectSafe(canvas, image, src, dst);
      return;
    }

    final double srcMainPx = axis == Axis.horizontal ? src.width : src.height;
    final double dstMain = axis == Axis.horizontal ? dst.width : dst.height;
    final double dstCross = axis == Axis.horizontal ? dst.height : dst.width;

    final double tileMain = srcMainPx / scale;
    if (tileMain <= 0) {
      _drawImageRectSafe(canvas, image, src, dst);
      return;
    }

    int tileCount;
    double tileMainAdjusted = tileMain;
    double gap = 0.0;

    switch (repeat) {
      case HtmlBorderImageRepeat.repeat:
        tileCount = math.max(1, (dstMain / tileMain).ceil());
        break;
      case HtmlBorderImageRepeat.round:
        tileCount = math.max(1, (dstMain / tileMain).round());
        tileMainAdjusted = dstMain / tileCount;
        break;
      case HtmlBorderImageRepeat.space:
        tileCount = math.max(1, (dstMain / tileMain).floor());
        if (tileCount > 1) {
          gap = (dstMain - tileCount * tileMain) / (tileCount - 1);
        }
        break;
      case HtmlBorderImageRepeat.stretch:
        tileCount = 1;
        break;
    }

    double cursor = 0.0;
    for (int i = 0; i < tileCount; i++) {
      final double remaining = dstMain - cursor;
      if (remaining <= 0) break;

      final double segmentMain = (repeat == HtmlBorderImageRepeat.round)
          ? tileMainAdjusted
          : math.min(tileMain, remaining);

      Rect dstSegment;
      if (axis == Axis.horizontal) {
        dstSegment = Rect.fromLTWH(
          dst.left + cursor,
          dst.top,
          segmentMain,
          dstCross,
        );
      } else {
        dstSegment = Rect.fromLTWH(
          dst.left,
          dst.top + cursor,
          dstCross,
          segmentMain,
        );
      }

      Rect srcSegment = src;
      if (repeat != HtmlBorderImageRepeat.round && segmentMain < tileMain) {
        final double segmentPx = segmentMain * scale;
        if (axis == Axis.horizontal) {
          srcSegment = Rect.fromLTRB(
            src.left,
            src.top,
            src.left + segmentPx,
            src.bottom,
          );
        } else {
          srcSegment = Rect.fromLTRB(
            src.left,
            src.top,
            src.right,
            src.top + segmentPx,
          );
        }
      }

      _drawImageRectSafe(canvas, image, srcSegment, dstSegment);
      cursor += (repeat == HtmlBorderImageRepeat.round)
          ? tileMainAdjusted
          : (tileMain + gap);
    }
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
