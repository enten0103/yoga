import 'package:flutter/widgets.dart';

// Unified length value
//
// Supports:
// - px
// - percent (of a provided reference)
// - multiplier (unitless; scales a provided reference)
// - auto

enum HtmlLengthUnit { px, percent, multiplier, auto }

class HtmlLength {
  final double value;
  final HtmlLengthUnit unit;

  const HtmlLength._(this.value, this.unit);

  const HtmlLength.px(double value) : this._(value, HtmlLengthUnit.px);
  const HtmlLength.percent(double value)
    : this._(value, HtmlLengthUnit.percent);

  /// Unitless multiplier that scales a provided reference.
  ///
  /// Intended primarily for CSS-like `line-height: <number>` (e.g. 1.3).
  ///
  /// Example:
  /// - `HtmlLength.multiplier(1.3).resolvePx(reference: naturalLineHeight)`
  ///   => `naturalLineHeight * 1.3`
  const HtmlLength.multiplier(double value)
    : this._(value, HtmlLengthUnit.multiplier);
  const HtmlLength.auto() : this._(0, HtmlLengthUnit.auto);

  bool get isAuto => unit == HtmlLengthUnit.auto;
  bool get isPercent => unit == HtmlLengthUnit.percent;
  bool get isMultiplier => unit == HtmlLengthUnit.multiplier;

  double resolvePx({required double reference}) {
    switch (unit) {
      case HtmlLengthUnit.px:
        return value;
      case HtmlLengthUnit.percent:
        return reference * value / 100.0;
      case HtmlLengthUnit.multiplier:
        return reference * value;
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
