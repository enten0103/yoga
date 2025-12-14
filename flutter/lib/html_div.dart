import 'dart:ffi' as ffi;
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'src/yoga_ffi.dart';

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

// Unified length value
//
// Supports:
// - px
// - percent (of a provided reference)
// - auto
enum HtmlLengthUnit { px, percent, auto }

class HtmlLength {
  final double value;
  final HtmlLengthUnit unit;

  const HtmlLength._(this.value, this.unit);

  const HtmlLength.px(double value) : this._(value, HtmlLengthUnit.px);
  const HtmlLength.percent(double value)
    : this._(value, HtmlLengthUnit.percent);
  const HtmlLength.auto() : this._(0, HtmlLengthUnit.auto);

  bool get isAuto => unit == HtmlLengthUnit.auto;
  bool get isPercent => unit == HtmlLengthUnit.percent;

  double resolvePx({required double reference}) {
    switch (unit) {
      case HtmlLengthUnit.px:
        return value;
      case HtmlLengthUnit.percent:
        return reference * value / 100.0;
      case HtmlLengthUnit.auto:
        return 0.0;
    }
  }
}

/// 2D length pair (px/percent/auto per axis).
///
/// Used to unify APIs that accept either pixel or percentage offsets.
class HtmlLengthOffset {
  final HtmlLength dx;
  final HtmlLength dy;

  const HtmlLengthOffset({
    this.dx = const HtmlLength.px(0),
    this.dy = const HtmlLength.px(0),
  });

  const HtmlLengthOffset.auto()
    : dx = const HtmlLength.auto(),
      dy = const HtmlLength.auto();

  const HtmlLengthOffset.zero() : this();

  Offset resolve({
    required double referenceWidth,
    required double referenceHeight,
  }) {
    return Offset(
      dx.resolvePx(reference: referenceWidth),
      dy.resolvePx(reference: referenceHeight),
    );
  }

  Offset resolveForSize(Size size) {
    return resolve(referenceWidth: size.width, referenceHeight: size.height);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HtmlLengthOffset && other.dx == dx && other.dy == dy;
  }

  @override
  int get hashCode => Object.hash(dx, dy);
}

// Margin (CSS-inspired model)
//
// Notes:
// - Margin does not paint.
// - Margin affects layout in the parent block flow.
// - Vertical margins between adjacent block children collapse per CSS rules.
class HtmlMargin {
  final HtmlLength top;
  final HtmlLength right;
  final HtmlLength bottom;
  final HtmlLength left;

  const HtmlMargin({
    this.top = const HtmlLength.px(0),
    this.right = const HtmlLength.px(0),
    this.bottom = const HtmlLength.px(0),
    this.left = const HtmlLength.px(0),
  });

  const HtmlMargin.all(HtmlLength value)
    : top = value,
      right = value,
      bottom = value,
      left = value;

  const HtmlMargin.only({
    this.top = const HtmlLength.px(0),
    this.right = const HtmlLength.px(0),
    this.bottom = const HtmlLength.px(0),
    this.left = const HtmlLength.px(0),
  });

  const HtmlMargin.symmetric({
    HtmlLength vertical = const HtmlLength.px(0),
    HtmlLength horizontal = const HtmlLength.px(0),
  }) : top = vertical,
       right = horizontal,
       bottom = vertical,
       left = horizontal;

  /// Convenience for the common CSS pattern `margin-left: auto; margin-right: auto;`.
  const HtmlMargin.horizontalAuto({
    this.top = const HtmlLength.px(0),
    this.bottom = const HtmlLength.px(0),
  }) : right = const HtmlLength.auto(),
       left = const HtmlLength.auto();

  /// Resolves the margin to physical pixels.
  ///
  /// Per CSS, percentage margins are relative to the containing block width.
  /// For normal block flow, vertical `auto` behaves like 0.
  EdgeInsets resolve({required double referenceWidth}) {
    return EdgeInsets.fromLTRB(
      left.resolvePx(reference: referenceWidth),
      top.resolvePx(reference: referenceWidth),
      right.resolvePx(reference: referenceWidth),
      bottom.resolvePx(reference: referenceWidth),
    );
  }
}

// Padding (CSS-inspired model)
//
// Notes:
// - Padding does not paint by itself.
// - Padding affects layout inside the element (content box is inset).
// - Percentage paddings are relative to the containing block width.
class HtmlPadding {
  final HtmlLength top;
  final HtmlLength right;
  final HtmlLength bottom;
  final HtmlLength left;

  const HtmlPadding({
    this.top = const HtmlLength.px(0),
    this.right = const HtmlLength.px(0),
    this.bottom = const HtmlLength.px(0),
    this.left = const HtmlLength.px(0),
  });

  const HtmlPadding.all(HtmlLength value)
    : top = value,
      right = value,
      bottom = value,
      left = value;

  const HtmlPadding.only({
    this.top = const HtmlLength.px(0),
    this.right = const HtmlLength.px(0),
    this.bottom = const HtmlLength.px(0),
    this.left = const HtmlLength.px(0),
  });

  const HtmlPadding.symmetric({
    HtmlLength vertical = const HtmlLength.px(0),
    HtmlLength horizontal = const HtmlLength.px(0),
  }) : top = vertical,
       right = horizontal,
       bottom = vertical,
       left = horizontal;

  EdgeInsets resolve({required double referenceWidth}) {
    return EdgeInsets.fromLTRB(
      left.resolvePx(reference: referenceWidth),
      top.resolvePx(reference: referenceWidth),
      right.resolvePx(reference: referenceWidth),
      bottom.resolvePx(reference: referenceWidth),
    );
  }
}

// Background (CSS-inspired model)
//
// Minimal support:
// - background-color
// - background-image (single layer)
// - background-repeat (x/y)
// - background-size (auto/contain/cover/explicit)
// - background-position (alignment + px offset)
// - background-clip (border-box/padding-box)

enum HtmlBackgroundRepeat { repeat, noRepeat, round, space }

enum HtmlBackgroundClip { borderBox, paddingBox }

enum HtmlBackgroundSizeType { auto, contain, cover, explicit }

class HtmlBackgroundSize {
  final HtmlBackgroundSizeType type;
  final HtmlLength? width;
  final HtmlLength? height;

  const HtmlBackgroundSize._(this.type, {this.width, this.height});

  const HtmlBackgroundSize.auto() : this._(HtmlBackgroundSizeType.auto);
  const HtmlBackgroundSize.contain() : this._(HtmlBackgroundSizeType.contain);
  const HtmlBackgroundSize.cover() : this._(HtmlBackgroundSizeType.cover);

  const HtmlBackgroundSize.explicit({HtmlLength? width, HtmlLength? height})
    : this._(HtmlBackgroundSizeType.explicit, width: width, height: height);
}

class HtmlBackgroundPosition {
  final Alignment alignment;
  final HtmlLengthOffset offset;

  const HtmlBackgroundPosition({
    this.alignment = Alignment.topLeft,
    this.offset = const HtmlLengthOffset.zero(),
  });
}

class HtmlBackgroundImage {
  final ImageProvider image;
  final HtmlBackgroundRepeat repeatX;
  final HtmlBackgroundRepeat repeatY;
  final HtmlBackgroundSize size;
  final HtmlBackgroundPosition position;

  const HtmlBackgroundImage({
    required this.image,
    this.repeatX = HtmlBackgroundRepeat.repeat,
    this.repeatY = HtmlBackgroundRepeat.repeat,
    this.size = const HtmlBackgroundSize.auto(),
    this.position = const HtmlBackgroundPosition(),
  });
}

class HtmlBackground {
  final Color? color;
  final HtmlBackgroundImage? image;
  final HtmlBackgroundClip clip;

  const HtmlBackground({
    this.color,
    this.image,
    this.clip = HtmlBackgroundClip.borderBox,
  });
}

// Transform (CSS-inspired model)
//
// Notes:
// - Transforms do not affect layout, only painting and hit testing.
// - The transform origin is resolved against the border-box size.
class HtmlTransform {
  final Matrix4 matrix;

  /// Equivalent to CSS `transform-origin` alignment in the border box.
  ///
  /// Default is center.
  final Alignment originAlignment;

  /// Additional origin offset in logical pixels or percent of border-box size.
  final HtmlLengthOffset originOffset;

  HtmlTransform({
    Matrix4? matrix,
    this.originAlignment = Alignment.center,
    this.originOffset = const HtmlLengthOffset.zero(),
  }) : matrix = matrix ?? Matrix4.identity();

  static HtmlTransform identity() => HtmlTransform();
}

// Box Shadow (CSS-inspired model)
//
// Supports multiple shadows and `inset`.
class HtmlBoxShadow {
  final Color color;
  final HtmlLengthOffset offset;
  final double blurRadius;
  final double spreadRadius;
  final bool inset;

  const HtmlBoxShadow({
    this.color = const Color(0xFF000000),
    this.offset = const HtmlLengthOffset.zero(),
    this.blurRadius = 0.0,
    this.spreadRadius = 0.0,
    this.inset = false,
  });
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

class _BackgroundAxisTile {
  final double offset;
  final double spacing;

  /// -1 means "repeat until bounds".
  final int count;
  final double? overrideTileExtent;

  const _BackgroundAxisTile({
    required this.offset,
    required this.spacing,
    required this.count,
    this.overrideTileExtent,
  });
}

enum HtmlDisplay { block, inline, flex }

enum HtmlFlexDirection { row, rowReverse, column, columnReverse }

enum HtmlJustifyContent {
  flexStart,
  center,
  flexEnd,
  spaceBetween,
  spaceAround,
  spaceEvenly,
}

enum HtmlAlignItems { stretch, flexStart, center, flexEnd, baseline }

enum HtmlAlignSelf { auto, stretch, flexStart, center, flexEnd, baseline }

enum HtmlFlexWrap { noWrap, wrap, wrapReverse }

enum HtmlTextAlign { start, center, end, justify }

class HtmlDiv extends MultiChildRenderObjectWidget {
  final HtmlSize width;
  final HtmlSize height;
  final HtmlSize? minWidth;
  final HtmlSize? maxWidth;
  final HtmlSize? minHeight;
  final HtmlSize? maxHeight;
  final HtmlDisplay display;
  // Flex container styles (used when display == flex)
  final HtmlFlexDirection flexDirection;
  final HtmlJustifyContent justifyContent;
  final HtmlAlignItems alignItems;
  final HtmlFlexWrap flexWrap;

  // Flex item styles (used when parent is flex)
  final double flexGrow;
  final double flexShrink;
  final HtmlLength flexBasis;
  final HtmlAlignSelf alignSelf;
  final HtmlTextAlign textAlign;
  final HtmlLength? lineHeight;
  final HtmlLength textIndent;
  final HtmlMargin? margin;
  final HtmlPadding? padding;
  final HtmlBorder? border;
  final HtmlBorderRadius? borderRadius;
  final HtmlBoxSizing boxSizing;
  final HtmlBackground? background;
  final List<HtmlBoxShadow> boxShadow;
  final HtmlTransform? transform;

  const HtmlDiv({
    super.key,
    this.width = const AutoSize(),
    this.height = const AutoSize(),
    this.minWidth,
    this.maxWidth,
    this.minHeight,
    this.maxHeight,
    this.display = HtmlDisplay.block,
    this.flexDirection = HtmlFlexDirection.row,
    this.justifyContent = HtmlJustifyContent.flexStart,
    this.alignItems = HtmlAlignItems.stretch,
    this.flexWrap = HtmlFlexWrap.noWrap,
    this.flexGrow = 0.0,
    this.flexShrink = 1.0,
    this.flexBasis = const HtmlLength.auto(),
    this.alignSelf = HtmlAlignSelf.auto,
    this.textAlign = HtmlTextAlign.start,
    this.lineHeight,
    this.textIndent = const HtmlLength.px(0),
    this.margin,
    this.padding,
    this.border,
    this.borderRadius,
    this.boxSizing = HtmlBoxSizing.contentBox,
    this.background,
    this.boxShadow = const <HtmlBoxShadow>[],
    this.transform,
    super.children = const [],
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderHtmlDiv(
      width: width,
      height: height,
      minWidth: minWidth,
      maxWidth: maxWidth,
      minHeight: minHeight,
      maxHeight: maxHeight,
      display: display,
      flexDirection: flexDirection,
      justifyContent: justifyContent,
      alignItems: alignItems,
      flexWrap: flexWrap,
      flexGrow: flexGrow,
      flexShrink: flexShrink,
      flexBasis: flexBasis,
      alignSelf: alignSelf,
      textAlign: textAlign,
      lineHeight: lineHeight,
      textIndent: textIndent,
      margin: margin,
      padding: padding,
      border: border,
      borderRadius: borderRadius,
      background: background,
      boxShadow: boxShadow,
      transform: transform,
      imageConfiguration: createLocalImageConfiguration(context),
      boxSizing: boxSizing,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderHtmlDiv renderObject) {
    renderObject
      ..width = width
      ..height = height
      ..minWidth = minWidth
      ..maxWidth = maxWidth
      ..minHeight = minHeight
      ..maxHeight = maxHeight
      ..display = display
      ..flexDirection = flexDirection
      ..justifyContent = justifyContent
      ..alignItems = alignItems
      ..flexWrap = flexWrap
      ..flexGrow = flexGrow
      ..flexShrink = flexShrink
      ..flexBasis = flexBasis
      ..alignSelf = alignSelf
      ..textAlign = textAlign
      ..lineHeight = lineHeight
      ..textIndent = textIndent
      ..margin = margin
      ..padding = padding
      ..border = border
      ..borderRadius = borderRadius
      ..background = background
      ..boxShadow = boxShadow
      ..transform = transform
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
  HtmlSize? _minWidth;
  HtmlSize? _maxWidth;
  HtmlSize? _minHeight;
  HtmlSize? _maxHeight;
  HtmlDisplay _display;
  HtmlFlexDirection _flexDirection;
  HtmlJustifyContent _justifyContent;
  HtmlAlignItems _alignItems;
  HtmlFlexWrap _flexWrap;
  double _flexGrow;
  double _flexShrink;
  HtmlLength _flexBasis;
  HtmlAlignSelf _alignSelf;
  HtmlTextAlign _textAlign;
  HtmlLength? _lineHeight;
  HtmlLength _textIndent;
  HtmlMargin? _margin;
  HtmlPadding? _padding;
  HtmlBorder? _border;
  HtmlBorderRadius? _borderRadius;
  HtmlBackground? _background;
  List<HtmlBoxShadow> _boxShadow;
  HtmlTransform? _transform;
  ImageConfiguration _imageConfiguration = ImageConfiguration.empty;
  final Map<ImageProvider, ImageStream> _borderImageStreams =
      <ImageProvider, ImageStream>{};
  final Map<ImageProvider, ImageInfo?> _borderImageInfos =
      <ImageProvider, ImageInfo?>{};
  final Map<ImageProvider, ImageStreamListener> _borderImageListeners =
      <ImageProvider, ImageStreamListener>{};
  ImageStream? _backgroundImageStream;
  ImageStreamListener? _backgroundImageListener;
  ImageInfo? _backgroundImageInfo;
  ImageProvider? _backgroundImageProvider;
  HtmlBoxSizing _boxSizing;

  Yoga? _yoga;

  EdgeInsets _computedBorderWidths = EdgeInsets.zero;
  EdgeInsets _computedPadding = EdgeInsets.zero;

  RenderHtmlDiv({
    required HtmlSize width,
    required HtmlSize height,
    HtmlSize? minWidth,
    HtmlSize? maxWidth,
    HtmlSize? minHeight,
    HtmlSize? maxHeight,
    HtmlDisplay display = HtmlDisplay.block,
    HtmlFlexDirection flexDirection = HtmlFlexDirection.row,
    HtmlJustifyContent justifyContent = HtmlJustifyContent.flexStart,
    HtmlAlignItems alignItems = HtmlAlignItems.stretch,
    HtmlFlexWrap flexWrap = HtmlFlexWrap.noWrap,
    double flexGrow = 0.0,
    double flexShrink = 1.0,
    HtmlLength flexBasis = const HtmlLength.auto(),
    HtmlAlignSelf alignSelf = HtmlAlignSelf.auto,
    HtmlTextAlign textAlign = HtmlTextAlign.start,
    HtmlLength? lineHeight,
    HtmlLength textIndent = const HtmlLength.px(0),
    HtmlMargin? margin,
    HtmlPadding? padding,
    HtmlBorder? border,
    HtmlBorderRadius? borderRadius,
    HtmlBackground? background,
    List<HtmlBoxShadow> boxShadow = const <HtmlBoxShadow>[],
    HtmlTransform? transform,
    ImageConfiguration imageConfiguration = ImageConfiguration.empty,
    HtmlBoxSizing boxSizing = HtmlBoxSizing.contentBox,
  }) : _width = width,
       _height = height,
       _minWidth = minWidth,
       _maxWidth = maxWidth,
       _minHeight = minHeight,
       _maxHeight = maxHeight,
       _display = display,
       _flexDirection = flexDirection,
       _justifyContent = justifyContent,
       _alignItems = alignItems,
       _flexWrap = flexWrap,
       _flexGrow = flexGrow,
       _flexShrink = flexShrink,
       _flexBasis = flexBasis,
       _alignSelf = alignSelf,
       _textAlign = textAlign,
       _lineHeight = lineHeight,
       _textIndent = textIndent,
       _margin = margin,
       _padding = padding,
       _border = border,
       _borderRadius = borderRadius,
       _background = background,
       _boxShadow = boxShadow,
       _transform = transform,
       _imageConfiguration = imageConfiguration,
       _boxSizing = boxSizing;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _resolveBorderImages();
    _resolveBackgroundImage();
  }

  @override
  void detach() {
    _stopListeningToBorderImages();
    _stopListeningToBackgroundImage();
    super.detach();
  }

  @override
  void dispose() {
    _stopListeningToBorderImages();
    _stopListeningToBackgroundImage();
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

  HtmlSize? get minWidth => _minWidth;
  set minWidth(HtmlSize? value) {
    if (_minWidth != value) {
      _minWidth = value;
      markNeedsLayout();
    }
  }

  HtmlSize? get maxWidth => _maxWidth;
  set maxWidth(HtmlSize? value) {
    if (_maxWidth != value) {
      _maxWidth = value;
      markNeedsLayout();
    }
  }

  HtmlSize? get minHeight => _minHeight;
  set minHeight(HtmlSize? value) {
    if (_minHeight != value) {
      _minHeight = value;
      markNeedsLayout();
    }
  }

  HtmlSize? get maxHeight => _maxHeight;
  set maxHeight(HtmlSize? value) {
    if (_maxHeight != value) {
      _maxHeight = value;
      markNeedsLayout();
    }
  }

  HtmlDisplay get display => _display;
  set display(HtmlDisplay value) {
    if (_display != value) {
      _display = value;
      markNeedsLayout();
    }
  }

  HtmlFlexDirection get flexDirection => _flexDirection;
  set flexDirection(HtmlFlexDirection value) {
    if (_flexDirection != value) {
      _flexDirection = value;
      markNeedsLayout();
    }
  }

  HtmlJustifyContent get justifyContent => _justifyContent;
  set justifyContent(HtmlJustifyContent value) {
    if (_justifyContent != value) {
      _justifyContent = value;
      markNeedsLayout();
    }
  }

  HtmlAlignItems get alignItems => _alignItems;
  set alignItems(HtmlAlignItems value) {
    if (_alignItems != value) {
      _alignItems = value;
      markNeedsLayout();
    }
  }

  HtmlFlexWrap get flexWrap => _flexWrap;
  set flexWrap(HtmlFlexWrap value) {
    if (_flexWrap != value) {
      _flexWrap = value;
      markNeedsLayout();
    }
  }

  double get flexGrow => _flexGrow;
  set flexGrow(double value) {
    if (_flexGrow != value) {
      _flexGrow = value;
      markNeedsLayout();
    }
  }

  double get flexShrink => _flexShrink;
  set flexShrink(double value) {
    if (_flexShrink != value) {
      _flexShrink = value;
      markNeedsLayout();
    }
  }

  HtmlLength get flexBasis => _flexBasis;
  set flexBasis(HtmlLength value) {
    if (_flexBasis != value) {
      _flexBasis = value;
      markNeedsLayout();
    }
  }

  HtmlAlignSelf get alignSelf => _alignSelf;
  set alignSelf(HtmlAlignSelf value) {
    if (_alignSelf != value) {
      _alignSelf = value;
      markNeedsLayout();
    }
  }

  Yoga _ensureYoga() {
    return _yoga ??= Yoga();
  }

  static int _toYGFlexDirection(HtmlFlexDirection v) {
    return switch (v) {
      HtmlFlexDirection.row => YGFlexDirection.row,
      HtmlFlexDirection.rowReverse => YGFlexDirection.rowReverse,
      HtmlFlexDirection.column => YGFlexDirection.column,
      HtmlFlexDirection.columnReverse => YGFlexDirection.columnReverse,
    };
  }

  static int _toYGJustifyContent(HtmlJustifyContent v) {
    return switch (v) {
      HtmlJustifyContent.flexStart => YGJustify.flexStart,
      HtmlJustifyContent.center => YGJustify.center,
      HtmlJustifyContent.flexEnd => YGJustify.flexEnd,
      HtmlJustifyContent.spaceBetween => YGJustify.spaceBetween,
      HtmlJustifyContent.spaceAround => YGJustify.spaceAround,
      HtmlJustifyContent.spaceEvenly => YGJustify.spaceEvenly,
    };
  }

  static int _toYGAlignItems(HtmlAlignItems v) {
    return switch (v) {
      HtmlAlignItems.stretch => YGAlign.stretch,
      HtmlAlignItems.flexStart => YGAlign.flexStart,
      HtmlAlignItems.center => YGAlign.center,
      HtmlAlignItems.flexEnd => YGAlign.flexEnd,
      HtmlAlignItems.baseline => YGAlign.baseline,
    };
  }

  static int _toYGAlignSelf(HtmlAlignSelf v) {
    return switch (v) {
      HtmlAlignSelf.auto => YGAlign.auto,
      HtmlAlignSelf.stretch => YGAlign.stretch,
      HtmlAlignSelf.flexStart => YGAlign.flexStart,
      HtmlAlignSelf.center => YGAlign.center,
      HtmlAlignSelf.flexEnd => YGAlign.flexEnd,
      HtmlAlignSelf.baseline => YGAlign.baseline,
    };
  }

  static int _toYGWrap(HtmlFlexWrap v) {
    return switch (v) {
      HtmlFlexWrap.noWrap => YGWrap.noWrap,
      HtmlFlexWrap.wrap => YGWrap.wrap,
      HtmlFlexWrap.wrapReverse => YGWrap.wrapReverse,
    };
  }

  void _applyFlexBasis(
    Yoga yoga,
    ffi.Pointer<ffi.Void> node,
    HtmlLength basis,
    double referenceWidth,
  ) {
    if (basis.isAuto) {
      yoga.setFlexBasisAuto(node);
      return;
    }
    if (basis.isPercent) {
      yoga.setFlexBasisPercent(node, basis.value);
      return;
    }
    yoga.setFlexBasis(node, basis.resolvePx(reference: referenceWidth));
  }

  void _applyYogaSizeFromHtmlSize(
    Yoga yoga,
    ffi.Pointer<ffi.Void> node, {
    required bool isWidth,
    required HtmlSize size,
  }) {
    if (size is FixedSize) {
      if (isWidth) {
        yoga.setWidth(node, size.value);
      } else {
        yoga.setHeight(node, size.value);
      }
      return;
    }
    if (size is PercentSize) {
      if (isWidth) {
        yoga.setWidthPercent(node, size.value);
      } else {
        yoga.setHeightPercent(node, size.value);
      }
      return;
    }
    if (isWidth) {
      yoga.setWidthAuto(node);
    } else {
      yoga.setHeightAuto(node);
    }
  }

  double _performFlexLayout({
    required double contentWidth,
    required double xOffset,
    required double yOffset,
    required double availableBorderBoxHeight,
    required double borderVertical,
    required double paddingVertical,
  }) {
    final Yoga yoga = _ensureYoga();
    final ffi.Pointer<ffi.Void> root = yoga.newNode();

    final List<RenderBox> children = <RenderBox>[];
    RenderBox? child = firstChild;
    while (child != null) {
      children.add(child);
      child = (child.parentData! as HtmlDivParentData).nextSibling;
    }

    final List<ffi.Pointer<ffi.Void>> childNodes = <ffi.Pointer<ffi.Void>>[];

    try {
      yoga.setDisplay(root, YGDisplay.flex);
      yoga.setFlexDirection(root, _toYGFlexDirection(_flexDirection));
      yoga.setJustifyContent(root, _toYGJustifyContent(_justifyContent));
      yoga.setAlignItems(root, _toYGAlignItems(_alignItems));
      yoga.setFlexWrap(root, _toYGWrap(_flexWrap));

      yoga.setWidth(root, contentWidth);

      if (_height is FixedSize) {
        final double h = (_height as FixedSize).value;
        final double contentH = _boxSizing == HtmlBoxSizing.borderBox
            ? math.max(0.0, h - borderVertical - paddingVertical)
            : h;
        yoga.setHeight(root, contentH);
      } else if (_height is PercentSize && constraints.hasBoundedHeight) {
        final double h =
            constraints.maxHeight * (_height as PercentSize).value / 100.0;
        final double contentH = _boxSizing == HtmlBoxSizing.borderBox
            ? math.max(0.0, h - borderVertical - paddingVertical)
            : h;
        yoga.setHeight(root, contentH);
      } else {
        yoga.setHeightAuto(root);
      }

      final bool mainAxisIsRow =
          _flexDirection == HtmlFlexDirection.row ||
          _flexDirection == HtmlFlexDirection.rowReverse;

      for (final RenderBox c in children) {
        // Loose pre-layout for a measurable basis.
        c.layout(
          BoxConstraints(
            minWidth: 0,
            maxWidth: contentWidth,
            minHeight: 0,
            maxHeight: double.infinity,
          ),
          parentUsesSize: true,
        );

        final ffi.Pointer<ffi.Void> node = yoga.newNode();
        childNodes.add(node);
        yoga.insertChild(root, node, childNodes.length - 1);

        // Flex item styles.
        if (c is RenderHtmlDiv) {
          yoga.setFlexGrow(node, c._flexGrow);
          yoga.setFlexShrink(node, c._flexShrink);
          _applyFlexBasis(yoga, node, c._flexBasis, contentWidth);
          yoga.setAlignSelf(node, _toYGAlignSelf(c._alignSelf));
        } else {
          yoga.setFlexGrow(node, 0.0);
          yoga.setFlexShrink(node, 1.0);
          yoga.setFlexBasisAuto(node);
          yoga.setAlignSelf(node, YGAlign.auto);
        }

        // Margin.
        final HtmlMargin? mObj = _readChildHtmlMargin(c);
        if (mObj != null) {
          if (mObj.left.isAuto) {
            yoga.setMarginAuto(node, YGEdge.left);
          } else {
            yoga.setMargin(
              node,
              YGEdge.left,
              mObj.left.resolvePx(reference: contentWidth),
            );
          }
          if (mObj.right.isAuto) {
            yoga.setMarginAuto(node, YGEdge.right);
          } else {
            yoga.setMargin(
              node,
              YGEdge.right,
              mObj.right.resolvePx(reference: contentWidth),
            );
          }
          yoga.setMargin(
            node,
            YGEdge.top,
            mObj.top.isAuto ? 0.0 : mObj.top.resolvePx(reference: contentWidth),
          );
          yoga.setMargin(
            node,
            YGEdge.bottom,
            mObj.bottom.isAuto
                ? 0.0
                : mObj.bottom.resolvePx(reference: contentWidth),
          );
        }

        // Size. Forward explicit width/height; otherwise use measured size.
        if (c is RenderHtmlDiv) {
          final HtmlSize w = c._width;
          final HtmlSize h = c._height;

          if (mainAxisIsRow) {
            if (w is FixedSize || w is PercentSize) {
              _applyYogaSizeFromHtmlSize(yoga, node, isWidth: true, size: w);
            } else {
              yoga.setWidthAuto(node);
              yoga.setFlexBasis(node, c.size.width);
            }

            if (_alignItems == HtmlAlignItems.stretch &&
                !(h is FixedSize || h is PercentSize)) {
              yoga.setHeightAuto(node);
            } else if (h is FixedSize || h is PercentSize) {
              _applyYogaSizeFromHtmlSize(yoga, node, isWidth: false, size: h);
            } else {
              yoga.setHeight(node, c.size.height);
            }
          } else {
            if (h is FixedSize || h is PercentSize) {
              _applyYogaSizeFromHtmlSize(yoga, node, isWidth: false, size: h);
            } else {
              yoga.setHeightAuto(node);
              yoga.setFlexBasis(node, c.size.height);
            }

            if (_alignItems == HtmlAlignItems.stretch &&
                !(w is FixedSize || w is PercentSize)) {
              yoga.setWidthAuto(node);
            } else if (w is FixedSize || w is PercentSize) {
              _applyYogaSizeFromHtmlSize(yoga, node, isWidth: true, size: w);
            } else {
              yoga.setWidth(node, c.size.width);
            }
          }
        } else {
          yoga.setWidth(node, c.size.width);
          yoga.setHeight(node, c.size.height);
        }
      }

      final double availableContentHeight = availableBorderBoxHeight.isFinite
          ? math.max(
              0.0,
              availableBorderBoxHeight - borderVertical - paddingVertical,
            )
          : double.nan;

      yoga.calculateLayout(
        root,
        availableWidth: contentWidth,
        availableHeight: availableContentHeight,
      );

      double maxBottom = yOffset;
      for (int i = 0; i < children.length; i++) {
        final RenderBox c = children[i];
        final ffi.Pointer<ffi.Void> node = childNodes[i];

        final double left = yoga.getLeft(node);
        final double top = yoga.getTop(node);
        final double w = yoga.getLayoutWidth(node);
        final double h = yoga.getLayoutHeight(node);

        c.layout(
          BoxConstraints.tightFor(width: w, height: h),
          parentUsesSize: true,
        );

        final HtmlDivParentData pd = c.parentData! as HtmlDivParentData;
        pd.offset = Offset(xOffset + left, yOffset + top);
        maxBottom = math.max(maxBottom, pd.offset.dy + c.size.height);
      }

      return math.max(0.0, maxBottom - yOffset);
    } finally {
      try {
        yoga.freeNodeRecursive(root);
      } catch (_) {
        // ignore
      }
    }
  }

  HtmlTextAlign get textAlign => _textAlign;
  set textAlign(HtmlTextAlign value) {
    if (_textAlign != value) {
      _textAlign = value;
      markNeedsLayout();
    }
  }

  HtmlLength? get lineHeight => _lineHeight;
  set lineHeight(HtmlLength? value) {
    if (_lineHeight != value) {
      _lineHeight = value;
      markNeedsLayout();
    }
  }

  HtmlLength get textIndent => _textIndent;
  set textIndent(HtmlLength value) {
    if (_textIndent != value) {
      _textIndent = value;
      markNeedsLayout();
    }
  }

  HtmlMargin? get margin => _margin;
  set margin(HtmlMargin? value) {
    if (_margin != value) {
      _margin = value;
      markNeedsLayout();
    }
  }

  HtmlPadding? get padding => _padding;
  set padding(HtmlPadding? value) {
    if (_padding != value) {
      _padding = value;
      markNeedsLayout();
    }
  }

  static double _collapseMargins(double a, double b) {
    if (a >= 0 && b >= 0) return math.max(a, b);
    if (a <= 0 && b <= 0) return math.min(a, b);
    return a + b;
  }

  static HtmlMargin? _readChildHtmlMargin(RenderBox child) {
    if (child is RenderHtmlDiv) return child._margin;
    return null;
  }

  static HtmlDisplay _readChildHtmlDisplay(RenderBox child) {
    if (child is RenderHtmlDiv) return child._display;
    // Treat plain text as inline-level content by default (CSS-like).
    if (child is RenderParagraph) return HtmlDisplay.inline;
    return HtmlDisplay.block;
  }

  static bool _hasInlineContent(RenderHtmlDiv div) {
    RenderBox? child = div.firstChild;
    while (child != null) {
      final HtmlDivParentData pd = child.parentData! as HtmlDivParentData;
      if (_readChildHtmlDisplay(child) == HtmlDisplay.inline) return true;
      child = pd.nextSibling;
    }
    return false;
  }

  static bool _isVisuallyTransparent(RenderHtmlDiv div) {
    final HtmlBackground? bg = div._background;
    final bool hasBackground =
        bg != null && (bg.color != null || bg.image != null);
    return !hasBackground &&
        div._border == null &&
        div._boxShadow.isEmpty &&
        div._transform == null;
  }

  static bool _paintsInInlineLayer(RenderBox child) {
    final HtmlDisplay d = _readChildHtmlDisplay(child);
    if (d == HtmlDisplay.inline) return true;
    // Special case: a transparent block that only exists to host inline/text
    // should paint in the inline layer so its text is not covered by later
    // block backgrounds when negative margins cause overlap.
    if (child is RenderHtmlDiv &&
        child._display == HtmlDisplay.block &&
        _isVisuallyTransparent(child) &&
        _hasInlineContent(child)) {
      return true;
    }
    return false;
  }

  static EdgeInsets _resolveChildMargin(
    RenderBox child,
    double referenceWidth,
  ) {
    final HtmlMargin? m = _readChildHtmlMargin(child);
    if (m == null) return EdgeInsets.zero;
    return m.resolve(referenceWidth: referenceWidth);
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

  HtmlBackground? get background => _background;
  set background(HtmlBackground? value) {
    if (_background != value) {
      _background = value;
      _resolveBackgroundImage();
      markNeedsPaint();
    }
  }

  List<HtmlBoxShadow> get boxShadow => _boxShadow;
  set boxShadow(List<HtmlBoxShadow> value) {
    if (!identical(_boxShadow, value)) {
      _boxShadow = value;
      markNeedsPaint();
    }
  }

  HtmlTransform? get transform => _transform;
  set transform(HtmlTransform? value) {
    if (_transform != value) {
      _transform = value;
      markNeedsPaint();
      markNeedsSemanticsUpdate();
    }
  }

  Offset _resolveTransformOrigin(HtmlTransform t) {
    if (size.isEmpty) {
      return t.originOffset.resolve(referenceWidth: 0, referenceHeight: 0);
    }
    final Offset aligned = t.originAlignment.alongSize(size);
    final Offset offset = t.originOffset.resolveForSize(size);
    return aligned + offset;
  }

  Matrix4? _effectiveTransform() {
    final HtmlTransform? t = _transform;
    if (t == null) return null;

    final Offset origin = _resolveTransformOrigin(t);
    final Matrix4 m = Matrix4.identity()
      ..translateByDouble(origin.dx, origin.dy, 0.0, 1.0)
      ..multiply(t.matrix)
      ..translateByDouble(-origin.dx, -origin.dy, 0.0, 1.0);

    // Avoid creating a compositing layer for pure identity.
    if (m.isIdentity()) return null;
    return m;
  }

  ImageConfiguration get imageConfiguration => _imageConfiguration;
  set imageConfiguration(ImageConfiguration value) {
    if (_imageConfiguration != value) {
      _imageConfiguration = value;
      _resolveBorderImages();
      _resolveBackgroundImage();
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

  void _stopListeningToBackgroundImage() {
    final ImageStream? stream = _backgroundImageStream;
    final ImageStreamListener? listener = _backgroundImageListener;
    if (stream != null && listener != null) {
      stream.removeListener(listener);
    }
    _backgroundImageStream = null;
    _backgroundImageListener = null;
    _backgroundImageInfo = null;
    _backgroundImageProvider = null;
  }

  void _resolveBackgroundImage() {
    if (!attached) return;

    final ImageProvider? provider = _background?.image?.image;
    if (provider == null) {
      if (_backgroundImageProvider != null) {
        _stopListeningToBackgroundImage();
        markNeedsPaint();
      }
      return;
    }

    final ImageStream newStream = provider.resolve(_imageConfiguration);
    final ImageStream? oldStream = _backgroundImageStream;

    if (_backgroundImageProvider == provider &&
        oldStream?.key == newStream.key &&
        _backgroundImageListener != null) {
      return;
    }

    if (oldStream != null && _backgroundImageListener != null) {
      oldStream.removeListener(_backgroundImageListener!);
    }

    _backgroundImageProvider = provider;
    _backgroundImageStream = newStream;
    _backgroundImageListener = ImageStreamListener(
      (ImageInfo image, bool synchronousCall) {
        _backgroundImageInfo = image;
        markNeedsPaint();
      },
      onError: (Object exception, StackTrace? stackTrace) {
        _backgroundImageInfo = null;
        markNeedsPaint();
      },
    );
    newStream.addListener(_backgroundImageListener!);
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

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    // CSS inline-block baseline is the bottom margin edge by default.
    // We approximate this by using the bottom edge of the border box.
    return size.height;
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

  static double _inlineMinContentWidth(RenderBox? firstChild, double height) {
    double maxBoxWidth = 0;
    RenderBox? child = firstChild;
    while (child != null) {
      final EdgeInsets m = _resolveChildMargin(child, 0);
      final double childWidth = child.getMinIntrinsicWidth(height);
      maxBoxWidth = math.max(maxBoxWidth, childWidth + m.horizontal);
      child = (child.parentData as HtmlDivParentData).nextSibling;
    }
    return maxBoxWidth;
  }

  static double _inlineMaxContentWidth(RenderBox? firstChild, double height) {
    double maxLineWidth = 0;
    double currentLineWidth = 0;

    RenderBox? child = firstChild;
    while (child != null) {
      final EdgeInsets m = _resolveChildMargin(child, 0);
      final HtmlDisplay d = _readChildHtmlDisplay(child);

      if (d == HtmlDisplay.inline) {
        final double childWidth = child.getMaxIntrinsicWidth(height);
        currentLineWidth += childWidth + m.horizontal;
      } else {
        maxLineWidth = math.max(maxLineWidth, currentLineWidth);
        final double childWidth = child.getMaxIntrinsicWidth(height);
        maxLineWidth = math.max(maxLineWidth, childWidth + m.horizontal);
        currentLineWidth = 0;
      }

      child = (child.parentData as HtmlDivParentData).nextSibling;
    }

    maxLineWidth = math.max(maxLineWidth, currentLineWidth);
    return maxLineWidth;
  }

  static double _inlineIntrinsicHeight(
    RenderBox? firstChild,
    double width,
    HtmlLength? lineHeight,
    HtmlLength textIndent,
  ) {
    if (!width.isFinite || width <= 0) return 0;

    final double indentPx = textIndent.resolvePx(reference: width);
    bool indentApplied = false;
    double currentLineIndent = 0;

    double currentY = 0;
    double inlineX = 0;
    double lineAscent = 0;
    double lineDescent = 0;

    double flushLine() {
      final double natural = lineAscent + lineDescent;
      if (natural <= 0) return 0;
      if (lineHeight == null || lineHeight.isAuto) return natural;
      final double target = lineHeight.resolvePx(reference: natural);
      if (!target.isFinite) return natural;
      return math.max(0.0, target);
    }

    RenderBox? child = firstChild;
    while (child != null) {
      final HtmlDisplay d = _readChildHtmlDisplay(child);
      final EdgeInsets m = _resolveChildMargin(child, width);

      if (d == HtmlDisplay.inline) {
        if (inlineX == 0) {
          currentLineIndent = indentApplied ? 0.0 : indentPx;
        }
        final double available = math.max(0.0, width - currentLineIndent);
        final double childMaxWidth = math.max(0.0, available - m.horizontal);
        final double childWidth = child.getMaxIntrinsicWidth(double.infinity);
        final double childHeight = child.getMaxIntrinsicHeight(childMaxWidth);
        final double baselineDistance =
            child.getDistanceToBaseline(TextBaseline.alphabetic) ?? childHeight;

        final double inlineBoxWidth = childWidth + m.horizontal;
        if (inlineX > 0 && inlineX + inlineBoxWidth > available) {
          currentY += flushLine();
          inlineX = 0;
          lineAscent = 0;
          lineDescent = 0;
          indentApplied = true;
          currentLineIndent = 0;
        }

        inlineX += inlineBoxWidth;
        final double ascent = m.top + baselineDistance;
        final double descent = (childHeight - baselineDistance) + m.bottom;
        lineAscent = math.max(lineAscent, ascent);
        lineDescent = math.max(lineDescent, descent);

        if (!indentApplied) {
          // After we've placed content on the first inline line, subsequent lines are not indented.
          indentApplied = true;
        }
      } else {
        if (inlineX > 0) {
          currentY += flushLine();
          inlineX = 0;
          lineAscent = 0;
          lineDescent = 0;
          indentApplied = true;
          currentLineIndent = 0;
        }
        final double childMaxWidth = math.max(0.0, width - m.horizontal);
        final double childHeight = child.getMaxIntrinsicHeight(childMaxWidth);
        currentY += m.top + childHeight + m.bottom;
      }

      child = (child.parentData as HtmlDivParentData).nextSibling;
    }

    if (inlineX > 0) currentY += flushLine();
    return currentY;
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    EdgeInsets borderW = _calculateBorderWidths(0);
    final EdgeInsets paddingW =
        _padding?.resolve(referenceWidth: 0) ?? EdgeInsets.zero;
    final double nonContentHorizontal =
        borderW.horizontal + paddingW.horizontal;
    double contentW = 0;
    if (_width is FixedSize) {
      contentW = (_width as FixedSize).value;
    } else {
      if (_display == HtmlDisplay.inline) {
        contentW = _inlineMinContentWidth(firstChild, height);
      } else {
        RenderBox? child = firstChild;
        while (child != null) {
          // Percentage margins depend on containing block width; ignore in width intrinsics.
          final EdgeInsets m = _resolveChildMargin(child, 0);
          contentW = math.max(
            contentW,
            child.getMinIntrinsicWidth(height) + m.horizontal,
          );
          child = (child.parentData as HtmlDivParentData).nextSibling;
        }
      }
    }

    if (_boxSizing == HtmlBoxSizing.contentBox) {
      return contentW + nonContentHorizontal;
    } else {
      return math.max(contentW, nonContentHorizontal);
    }
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    EdgeInsets borderW = _calculateBorderWidths(0);
    final EdgeInsets paddingW =
        _padding?.resolve(referenceWidth: 0) ?? EdgeInsets.zero;
    final double nonContentHorizontal =
        borderW.horizontal + paddingW.horizontal;
    double contentW = 0;
    if (_width is FixedSize) {
      contentW = (_width as FixedSize).value;
    } else {
      if (_display == HtmlDisplay.inline) {
        contentW = _inlineMaxContentWidth(firstChild, height);
      } else {
        RenderBox? child = firstChild;
        while (child != null) {
          // Percentage margins depend on containing block width; ignore in width intrinsics.
          final EdgeInsets m = _resolveChildMargin(child, 0);
          contentW = math.max(
            contentW,
            child.getMaxIntrinsicWidth(height) + m.horizontal,
          );
          child = (child.parentData as HtmlDivParentData).nextSibling;
        }
      }
    }

    if (_boxSizing == HtmlBoxSizing.contentBox) {
      return contentW + nonContentHorizontal;
    } else {
      return math.max(contentW, nonContentHorizontal);
    }
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    EdgeInsets borderW = _calculateBorderWidths(width.isFinite ? width : 0);
    final EdgeInsets paddingW =
        _padding?.resolve(referenceWidth: width.isFinite ? width : 0) ??
        EdgeInsets.zero;
    final double nonContentVertical = borderW.vertical + paddingW.vertical;
    double contentH = 0;
    if (_height is FixedSize) {
      contentH = (_height as FixedSize).value;
    } else {
      final double referenceWidth = width.isFinite
          ? math.max(0.0, width - borderW.horizontal - paddingW.horizontal)
          : 0.0;

      if (_display == HtmlDisplay.inline) {
        contentH = _inlineIntrinsicHeight(
          firstChild,
          referenceWidth,
          _lineHeight,
          _textIndent,
        );
      } else {
        double prevBottom = 0;
        RenderBox? child = firstChild;
        while (child != null) {
          final EdgeInsets m = _resolveChildMargin(child, referenceWidth);
          contentH += _collapseMargins(prevBottom, m.top);
          contentH += child.getMinIntrinsicHeight(width);
          prevBottom = m.bottom;
          child = (child.parentData as HtmlDivParentData).nextSibling;
        }
        contentH += prevBottom;
      }
    }

    if (_boxSizing == HtmlBoxSizing.contentBox) {
      return contentH + nonContentVertical;
    } else {
      return math.max(contentH, nonContentVertical);
    }
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    EdgeInsets borderW = _calculateBorderWidths(width.isFinite ? width : 0);
    final EdgeInsets paddingW =
        _padding?.resolve(referenceWidth: width.isFinite ? width : 0) ??
        EdgeInsets.zero;
    final double nonContentVertical = borderW.vertical + paddingW.vertical;
    double contentH = 0;
    if (_height is FixedSize) {
      contentH = (_height as FixedSize).value;
    } else {
      final double referenceWidth = width.isFinite
          ? math.max(0.0, width - borderW.horizontal - paddingW.horizontal)
          : 0.0;

      if (_display == HtmlDisplay.inline) {
        contentH = _inlineIntrinsicHeight(
          firstChild,
          referenceWidth,
          _lineHeight,
          _textIndent,
        );
      } else {
        double prevBottom = 0;
        RenderBox? child = firstChild;
        while (child != null) {
          final EdgeInsets m = _resolveChildMargin(child, referenceWidth);
          contentH += _collapseMargins(prevBottom, m.top);
          contentH += child.getMaxIntrinsicHeight(width);
          prevBottom = m.bottom;
          child = (child.parentData as HtmlDivParentData).nextSibling;
        }
        contentH += prevBottom;
      }
    }

    if (_boxSizing == HtmlBoxSizing.contentBox) {
      return contentH + nonContentVertical;
    } else {
      return math.max(contentH, nonContentVertical);
    }
  }

  @override
  void performLayout() {
    final double containerBorderBoxWidth = constraints.hasBoundedWidth
        ? constraints.maxWidth
        : 0.0;
    _computedBorderWidths = _calculateBorderWidths(containerBorderBoxWidth);
    _computedPadding =
        _padding?.resolve(referenceWidth: containerBorderBoxWidth) ??
        EdgeInsets.zero;
    final double borderHorizontal = _computedBorderWidths.horizontal;
    final double borderVertical = _computedBorderWidths.vertical;
    final double paddingHorizontal = _computedPadding.horizontal;
    final double paddingVertical = _computedPadding.vertical;

    double availableBorderBoxWidth = constraints.hasBoundedWidth
        ? constraints.maxWidth
        : double.infinity;
    double availableBorderBoxHeight = constraints.hasBoundedHeight
        ? constraints.maxHeight
        : double.infinity;

    double availableSizingWidth;
    if (_boxSizing == HtmlBoxSizing.borderBox) {
      availableSizingWidth = availableBorderBoxWidth;
    } else {
      availableSizingWidth = availableBorderBoxWidth.isFinite
          ? math.max(
              0.0,
              availableBorderBoxWidth - borderHorizontal - paddingHorizontal,
            )
          : double.infinity;
    }

    double? resolveSizingLimit(HtmlSize? v, {required bool isWidthAxis}) {
      if (v == null) return null;

      final double availableBorderBox = isWidthAxis
          ? availableBorderBoxWidth
          : availableBorderBoxHeight;

      if (v is FixedSize) return v.value;
      if (v is PercentSize) {
        if (availableBorderBox.isFinite) {
          return availableBorderBox * v.value / 100.0;
        }
        return null;
      }

      double intrinsicBorderBox;
      if (isWidthAxis) {
        if (v is MinContent) {
          intrinsicBorderBox = computeMinIntrinsicWidth(double.infinity);
        } else if (v is MaxContent) {
          intrinsicBorderBox = computeMaxIntrinsicWidth(double.infinity);
        } else if (v is FitContent) {
          final double minI = computeMinIntrinsicWidth(double.infinity);
          final double maxI = computeMaxIntrinsicWidth(double.infinity);
          intrinsicBorderBox = math.min(
            maxI,
            math.max(minI, availableBorderBoxWidth),
          );
        } else {
          return null;
        }
      } else {
        if (v is MinContent) {
          intrinsicBorderBox = computeMinIntrinsicHeight(double.infinity);
        } else if (v is MaxContent) {
          intrinsicBorderBox = computeMaxIntrinsicHeight(double.infinity);
        } else if (v is FitContent) {
          final double minI = computeMinIntrinsicHeight(double.infinity);
          final double maxI = computeMaxIntrinsicHeight(double.infinity);
          intrinsicBorderBox = math.min(
            maxI,
            math.max(minI, availableBorderBoxHeight),
          );
        } else {
          return null;
        }
      }

      if (_boxSizing == HtmlBoxSizing.borderBox) {
        return intrinsicBorderBox;
      }
      final double border = isWidthAxis ? borderHorizontal : borderVertical;
      return math.max(0.0, intrinsicBorderBox - border);
    }

    double? minW = resolveSizingLimit(_minWidth, isWidthAxis: true);
    double? maxW = resolveSizingLimit(_maxWidth, isWidthAxis: true);
    if (minW != null && maxW != null && maxW < minW) {
      maxW = minW;
    }

    double sizingWidth;
    if (_width is FixedSize) {
      sizingWidth = (_width as FixedSize).value;
    } else if (_width is PercentSize && constraints.hasBoundedWidth) {
      sizingWidth =
          constraints.maxWidth * (_width as PercentSize).value / 100.0;
      if (_boxSizing == HtmlBoxSizing.contentBox) {
        // percent width is resolved against containing block width; keep as content-box width.
      }
    } else if (_width is AutoSize &&
        constraints.hasBoundedWidth &&
        (_display == HtmlDisplay.block || _display == HtmlDisplay.flex)) {
      sizingWidth = availableSizingWidth;
    } else {
      // Intrinsic / shrink-to-fit cases.
      final double intrinsicBorderBox;
      if (_width is MinContent) {
        intrinsicBorderBox = computeMinIntrinsicWidth(double.infinity);
      } else if (_width is MaxContent) {
        intrinsicBorderBox = computeMaxIntrinsicWidth(double.infinity);
      } else if (_width is AutoSize && _display == HtmlDisplay.inline) {
        final double minI = computeMinIntrinsicWidth(double.infinity);
        final double maxI = computeMaxIntrinsicWidth(double.infinity);
        final double available = availableBorderBoxWidth;
        intrinsicBorderBox = math.min(maxI, math.max(minI, available));
      } else if (_width is FitContent) {
        final double minI = computeMinIntrinsicWidth(double.infinity);
        final double maxI = computeMaxIntrinsicWidth(double.infinity);
        final double available = availableBorderBoxWidth;
        intrinsicBorderBox = math.min(maxI, math.max(minI, available));
      } else if (_width is AutoSize) {
        intrinsicBorderBox = computeMaxIntrinsicWidth(double.infinity);
      } else {
        intrinsicBorderBox = 0.0;
      }

      sizingWidth = _boxSizing == HtmlBoxSizing.borderBox
          ? intrinsicBorderBox
          : math.max(0.0, intrinsicBorderBox - borderHorizontal);
    }

    if (minW != null) sizingWidth = math.max(sizingWidth, minW);
    if (maxW != null) sizingWidth = math.min(sizingWidth, maxW);

    double borderBoxWidth = _boxSizing == HtmlBoxSizing.borderBox
        ? sizingWidth
        : sizingWidth + borderHorizontal + paddingHorizontal;
    borderBoxWidth = constraints.constrainWidth(borderBoxWidth);

    final double contentWidth = math.max(
      0.0,
      borderBoxWidth - borderHorizontal - paddingHorizontal,
    );

    double yOffset = _computedBorderWidths.top + _computedPadding.top;
    double xOffset = _computedBorderWidths.left + _computedPadding.left;
    double currentY = yOffset;
    double prevBottom = 0;

    if (_display == HtmlDisplay.flex) {
      final double contentHeight = _performFlexLayout(
        contentWidth: contentWidth,
        xOffset: xOffset,
        yOffset: yOffset,
        availableBorderBoxHeight: availableBorderBoxHeight,
        borderVertical: borderVertical,
        paddingVertical: paddingVertical,
      );

      double? minH = resolveSizingLimit(_minHeight, isWidthAxis: false);
      double? maxH = resolveSizingLimit(_maxHeight, isWidthAxis: false);
      if (minH != null && maxH != null && maxH < minH) {
        maxH = minH;
      }

      double sizingHeight;
      if (_height is FixedSize) {
        sizingHeight = (_height as FixedSize).value;
      } else if (_height is PercentSize && constraints.hasBoundedHeight) {
        sizingHeight =
            constraints.maxHeight * (_height as PercentSize).value / 100.0;
      } else {
        // auto height depends on boxSizing.
        sizingHeight = _boxSizing == HtmlBoxSizing.borderBox
            ? (contentHeight + borderVertical + paddingVertical)
            : contentHeight;
      }

      if (minH != null) sizingHeight = math.max(sizingHeight, minH);
      if (maxH != null) sizingHeight = math.min(sizingHeight, maxH);

      double borderBoxHeight;
      if (_boxSizing == HtmlBoxSizing.borderBox) {
        borderBoxHeight = sizingHeight;
      } else {
        borderBoxHeight = sizingHeight + borderVertical + paddingVertical;
      }
      borderBoxHeight = constraints.constrainHeight(borderBoxHeight);

      size = Size(borderBoxWidth, borderBoxHeight);
      return;
    }

    bool inInlineRun = false;
    final List<RenderBox> lineChildren = <RenderBox>[];
    final List<EdgeInsets> lineMargins = <EdgeInsets>[];
    final List<double> lineBaselines = <double>[];
    final List<double> lineXs = <double>[];
    double lineUsedWidth = 0;
    double lineAscent = 0;
    double lineDescent = 0;

    final double indentPx = _textIndent.resolvePx(reference: contentWidth);
    bool indentApplied = false;
    double currentLineIndent = 0;

    (double ascent, double descent) applyLineHeight(
      double ascent,
      double descent,
    ) {
      final double natural = ascent + descent;
      if (natural <= 0) return (ascent, descent);
      final HtmlLength? lh = _lineHeight;
      if (lh == null || lh.isAuto) return (ascent, descent);
      final double target = lh.resolvePx(reference: natural);
      if (!target.isFinite) return (ascent, descent);
      final double delta = target - natural;
      final double half = delta / 2.0;
      return (math.max(0.0, ascent + half), math.max(0.0, descent + half));
    }

    double flushLine({required bool isLastLine}) {
      if (lineChildren.isEmpty) return 0;

      final (double finalAscent, double finalDescent) = applyLineHeight(
        lineAscent,
        lineDescent,
      );

      final double lineHeight = finalAscent + finalDescent;
      final double availableWidth = math.max(
        0.0,
        contentWidth - currentLineIndent,
      );
      final double extraSpace = math.max(0.0, availableWidth - lineUsedWidth);

      double startShift = 0;
      double gapExtra = 0;

      if (_textAlign == HtmlTextAlign.center) {
        startShift = extraSpace / 2.0;
      } else if (_textAlign == HtmlTextAlign.end) {
        startShift = extraSpace;
      } else if (_textAlign == HtmlTextAlign.justify &&
          !isLastLine &&
          lineChildren.length > 1) {
        gapExtra = extraSpace / (lineChildren.length - 1);
      }

      final double baselineY = currentY + finalAscent;
      for (int i = 0; i < lineChildren.length; i++) {
        final RenderBox c = lineChildren[i];
        final HtmlDivParentData pd = c.parentData as HtmlDivParentData;
        final EdgeInsets m = lineMargins[i];
        final double baselineDistance = lineBaselines[i];
        final double childTop = baselineY - baselineDistance;
        final double childLeft =
            xOffset +
            currentLineIndent +
            startShift +
            lineXs[i] +
            (gapExtra * i) +
            m.left;
        pd.offset = Offset(childLeft, childTop);
      }

      lineChildren.clear();
      lineMargins.clear();
      lineBaselines.clear();
      lineXs.clear();
      lineUsedWidth = 0;
      lineAscent = 0;
      lineDescent = 0;

      if (!indentApplied) {
        indentApplied = true;
      }
      currentLineIndent = 0;
      return lineHeight;
    }

    RenderBox? child = firstChild;
    while (child != null) {
      final HtmlDivParentData childParentData =
          child.parentData as HtmlDivParentData;

      final HtmlDisplay childDisplay = _readChildHtmlDisplay(child);
      final bool isInline = childDisplay == HtmlDisplay.inline;

      if (isInline) {
        if (!inInlineRun) {
          // Inline content does not participate in margin collapsing.
          currentY += prevBottom;
          prevBottom = 0;
          inInlineRun = true;
          lineChildren.clear();
          lineMargins.clear();
          lineBaselines.clear();
          lineXs.clear();
          lineUsedWidth = 0;
          lineAscent = 0;
          lineDescent = 0;
          currentLineIndent = indentApplied ? 0.0 : indentPx;
        }

        if (lineChildren.isEmpty) {
          currentLineIndent = indentApplied ? 0.0 : indentPx;
        }

        final EdgeInsets m = _resolveChildMargin(child, contentWidth);
        final double availableWidth = math.max(
          0.0,
          contentWidth - currentLineIndent,
        );
        final double childMaxWidth = math.max(
          0.0,
          availableWidth - m.horizontal,
        );
        child.layout(
          BoxConstraints(maxWidth: childMaxWidth),
          parentUsesSize: true,
        );

        double inlineBoxWidth = m.left + child.size.width + m.right;
        double wrapWidth = math.max(0.0, contentWidth - currentLineIndent);
        if (lineUsedWidth > 0 && lineUsedWidth + inlineBoxWidth > wrapWidth) {
          currentY += flushLine(isLastLine: false);

          // New line may have different available width (e.g. first line had indent).
          if (lineChildren.isEmpty) {
            currentLineIndent = indentApplied ? 0.0 : indentPx;
          }
          final double newAvailableWidth = math.max(
            0.0,
            contentWidth - currentLineIndent,
          );
          final double newChildMaxWidth = math.max(
            0.0,
            newAvailableWidth - m.horizontal,
          );
          child.layout(
            BoxConstraints(maxWidth: newChildMaxWidth),
            parentUsesSize: true,
          );
          inlineBoxWidth = m.left + child.size.width + m.right;
          wrapWidth = newAvailableWidth;
        }

        final double baselineDistance =
            child.getDistanceToBaseline(TextBaseline.alphabetic) ??
            child.size.height;
        final double ascent = m.top + baselineDistance;
        final double descent =
            (child.size.height - baselineDistance) + m.bottom;
        lineAscent = math.max(lineAscent, ascent);
        lineDescent = math.max(lineDescent, descent);

        lineChildren.add(child);
        lineMargins.add(m);
        lineBaselines.add(baselineDistance);
        lineXs.add(lineUsedWidth);
        lineUsedWidth += inlineBoxWidth;

        child = childParentData.nextSibling;
        continue;
      }

      if (inInlineRun) {
        currentY += flushLine(isLastLine: true);
        inInlineRun = false;
        prevBottom = 0;
      }

      final HtmlMargin? childMarginObj = _readChildHtmlMargin(child);
      final EdgeInsets m = _resolveChildMargin(child, contentWidth);
      final double collapsed = _collapseMargins(prevBottom, m.top);
      currentY += collapsed;

      final double childMaxWidth = math.max(0.0, contentWidth - m.horizontal);
      final BoxConstraints childConstraints = BoxConstraints(
        maxWidth: childMaxWidth,
      );
      child.layout(childConstraints, parentUsesSize: true);

      double autoLeft = 0;
      if (childMarginObj != null &&
          (childMarginObj.left.isAuto || childMarginObj.right.isAuto)) {
        final double fixedHorizontal =
            (childMarginObj.left.isAuto ? 0.0 : m.left) +
            (childMarginObj.right.isAuto ? 0.0 : m.right);
        final double remaining = math.max(
          0.0,
          contentWidth - fixedHorizontal - child.size.width,
        );
        if (childMarginObj.left.isAuto && childMarginObj.right.isAuto) {
          autoLeft = remaining / 2.0;
        } else if (childMarginObj.left.isAuto) {
          autoLeft = remaining;
        }
      }

      childParentData.offset = Offset(xOffset + m.left + autoLeft, currentY);
      currentY += child.size.height;
      prevBottom = m.bottom;

      child = childParentData.nextSibling;
    }

    if (inInlineRun) {
      currentY += flushLine(isLastLine: true);
      inInlineRun = false;
      prevBottom = 0;
    }

    final double contentHeight = (currentY - yOffset) + prevBottom;

    double? minH = resolveSizingLimit(_minHeight, isWidthAxis: false);
    double? maxH = resolveSizingLimit(_maxHeight, isWidthAxis: false);
    if (minH != null && maxH != null && maxH < minH) {
      maxH = minH;
    }

    double sizingHeight;
    if (_height is FixedSize) {
      sizingHeight = (_height as FixedSize).value;
    } else if (_height is PercentSize && constraints.hasBoundedHeight) {
      sizingHeight =
          constraints.maxHeight * (_height as PercentSize).value / 100.0;
    } else {
      // auto height depends on boxSizing.
      sizingHeight = _boxSizing == HtmlBoxSizing.borderBox
          ? (contentHeight + borderVertical)
          : contentHeight;
    }

    if (minH != null) sizingHeight = math.max(sizingHeight, minH);
    if (maxH != null) sizingHeight = math.min(sizingHeight, maxH);

    double borderBoxHeight;
    if (_boxSizing == HtmlBoxSizing.borderBox) {
      borderBoxHeight = sizingHeight;
    } else {
      borderBoxHeight = sizingHeight + borderVertical;
    }
    borderBoxHeight = constraints.constrainHeight(borderBoxHeight);

    size = Size(borderBoxWidth, borderBoxHeight);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Matrix4? t = _effectiveTransform();
    if (t == null) {
      _paintWithoutTransform(context, offset);
      return;
    }

    context.pushTransform(needsCompositing, offset, t, _paintWithoutTransform);
  }

  void _paintWithoutTransform(PaintingContext context, Offset offset) {
    _paintBoxShadowIfNeeded(context, offset, inset: false);
    _paintBackgroundIfNeeded(context, offset);
    _paintBoxShadowIfNeeded(context, offset, inset: true);
    final bool paintedBorderImage = _paintBorderImageIfNeeded(context, offset);
    if (!paintedBorderImage && _border != null) {
      if (_border!.isUniform) {
        _paintUniformBorder(context, offset);
      } else {
        _paintMixedBorder(context, offset);
      }
    }
    // Paint order policy:
    // - Paint all block-level children first.
    // - Then paint all inline-level children (on top), to match typical HTML expectations
    //   when inline content overlaps block backgrounds due to negative margins.
    if (_display == HtmlDisplay.flex) {
      defaultPaint(context, offset);
    } else {
      _paintChildrenSeparated(context, offset);
    }
  }

  void _paintChildrenSeparated(PaintingContext context, Offset offset) {
    RenderBox? child = firstChild;
    while (child != null) {
      final HtmlDivParentData childParentData =
          child.parentData! as HtmlDivParentData;
      final bool inlineLayer = _paintsInInlineLayer(child);
      if (!inlineLayer) {
        context.paintChild(child, childParentData.offset + offset);
      }
      child = childParentData.nextSibling;
    }

    child = firstChild;
    while (child != null) {
      final HtmlDivParentData childParentData =
          child.parentData! as HtmlDivParentData;
      final bool inlineLayer = _paintsInInlineLayer(child);
      if (inlineLayer) {
        context.paintChild(child, childParentData.offset + offset);
      }
      child = childParentData.nextSibling;
    }
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    final Matrix4? t = _effectiveTransform();
    if (t == null) {
      return super.hitTest(result, position: position);
    }
    return result.addWithPaintTransform(
      transform: t,
      position: position,
      hitTest: (BoxHitTestResult result, Offset transformed) {
        return super.hitTest(result, position: transformed);
      },
    );
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    super.applyPaintTransform(child, transform);
    final Matrix4? t = _effectiveTransform();
    if (t != null) {
      transform.multiply(t);
    }
  }

  void _paintBoxShadowIfNeeded(
    PaintingContext context,
    Offset offset, {
    required bool inset,
  }) {
    if (_boxShadow.isEmpty) return;

    final Rect borderBox = offset & size;
    if (borderBox.isEmpty) return;

    final Canvas canvas = context.canvas;
    final HtmlBorderRadius? br = _borderRadius;
    final bool hasRadius =
        br != null && br.toBorderRadius() != BorderRadius.zero;
    final RRect? baseRRect = hasRadius
        ? br.toBorderRadius().toRRect(borderBox)
        : null;

    // CSS draws the first shadow on top.
    for (int i = _boxShadow.length - 1; i >= 0; i--) {
      final HtmlBoxShadow s = _boxShadow[i];
      if (s.inset != inset) continue;

      final Offset shadowOffset = s.offset.resolveForSize(borderBox.size);

      final Paint paint = BoxShadow(
        color: s.color,
        blurRadius: s.blurRadius,
      ).toPaint();

      if (!inset) {
        if (baseRRect != null) {
          final RRect rr = baseRRect
              .shift(shadowOffset)
              .inflate(s.spreadRadius);
          canvas.drawRRect(rr, paint);
        } else {
          final Rect r = borderBox.shift(shadowOffset).inflate(s.spreadRadius);
          canvas.drawRect(r, paint);
        }
        continue;
      }

      // Inset shadow approximation:
      // Draw a blurred ring (outer - shifted/deflated inner) clipped to the border box.
      canvas.save();
      if (baseRRect != null) {
        canvas.clipRRect(baseRRect);
        final Path outer = Path()..addRRect(baseRRect);
        final Offset invOffset = Offset(-shadowOffset.dx, -shadowOffset.dy);
        final RRect inner = baseRRect.deflate(s.spreadRadius).shift(invOffset);
        final Path hole = Path()..addRRect(inner);
        final Path ring = Path.combine(
          ui.PathOperation.difference,
          outer,
          hole,
        );
        canvas.drawPath(ring, paint);
      } else {
        canvas.clipRect(borderBox);
        final Path outer = Path()..addRect(borderBox);
        final Offset invOffset = Offset(-shadowOffset.dx, -shadowOffset.dy);
        final Rect inner = borderBox.deflate(s.spreadRadius).shift(invOffset);
        final Path hole = Path()..addRect(inner);
        final Path ring = Path.combine(
          ui.PathOperation.difference,
          outer,
          hole,
        );
        canvas.drawPath(ring, paint);
      }
      canvas.restore();
    }
  }

  void _paintBackgroundIfNeeded(PaintingContext context, Offset offset) {
    final HtmlBackground? bg = _background;
    if (bg == null) return;

    final Rect borderBox = offset & size;
    final Rect clipRect;
    if (bg.clip == HtmlBackgroundClip.borderBox) {
      clipRect = borderBox;
    } else {
      final EdgeInsets bw = _computedBorderWidths;
      clipRect = Rect.fromLTRB(
        borderBox.left + bw.left,
        borderBox.top + bw.top,
        borderBox.right - bw.right,
        borderBox.bottom - bw.bottom,
      );
    }
    if (clipRect.isEmpty) return;

    final Canvas canvas = context.canvas;
    final HtmlBorderRadius? br = _borderRadius;
    final bool needsClip =
        br != null && br.toBorderRadius() != BorderRadius.zero;

    canvas.save();
    if (needsClip) {
      final RRect rrect = br.toBorderRadius().toRRect(clipRect);
      canvas.clipRRect(rrect);
    } else {
      canvas.clipRect(clipRect);
    }

    final Color? bgColor = bg.color;
    if (bgColor != null) {
      canvas.drawRect(clipRect, Paint()..color = bgColor);
    }

    final HtmlBackgroundImage? bgImage = bg.image;
    final ImageInfo? info = _backgroundImageInfo;
    if (bgImage != null && info != null) {
      _paintBackgroundImage(
        canvas: canvas,
        rect: clipRect,
        bg: bgImage,
        info: info,
      );
    }

    canvas.restore();
  }

  Size _resolveBackgroundImageDestSize({
    required HtmlBackgroundSize size,
    required Size imageSize,
    required Size dstRectSize,
  }) {
    switch (size.type) {
      case HtmlBackgroundSizeType.auto:
        return imageSize;
      case HtmlBackgroundSizeType.contain:
        final double sx = dstRectSize.width / imageSize.width;
        final double sy = dstRectSize.height / imageSize.height;
        final double s = math.min(sx, sy);
        return Size(imageSize.width * s, imageSize.height * s);
      case HtmlBackgroundSizeType.cover:
        final double sx = dstRectSize.width / imageSize.width;
        final double sy = dstRectSize.height / imageSize.height;
        final double s = math.max(sx, sy);
        return Size(imageSize.width * s, imageSize.height * s);
      case HtmlBackgroundSizeType.explicit:
        final double w =
            size.width?.resolvePx(reference: dstRectSize.width) ??
            imageSize.width;
        final double h =
            size.height?.resolvePx(reference: dstRectSize.height) ??
            imageSize.height;
        return Size(w, h);
    }
  }

  List<_BackgroundAxisTile> _computeAxisTiles({
    required double start,
    required double extent,
    required double tileExtent,
    required HtmlBackgroundRepeat repeat,
  }) {
    if (tileExtent <= 0 || extent <= 0) return const <_BackgroundAxisTile>[];

    switch (repeat) {
      case HtmlBackgroundRepeat.noRepeat:
        return <_BackgroundAxisTile>[
          const _BackgroundAxisTile(offset: 0, spacing: 0, count: 1),
        ];
      case HtmlBackgroundRepeat.repeat:
        // We'll use the raw tiling loop; spacing=0.
        return <_BackgroundAxisTile>[
          const _BackgroundAxisTile(offset: 0, spacing: 0, count: -1),
        ];
      case HtmlBackgroundRepeat.round:
        final int count = math.max(1, (extent / tileExtent).round());
        final double newTile = extent / count;
        return <_BackgroundAxisTile>[
          _BackgroundAxisTile(
            offset: 0,
            spacing: 0,
            count: count,
            overrideTileExtent: newTile,
          ),
        ];
      case HtmlBackgroundRepeat.space:
        final int count = (extent / tileExtent).floor();
        if (count <= 1) {
          return <_BackgroundAxisTile>[
            const _BackgroundAxisTile(offset: 0, spacing: 0, count: 1),
          ];
        }
        final double spacing = (extent - (count * tileExtent)) / (count - 1);
        return <_BackgroundAxisTile>[
          _BackgroundAxisTile(offset: 0, spacing: spacing, count: count),
        ];
    }
  }

  void _paintBackgroundImage({
    required Canvas canvas,
    required Rect rect,
    required HtmlBackgroundImage bg,
    required ImageInfo info,
  }) {
    final ui.Image image = info.image;
    final double logicalW = image.width.toDouble() / info.scale;
    final double logicalH = image.height.toDouble() / info.scale;
    final Size imageSize = Size(logicalW, logicalH);

    final Size dstSize = _resolveBackgroundImageDestSize(
      size: bg.size,
      imageSize: imageSize,
      dstRectSize: rect.size,
    );
    if (dstSize.isEmpty) return;

    final Alignment a = bg.position.alignment;
    final double ax = (a.x + 1) / 2.0;
    final double ay = (a.y + 1) / 2.0;
    final Offset posOffset = bg.position.offset.resolveForSize(rect.size);
    final double baseLeft =
        rect.left + (rect.width - dstSize.width) * ax + posOffset.dx;
    final double baseTop =
        rect.top + (rect.height - dstSize.height) * ay + posOffset.dy;

    final Rect src = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );

    // Determine tiling in X/Y.
    final List<_BackgroundAxisTile> xTiles = _computeAxisTiles(
      start: rect.left,
      extent: rect.width,
      tileExtent: dstSize.width,
      repeat: bg.repeatX,
    );
    final List<_BackgroundAxisTile> yTiles = _computeAxisTiles(
      start: rect.top,
      extent: rect.height,
      tileExtent: dstSize.height,
      repeat: bg.repeatY,
    );
    if (xTiles.isEmpty || yTiles.isEmpty) return;

    double tileW = dstSize.width;
    double tileH = dstSize.height;
    if (xTiles.first.overrideTileExtent != null) {
      tileW = xTiles.first.overrideTileExtent!;
    }
    if (yTiles.first.overrideTileExtent != null) {
      tileH = yTiles.first.overrideTileExtent!;
    }

    // Repeat mode uses positioning origin; round/space use rect-start for simplicity.
    double startX;
    if (bg.repeatX == HtmlBackgroundRepeat.repeat) {
      startX = baseLeft;
      while (startX > rect.left) {
        startX -= tileW;
      }
    } else {
      startX = rect.left;
    }

    double startY;
    if (bg.repeatY == HtmlBackgroundRepeat.repeat) {
      startY = baseTop;
      while (startY > rect.top) {
        startY -= tileH;
      }
    } else {
      startY = rect.top;
    }

    final Paint paint = Paint()..filterQuality = FilterQuality.low;

    for (final _BackgroundAxisTile xt in xTiles) {
      for (final _BackgroundAxisTile yt in yTiles) {
        if (xt.count == 1 &&
            yt.count == 1 &&
            bg.repeatX == HtmlBackgroundRepeat.noRepeat &&
            bg.repeatY == HtmlBackgroundRepeat.noRepeat) {
          final Rect dst = Rect.fromLTWH(baseLeft, baseTop, tileW, tileH);
          if (dst.overlaps(rect)) canvas.drawImageRect(image, src, dst, paint);
          continue;
        }

        final int xCount = xt.count < 0
            ? ((rect.right - startX) / tileW).ceil() + 2
            : xt.count;
        final int yCount = yt.count < 0
            ? ((rect.bottom - startY) / tileH).ceil() + 2
            : yt.count;
        final double xSpacing = xt.spacing;
        final double ySpacing = yt.spacing;

        for (int ix = 0; ix < xCount; ix++) {
          final double dx = (bg.repeatX == HtmlBackgroundRepeat.repeat)
              ? startX + ix * tileW
              : rect.left + ix * (tileW + xSpacing);
          if (dx >= rect.right) break;
          if (dx + tileW <= rect.left) continue;

          for (int iy = 0; iy < yCount; iy++) {
            final double dy = (bg.repeatY == HtmlBackgroundRepeat.repeat)
                ? startY + iy * tileH
                : rect.top + iy * (tileH + ySpacing);
            if (dy >= rect.bottom) break;
            if (dy + tileH <= rect.top) continue;

            final Rect dst = Rect.fromLTWH(dx, dy, tileW, tileH);
            if (dst.overlaps(rect)) {
              canvas.drawImageRect(image, src, dst, paint);
            }
          }
        }
      }
    }
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
    if (_display == HtmlDisplay.flex) {
      return defaultHitTestChildren(result, position: position);
    }
    final List<RenderBox> blockChildren = <RenderBox>[];
    final List<RenderBox> inlineChildren = <RenderBox>[];

    RenderBox? child = firstChild;
    while (child != null) {
      final HtmlDivParentData childParentData =
          child.parentData! as HtmlDivParentData;
      final bool inlineLayer = _paintsInInlineLayer(child);
      (inlineLayer ? inlineChildren : blockChildren).add(child);
      child = childParentData.nextSibling;
    }

    bool hitTestChild(RenderBox child) {
      final HtmlDivParentData childParentData =
          child.parentData! as HtmlDivParentData;
      return result.addWithPaintOffset(
        offset: childParentData.offset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          return child.hitTest(result, position: transformed);
        },
      );
    }

    // Inline children paint last => hit test first.
    for (int i = inlineChildren.length - 1; i >= 0; i--) {
      if (hitTestChild(inlineChildren[i])) return true;
    }

    for (int i = blockChildren.length - 1; i >= 0; i--) {
      if (hitTestChild(blockChildren[i])) return true;
    }

    return false;
  }
}
