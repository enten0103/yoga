import 'package:flutter/widgets.dart';

import 'length.dart';

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
