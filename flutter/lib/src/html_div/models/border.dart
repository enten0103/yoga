import 'package:flutter/widgets.dart';

import 'border_image.dart';

// Border model

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
