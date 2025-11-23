import 'package:flutter/painting.dart';
import 'yoga_value.dart';

/// Specifies the positioning area of the background images.
enum YogaBackgroundOrigin {
  /// The background extends to the outside edge of the border (but underneath the border in z-order).
  borderBox,

  /// The background extends to the outside edge of the padding. No background is drawn beneath the border.
  paddingBox,

  /// The background extends to the edge of the content box.
  contentBox,
}

/// Specifies the size of the background images.
enum YogaBackgroundSizeMode {
  /// The background image is displayed at its intrinsic size.
  auto,

  /// Scale the image, while preserving its intrinsic aspect ratio, to the smallest size such that both its width and its height can completely cover the background positioning area.
  cover,

  /// Scale the image, while preserving its intrinsic aspect ratio, to the largest size such that both its width and its height can fit inside the background positioning area.
  contain,

  /// The size is explicitly specified by width and height.
  explicit,
}

/// Represents the size of a background image.
class YogaBackgroundSize {
  /// The width of the background image.
  final YogaValue width;

  /// The height of the background image.
  final YogaValue height;

  /// The mode of sizing.
  final YogaBackgroundSizeMode mode;

  /// Creates an explicit background size.
  const YogaBackgroundSize({
    this.width = const YogaValue.auto(),
    this.height = const YogaValue.auto(),
  }) : mode = YogaBackgroundSizeMode.explicit;

  /// The background image is displayed at its intrinsic size.
  const YogaBackgroundSize.auto()
    : width = const YogaValue.auto(),
      height = const YogaValue.auto(),
      mode = YogaBackgroundSizeMode.auto;

  /// Scale the image to cover the background positioning area.
  const YogaBackgroundSize.cover()
    : width = const YogaValue.auto(),
      height = const YogaValue.auto(),
      mode = YogaBackgroundSizeMode.cover;

  /// Scale the image to fit inside the background positioning area.
  const YogaBackgroundSize.contain()
    : width = const YogaValue.auto(),
      height = const YogaValue.auto(),
      mode = YogaBackgroundSizeMode.contain;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is YogaBackgroundSize &&
        other.width == width &&
        other.height == height &&
        other.mode == mode;
  }

  @override
  int get hashCode => Object.hash(width, height, mode);
}

/// Represents the position of a background image.
class YogaBackgroundPosition {
  /// The horizontal position.
  final YogaValue x;

  /// The vertical position.
  final YogaValue y;

  /// Creates a background position.
  const YogaBackgroundPosition({
    this.x = const YogaValue.percent(0),
    this.y = const YogaValue.percent(0),
  });

  /// Center position (50% 50%).
  static const YogaBackgroundPosition center = YogaBackgroundPosition(
    x: YogaValue.percent(50),
    y: YogaValue.percent(50),
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is YogaBackgroundPosition && other.x == x && other.y == y;
  }

  @override
  int get hashCode => Object.hash(x, y);
}

/// A background of a box.
class YogaBackground {
  /// The background color.
  final Color? color;

  /// The background image.
  final ImageProvider? image;

  /// The background origin.
  final YogaBackgroundOrigin origin;

  /// The background position.
  final YogaBackgroundPosition position;

  /// The background repeat.
  final ImageRepeat repeat;

  /// The background size.
  final YogaBackgroundSize size;

  /// Creates a background.
  const YogaBackground({
    this.color,
    this.image,
    this.origin = YogaBackgroundOrigin.paddingBox,
    this.position = const YogaBackgroundPosition(
      x: YogaValue.percent(0),
      y: YogaValue.percent(0),
    ),
    this.repeat = ImageRepeat.repeat,
    this.size = const YogaBackgroundSize.auto(),
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is YogaBackground &&
        other.color == color &&
        other.image == image &&
        other.origin == origin &&
        other.position == position &&
        other.repeat == repeat &&
        other.size == size;
  }

  @override
  int get hashCode => Object.hash(color, image, origin, position, repeat, size);
}
