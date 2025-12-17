import 'package:flutter/widgets.dart';

import 'length.dart';

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
