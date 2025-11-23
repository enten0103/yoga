import 'package:flutter/painting.dart';
import 'yoga_value.dart';

/// The style of a border.
enum YogaBorderStyle {
  /// No border.
  none,

  /// Same as none, but has different behavior in border conflict resolution (not fully applicable here).
  hidden,

  /// A series of round dots.
  dotted,

  /// A series of short square-ended dashes.
  dashed,

  /// A single solid line.
  solid,

  /// Two parallel solid lines with some space between them.
  double,

  /// Looks as if it were carved in the canvas.
  groove,

  /// Looks as if it were coming out of the canvas.
  ridge,

  /// Looks as if the content inside the border is sunken.
  inset,

  /// Looks as if the content inside the border is coming out of the canvas.
  outset,
}

/// How the image should be repeated to fill the area.
enum YogaBorderImageRepeat {
  /// The image is stretched to fill the area.
  stretch,

  /// The image is tiled (repeated) to fill the area.
  repeat,

  /// The image is tiled (repeated) to fill the area. If it doesn't fit a whole number of times, it is rescaled so that it does.
  round,

  /// The image is tiled (repeated) to fill the area. If it doesn't fit a whole number of times, the extra space is distributed around the tiles.
  space,
}

/// A side of a border of a box.
class YogaBorderSide {
  /// The color of this side of the border.
  final Color? color;

  /// The width of this side of the border.
  final double? width;

  /// The style of this side of the border.
  final YogaBorderStyle? style;

  /// Creates the side of a border.
  const YogaBorderSide({this.color, this.width, this.style});

  /// A border side that is invisible.
  static const YogaBorderSide none = YogaBorderSide(
    width: 0.0,
    style: YogaBorderStyle.none,
  );

  /// Creates a copy of this border side with the given fields replaced with the new values.
  YogaBorderSide copyWith({
    Color? color,
    double? width,
    YogaBorderStyle? style,
  }) {
    return YogaBorderSide(
      color: color ?? this.color,
      width: width ?? this.width,
      style: style ?? this.style,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is YogaBorderSide &&
        other.color == color &&
        other.width == width &&
        other.style == style;
  }

  @override
  int get hashCode => Object.hash(color, width, style);

  /// Converts this [YogaBorderSide] to a Flutter [BorderSide].
  BorderSide toFlutterBorderSide() {
    if (style == YogaBorderStyle.none || style == YogaBorderStyle.hidden) {
      return BorderSide.none;
    }
    return BorderSide(
      color: color ?? const Color(0xFF000000),
      width: width ?? 1.0,
      style: style == YogaBorderStyle.none
          ? BorderStyle.none
          : BorderStyle.solid,
      // Flutter only supports solid and none natively in BorderSide.
      // We might need custom painting for dashed/dotted if we want full CSS support.
      // For now, map everything to solid except none.
    );
  }
}

/// A set of immutable radii for each corner of a rectangle.
///
/// Similar to Flutter's [BorderRadius], but uses [YogaValue] to support percentages.
class YogaBorderRadius {
  /// The top-left radius.
  final YogaValue? topLeft;

  /// The top-right radius.
  final YogaValue? topRight;

  /// The bottom-left radius.
  final YogaValue? bottomLeft;

  /// The bottom-right radius.
  final YogaValue? bottomRight;

  /// The start-start radius (logical).
  final YogaValue? startStart;

  /// The start-end radius (logical).
  final YogaValue? startEnd;

  /// The end-start radius (logical).
  final YogaValue? endStart;

  /// The end-end radius (logical).
  final YogaValue? endEnd;

  /// Creates a border radius with the given radii.
  const YogaBorderRadius({
    this.topLeft,
    this.topRight,
    this.bottomLeft,
    this.bottomRight,
    this.startStart,
    this.startEnd,
    this.endStart,
    this.endEnd,
  });

  /// A border radius with all zero radii.
  static const YogaBorderRadius zero = YogaBorderRadius(
    topLeft: YogaValue.zero,
    topRight: YogaValue.zero,
    bottomLeft: YogaValue.zero,
    bottomRight: YogaValue.zero,
  );

  /// Creates a border radius where all radii are [radius].
  const YogaBorderRadius.all(YogaValue radius)
    : topLeft = radius,
      topRight = radius,
      bottomLeft = radius,
      bottomRight = radius,
      startStart = null,
      startEnd = null,
      endStart = null,
      endEnd = null;

  /// Creates a border radius where all radii are [radius] (in points).
  factory YogaBorderRadius.circular(double radius) =>
      YogaBorderRadius.all(YogaValue.point(radius));

  /// Resolves logical radii to physical radii based on the text direction.
  YogaBorderRadius resolve(TextDirection direction) {
    // Resolve logical to physical
    YogaValue? tl = topLeft;
    YogaValue? tr = topRight;
    YogaValue? bl = bottomLeft;
    YogaValue? br = bottomRight;

    if (direction == TextDirection.ltr) {
      tl ??= startStart;
      tr ??= startEnd;
      bl ??= endStart;
      br ??= endEnd;
    } else {
      tl ??= startEnd;
      tr ??= startStart;
      bl ??= endEnd;
      br ??= endStart;
    }

    return YogaBorderRadius(
      topLeft: tl ?? YogaValue.zero,
      topRight: tr ?? YogaValue.zero,
      bottomLeft: bl ?? YogaValue.zero,
      bottomRight: br ?? YogaValue.zero,
    );
  }

  /// Converts this [YogaBorderRadius] to a Flutter [BorderRadius].
  BorderRadius toFlutterBorderRadius(Size size) {
    Radius resolveRadius(YogaValue? v) {
      if (v == null) return Radius.zero;
      switch (v.unit) {
        case YogaUnit.point:
          return Radius.circular(v.value);
        case YogaUnit.percent:
          return Radius.elliptical(
            v.value * size.width / 100,
            v.value * size.height / 100,
          );
        case YogaUnit.auto:
        case YogaUnit.undefined:
        case YogaUnit.maxContent:
        case YogaUnit.minContent:
        case YogaUnit.fitContent:
          return Radius.zero;
      }
    }

    return BorderRadius.only(
      topLeft: resolveRadius(topLeft),
      topRight: resolveRadius(topRight),
      bottomLeft: resolveRadius(bottomLeft),
      bottomRight: resolveRadius(bottomRight),
    );
  }
}

/// A border of a box, comprised of four sides and a border radius.
class YogaBorder {
  // Physical
  /// The top side of this border.
  final YogaBorderSide? top;

  /// The right side of this border.
  final YogaBorderSide? right;

  /// The bottom side of this border.
  final YogaBorderSide? bottom;

  /// The left side of this border.
  final YogaBorderSide? left;

  // Logical
  /// The start side of this border (logical).
  final YogaBorderSide? start; // inline-start

  /// The end side of this border (logical).
  final YogaBorderSide? end; // inline-end

  /// The block-start side of this border (logical).
  final YogaBorderSide? blockStart;

  /// The block-end side of this border (logical).
  final YogaBorderSide? blockEnd;

  // Global
  /// A side representing all sides of this border.
  final YogaBorderSide? all;

  /// The radii for each corner of the border.
  final YogaBorderRadius? borderRadius;

  /// An image to be used for the border.
  final YogaBorderImage? image;

  /// Creates a border.
  const YogaBorder({
    this.top,
    this.right,
    this.bottom,
    this.left,
    this.start,
    this.end,
    this.blockStart,
    this.blockEnd,
    this.all,
    this.borderRadius,
    this.image,
  });

  /// Creates a border with all sides the same.
  factory YogaBorder.all({
    Color color = const Color(0xFF000000),
    double width = 1.0,
    YogaBorderStyle style = YogaBorderStyle.solid,
    YogaBorderRadius? borderRadius,
  }) {
    return YogaBorder(
      all: YogaBorderSide(color: color, width: width, style: style),
      borderRadius: borderRadius,
    );
  }

  /// Resolves logical sides to physical sides based on the text direction.
  ResolvedYogaBorder resolve(TextDirection direction) {
    YogaBorderSide resolveSide(
      YogaBorderSide? specific,
      YogaBorderSide? logical,
      YogaBorderSide? global,
    ) {
      // Specific overrides logical overrides global
      // Merge properties
      Color? color = specific?.color ?? logical?.color ?? global?.color;
      double? width = specific?.width ?? logical?.width ?? global?.width;
      YogaBorderStyle? style =
          specific?.style ?? logical?.style ?? global?.style;

      return YogaBorderSide(color: color, width: width, style: style);
    }

    final YogaBorderSide? effectiveStart = direction == TextDirection.ltr
        ? start
        : end;
    final YogaBorderSide? effectiveEnd = direction == TextDirection.ltr
        ? end
        : start;

    // Assuming horizontal-tb writing mode for now
    final YogaBorderSide? effectiveBlockStart = blockStart;
    final YogaBorderSide? effectiveBlockEnd = blockEnd;

    return ResolvedYogaBorder(
      top: resolveSide(top, effectiveBlockStart, all),
      right: resolveSide(right, effectiveEnd, all),
      bottom: resolveSide(bottom, effectiveBlockEnd, all),
      left: resolveSide(left, effectiveStart, all),
      borderRadius: borderRadius?.resolve(direction) ?? YogaBorderRadius.zero,
    );
  }
}

/// A border where all logical sides have been resolved to physical sides.
class ResolvedYogaBorder {
  /// The top side.
  final YogaBorderSide top;

  /// The right side.
  final YogaBorderSide right;

  /// The bottom side.
  final YogaBorderSide bottom;

  /// The left side.
  final YogaBorderSide left;

  /// The border radius.
  final YogaBorderRadius borderRadius;

  /// Creates a resolved border.
  ResolvedYogaBorder({
    required this.top,
    required this.right,
    required this.bottom,
    required this.left,
    required this.borderRadius,
  });

  /// Whether all four sides are identical.
  bool get isUniform {
    return top == right && right == bottom && bottom == left;
  }

  /// Converts this [ResolvedYogaBorder] to a Flutter [Border].
  Border toFlutterBorder() {
    return Border(
      top: top.toFlutterBorderSide(),
      right: right.toFlutterBorderSide(),
      bottom: bottom.toFlutterBorderSide(),
      left: left.toFlutterBorderSide(),
    );
  }
}

/// An image to be used as a border.
class YogaBorderImage {
  /// The image to use.
  final ImageProvider source;

  /// The offsets that define the slicing lines for the image.
  final YogaEdgeInsets slice;

  /// Whether to fill the center of the border image.
  final bool fill;

  /// The width of the border image.
  final YogaEdgeInsets? width;

  /// The amount by which the border image area extends beyond the border box.
  final YogaEdgeInsets outset;

  /// How the image should be repeated to fill the area.
  final YogaBorderImageRepeat repeat;

  /// Creates a border image.
  const YogaBorderImage({
    required this.source,
    this.slice = YogaEdgeInsets.zero,
    this.fill = false,
    this.width,
    this.outset = YogaEdgeInsets.zero,
    this.repeat = YogaBorderImageRepeat.stretch,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is YogaBorderImage &&
        other.source == source &&
        other.slice == slice &&
        other.fill == fill &&
        other.width == width &&
        other.outset == outset &&
        other.repeat == repeat;
  }

  @override
  int get hashCode => Object.hash(source, slice, fill, width, outset, repeat);
}
