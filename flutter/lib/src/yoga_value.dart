import 'package:flutter/painting.dart';

/// Units used in Yoga layout.
enum YogaUnit {
  /// A specific number of points (pixels).
  point,

  /// A percentage of the parent's size.
  percent,

  /// The value is calculated automatically by the layout engine.
  auto,

  /// The value is undefined.
  undefined,
}

/// Controls how the size of a box is calculated.
enum YogaBoxSizing {
  /// The width and height properties include the content, padding, and border, but not the margin.
  borderBox,

  /// The width and height properties include only the content. Border and padding are added outside.
  contentBox,
}

/// Controls how content that overflows its box is handled.
enum YogaOverflow {
  /// Content is not clipped and may be rendered outside the box.
  visible,

  /// Content is clipped if necessary to fit the padding box.
  hidden,

  /// Content is clipped and a scroll mechanism is provided (not fully supported in all contexts).
  scroll,
}

/// Represents a value in the Yoga layout system.
///
/// A value can be a specific point value, a percentage, auto, or undefined.
class YogaValue {
  /// The numeric value. Only valid if [unit] is [YogaUnit.point] or [YogaUnit.percent].
  final double value;

  /// The unit of this value.
  final YogaUnit unit;

  /// Creates a value in points.
  const YogaValue.point(this.value) : unit = YogaUnit.point;

  /// Creates a value as a percentage.
  const YogaValue.percent(this.value) : unit = YogaUnit.percent;

  /// Creates an auto value.
  const YogaValue.auto() : value = double.nan, unit = YogaUnit.auto;

  /// Creates an undefined value.
  const YogaValue.undefined() : value = double.nan, unit = YogaUnit.undefined;

  /// A value of 0 points.
  static const zero = YogaValue.point(0);

  // Helpers for common cases

  /// Creates a point value.
  static YogaValue of(double value) => YogaValue.point(value);

  /// Alias for [YogaValue.point].
  static YogaValue pt(double value) => YogaValue.point(value);

  /// Alias for [YogaValue.percent].
  static YogaValue pct(double value) => YogaValue.percent(value);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is YogaValue && other.value == value && other.unit == unit;
  }

  @override
  int get hashCode => Object.hash(value, unit);

  @override
  String toString() {
    switch (unit) {
      case YogaUnit.point:
        return '${value}px';
      case YogaUnit.percent:
        return '$value%';
      case YogaUnit.auto:
        return 'auto';
      case YogaUnit.undefined:
        return 'undefined';
    }
  }
}

/// Immutable set of offsets in each of the four cardinal directions.
///
/// Similar to Flutter's [EdgeInsets], but uses [YogaValue] to support percentages and auto.
class YogaEdgeInsets {
  /// The offset from the left.
  final YogaValue left;

  /// The offset from the top.
  final YogaValue top;

  /// The offset from the right.
  final YogaValue right;

  /// The offset from the bottom.
  final YogaValue bottom;

  /// Creates insets where all offsets are value.
  const YogaEdgeInsets.all(YogaValue value)
    : left = value,
      top = value,
      right = value,
      bottom = value;

  /// Creates insets with symmetrical vertical and horizontal offsets.
  const YogaEdgeInsets.symmetric({
    YogaValue vertical = YogaValue.zero,
    YogaValue horizontal = YogaValue.zero,
  }) : left = horizontal,
       top = vertical,
       right = horizontal,
       bottom = vertical;

  /// Creates insets with only the given values non-zero.
  const YogaEdgeInsets.only({
    this.left = YogaValue.zero,
    this.top = YogaValue.zero,
    this.right = YogaValue.zero,
    this.bottom = YogaValue.zero,
  });

  /// An [YogaEdgeInsets] with zero offsets.
  static const zero = YogaEdgeInsets.all(YogaValue.point(0));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is YogaEdgeInsets &&
        other.left == left &&
        other.top == top &&
        other.right == right &&
        other.bottom == bottom;
  }

  @override
  int get hashCode => Object.hash(left, top, right, bottom);

  @override
  String toString() =>
      'YogaEdgeInsets(left: $left, top: $top, right: $right, bottom: $bottom)';
}

/// A shadow cast by a box.
///
/// Similar to Flutter's [BoxShadow], but uses [YogaValue] for offsets and radii to support percentages.
class YogaBoxShadow {
  /// The color of the shadow.
  final Color color;

  /// The horizontal offset of the shadow.
  final YogaValue offsetDX;

  /// The vertical offset of the shadow.
  final YogaValue offsetDY;

  /// The standard deviation of the Gaussian to convolute with the box's shape.
  final YogaValue blurRadius;

  /// The amount the box should be inflated prior to applying the blur.
  final YogaValue spreadRadius;

  /// The style of the blur.
  final BlurStyle blurStyle;

  /// Creates a box shadow.
  const YogaBoxShadow({
    this.color = const Color(0xFF000000),
    this.offsetDX = YogaValue.zero,
    this.offsetDY = YogaValue.zero,
    this.blurRadius = YogaValue.zero,
    this.spreadRadius = YogaValue.zero,
    this.blurStyle = BlurStyle.normal,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is YogaBoxShadow &&
        other.color == color &&
        other.offsetDX == offsetDX &&
        other.offsetDY == offsetDY &&
        other.blurRadius == blurRadius &&
        other.spreadRadius == spreadRadius &&
        other.blurStyle == blurStyle;
  }

  @override
  int get hashCode => Object.hash(
    color,
    offsetDX,
    offsetDY,
    blurRadius,
    spreadRadius,
    blurStyle,
  );
}
