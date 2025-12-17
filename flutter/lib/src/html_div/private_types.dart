part of '../../html_div.dart';

class _NineSliceSrcRects {
  final Rect topLeft;
  final Rect top;
  final Rect topRight;
  final Rect left;
  final Rect center;
  final Rect right;
  final Rect bottomLeft;
  final Rect bottom;
  final Rect bottomRight;

  const _NineSliceSrcRects({
    required this.topLeft,
    required this.top,
    required this.topRight,
    required this.left,
    required this.center,
    required this.right,
    required this.bottomLeft,
    required this.bottom,
    required this.bottomRight,
  });
}

class _BackgroundAxisTile {
  final double offset;
  final double spacing;

  /// -1 means "repeat until bounds".
  final int count;
  final double? overrideTileExtent;

  const _BackgroundAxisTile({
    required this.offset,
    required this.spacing,
    required this.count,
    this.overrideTileExtent,
  });
}
