import 'package:flutter/painting.dart';
import 'yoga_value.dart';

enum YogaBorderStyle {
  none,
  hidden,
  dotted,
  dashed,
  solid,
  double,
  groove,
  ridge,
  inset,
  outset,
}

enum YogaBorderImageRepeat { stretch, repeat, round, space }

class YogaBorderSide {
  final Color? color;
  final double? width;
  final YogaBorderStyle? style;

  const YogaBorderSide({this.color, this.width, this.style});

  static const YogaBorderSide none = YogaBorderSide(
    width: 0.0,
    style: YogaBorderStyle.none,
  );

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

class YogaBorderRadius {
  final double? topLeft;
  final double? topRight;
  final double? bottomLeft;
  final double? bottomRight;
  final double? startStart;
  final double? startEnd;
  final double? endStart;
  final double? endEnd;

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

  static const YogaBorderRadius zero = YogaBorderRadius(
    topLeft: 0,
    topRight: 0,
    bottomLeft: 0,
    bottomRight: 0,
  );

  const YogaBorderRadius.all(double radius)
    : topLeft = radius,
      topRight = radius,
      bottomLeft = radius,
      bottomRight = radius,
      startStart = null,
      startEnd = null,
      endStart = null,
      endEnd = null;

  BorderRadius toFlutterBorderRadius(TextDirection direction) {
    // Resolve logical to physical
    double? tl = topLeft;
    double? tr = topRight;
    double? bl = bottomLeft;
    double? br = bottomRight;

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

    return BorderRadius.only(
      topLeft: Radius.circular(tl ?? 0),
      topRight: Radius.circular(tr ?? 0),
      bottomLeft: Radius.circular(bl ?? 0),
      bottomRight: Radius.circular(br ?? 0),
    );
  }
}

class YogaBorder {
  // Physical
  final YogaBorderSide? top;
  final YogaBorderSide? right;
  final YogaBorderSide? bottom;
  final YogaBorderSide? left;

  // Logical
  final YogaBorderSide? start; // inline-start
  final YogaBorderSide? end; // inline-end
  final YogaBorderSide? blockStart;
  final YogaBorderSide? blockEnd;

  // Global
  final YogaBorderSide? all;

  final YogaBorderRadius? borderRadius;

  final YogaBorderImage? image;

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

  // Helper to resolve to physical sides
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
      borderRadius:
          borderRadius?.toFlutterBorderRadius(direction) ?? BorderRadius.zero,
    );
  }
}

class ResolvedYogaBorder {
  final YogaBorderSide top;
  final YogaBorderSide right;
  final YogaBorderSide bottom;
  final YogaBorderSide left;
  final BorderRadius borderRadius;

  ResolvedYogaBorder({
    required this.top,
    required this.right,
    required this.bottom,
    required this.left,
    required this.borderRadius,
  });

  Border toFlutterBorder() {
    return Border(
      top: top.toFlutterBorderSide(),
      right: right.toFlutterBorderSide(),
      bottom: bottom.toFlutterBorderSide(),
      left: left.toFlutterBorderSide(),
    );
  }
}

class YogaBorderImage {
  final ImageProvider source;
  final YogaEdgeInsets slice;
  final bool fill;
  final YogaEdgeInsets? width;
  final YogaEdgeInsets outset;
  final YogaBorderImageRepeat repeat;

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
