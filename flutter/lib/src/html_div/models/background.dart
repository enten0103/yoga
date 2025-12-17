import 'package:flutter/widgets.dart';

import 'length.dart';

// Background (CSS-inspired model)
//
// Minimal support:
// - background-color
// - background-image (single layer)
// - background-repeat (x/y)
// - background-size (auto/contain/cover/explicit)
// - background-position (alignment + px/% offset)
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
