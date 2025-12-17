import 'package:flutter/widgets.dart';

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
