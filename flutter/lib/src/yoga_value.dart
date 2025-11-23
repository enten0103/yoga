enum YogaUnit { point, percent, auto, undefined }

class YogaValue {
  final double value;
  final YogaUnit unit;

  const YogaValue.point(this.value) : unit = YogaUnit.point;
  const YogaValue.percent(this.value) : unit = YogaUnit.percent;
  const YogaValue.auto() : value = double.nan, unit = YogaUnit.auto;
  const YogaValue.undefined() : value = double.nan, unit = YogaUnit.undefined;

  static const zero = YogaValue.point(0);

  // Helpers for common cases
  static YogaValue of(double value) => YogaValue.point(value);
  static YogaValue pt(double value) => YogaValue.point(value);
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

class YogaEdgeInsets {
  final YogaValue left;
  final YogaValue top;
  final YogaValue right;
  final YogaValue bottom;

  const YogaEdgeInsets.all(YogaValue value)
    : left = value,
      top = value,
      right = value,
      bottom = value;

  const YogaEdgeInsets.symmetric({
    YogaValue vertical = YogaValue.zero,
    YogaValue horizontal = YogaValue.zero,
  }) : left = horizontal,
       top = vertical,
       right = horizontal,
       bottom = vertical;

  const YogaEdgeInsets.only({
    this.left = YogaValue.zero,
    this.top = YogaValue.zero,
    this.right = YogaValue.zero,
    this.bottom = YogaValue.zero,
  });

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
