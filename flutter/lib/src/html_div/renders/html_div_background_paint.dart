part of '../../../html_div.dart';

extension _RenderHtmlDivBackgroundPaintExt on RenderHtmlDiv {
  void _paintBackgroundIfNeeded(PaintingContext context, Offset offset) {
    final HtmlBackground? bg = _background;
    if (bg == null) return;

    final Rect borderBox = offset & size;
    final Rect clipRect;
    if (bg.clip == HtmlBackgroundClip.borderBox) {
      clipRect = borderBox;
    } else {
      final EdgeInsets bw = _computedBorderWidths;
      clipRect = Rect.fromLTRB(
        borderBox.left + bw.left,
        borderBox.top + bw.top,
        borderBox.right - bw.right,
        borderBox.bottom - bw.bottom,
      );
    }
    if (clipRect.isEmpty) return;

    final Canvas canvas = context.canvas;
    final HtmlBorderRadius? br = _borderRadius;
    final bool needsClip =
        br != null && br.toBorderRadius() != BorderRadius.zero;

    canvas.save();
    if (needsClip) {
      final RRect rrect = br.toBorderRadius().toRRect(clipRect);
      canvas.clipRRect(rrect);
    } else {
      canvas.clipRect(clipRect);
    }

    final Color? bgColor = bg.color;
    if (bgColor != null) {
      canvas.drawRect(clipRect, Paint()..color = bgColor);
    }

    final HtmlBackgroundImage? bgImage = bg.image;
    final ImageInfo? info = _backgroundImageInfo;
    if (bgImage != null && info != null) {
      _paintBackgroundImage(
        canvas: canvas,
        rect: clipRect,
        bg: bgImage,
        info: info,
      );
    }

    canvas.restore();
  }

  Size _resolveBackgroundImageDestSize({
    required HtmlBackgroundSize size,
    required Size imageSize,
    required Size dstRectSize,
  }) {
    switch (size.type) {
      case HtmlBackgroundSizeType.auto:
        return imageSize;
      case HtmlBackgroundSizeType.contain:
        final double sx = dstRectSize.width / imageSize.width;
        final double sy = dstRectSize.height / imageSize.height;
        final double s = math.min(sx, sy);
        return Size(imageSize.width * s, imageSize.height * s);
      case HtmlBackgroundSizeType.cover:
        final double sx = dstRectSize.width / imageSize.width;
        final double sy = dstRectSize.height / imageSize.height;
        final double s = math.max(sx, sy);
        return Size(imageSize.width * s, imageSize.height * s);
      case HtmlBackgroundSizeType.explicit:
        final double w =
            size.width?.resolvePx(reference: dstRectSize.width) ??
            imageSize.width;
        final double h =
            size.height?.resolvePx(reference: dstRectSize.height) ??
            imageSize.height;
        return Size(w, h);
    }
  }

  List<_BackgroundAxisTile> _computeAxisTiles({
    required double start,
    required double extent,
    required double tileExtent,
    required HtmlBackgroundRepeat repeat,
  }) {
    if (tileExtent <= 0 || extent <= 0) return const <_BackgroundAxisTile>[];

    switch (repeat) {
      case HtmlBackgroundRepeat.noRepeat:
        return <_BackgroundAxisTile>[
          const _BackgroundAxisTile(offset: 0, spacing: 0, count: 1),
        ];
      case HtmlBackgroundRepeat.repeat:
        // We'll use the raw tiling loop; spacing=0.
        return <_BackgroundAxisTile>[
          const _BackgroundAxisTile(offset: 0, spacing: 0, count: -1),
        ];
      case HtmlBackgroundRepeat.round:
        final int count = math.max(1, (extent / tileExtent).round());
        final double newTile = extent / count;
        return <_BackgroundAxisTile>[
          _BackgroundAxisTile(
            offset: 0,
            spacing: 0,
            count: count,
            overrideTileExtent: newTile,
          ),
        ];
      case HtmlBackgroundRepeat.space:
        final int count = (extent / tileExtent).floor();
        if (count <= 1) {
          return <_BackgroundAxisTile>[
            const _BackgroundAxisTile(offset: 0, spacing: 0, count: 1),
          ];
        }
        final double spacing = (extent - (count * tileExtent)) / (count - 1);
        return <_BackgroundAxisTile>[
          _BackgroundAxisTile(offset: 0, spacing: spacing, count: count),
        ];
    }
  }

  void _paintBackgroundImage({
    required Canvas canvas,
    required Rect rect,
    required HtmlBackgroundImage bg,
    required ImageInfo info,
  }) {
    final ui.Image image = info.image;
    final double logicalW = image.width.toDouble() / info.scale;
    final double logicalH = image.height.toDouble() / info.scale;
    final Size imageSize = Size(logicalW, logicalH);

    final Size dstSize = _resolveBackgroundImageDestSize(
      size: bg.size,
      imageSize: imageSize,
      dstRectSize: rect.size,
    );
    if (dstSize.isEmpty) return;

    final Alignment a = bg.position.alignment;
    final double ax = (a.x + 1) / 2.0;
    final double ay = (a.y + 1) / 2.0;
    final Offset posOffset = bg.position.offset.resolveForSize(rect.size);
    final double baseLeft =
        rect.left + (rect.width - dstSize.width) * ax + posOffset.dx;
    final double baseTop =
        rect.top + (rect.height - dstSize.height) * ay + posOffset.dy;

    final Rect src = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );

    // Determine tiling in X/Y.
    final List<_BackgroundAxisTile> xTiles = _computeAxisTiles(
      start: rect.left,
      extent: rect.width,
      tileExtent: dstSize.width,
      repeat: bg.repeatX,
    );
    final List<_BackgroundAxisTile> yTiles = _computeAxisTiles(
      start: rect.top,
      extent: rect.height,
      tileExtent: dstSize.height,
      repeat: bg.repeatY,
    );
    if (xTiles.isEmpty || yTiles.isEmpty) return;

    double tileW = dstSize.width;
    double tileH = dstSize.height;
    if (xTiles.first.overrideTileExtent != null) {
      tileW = xTiles.first.overrideTileExtent!;
    }
    if (yTiles.first.overrideTileExtent != null) {
      tileH = yTiles.first.overrideTileExtent!;
    }

    // Repeat mode uses positioning origin; round/space use rect-start for simplicity.
    double startX;
    if (bg.repeatX == HtmlBackgroundRepeat.repeat) {
      startX = baseLeft;
      while (startX > rect.left) {
        startX -= tileW;
      }
    } else {
      startX = rect.left;
    }

    double startY;
    if (bg.repeatY == HtmlBackgroundRepeat.repeat) {
      startY = baseTop;
      while (startY > rect.top) {
        startY -= tileH;
      }
    } else {
      startY = rect.top;
    }

    final Paint paint = Paint()..filterQuality = FilterQuality.low;

    for (final _BackgroundAxisTile xt in xTiles) {
      for (final _BackgroundAxisTile yt in yTiles) {
        if (xt.count == 1 &&
            yt.count == 1 &&
            bg.repeatX == HtmlBackgroundRepeat.noRepeat &&
            bg.repeatY == HtmlBackgroundRepeat.noRepeat) {
          final Rect dst = Rect.fromLTWH(baseLeft, baseTop, tileW, tileH);
          if (dst.overlaps(rect)) canvas.drawImageRect(image, src, dst, paint);
          continue;
        }

        final int xCount = xt.count < 0
            ? ((rect.right - startX) / tileW).ceil() + 2
            : xt.count;
        final int yCount = yt.count < 0
            ? ((rect.bottom - startY) / tileH).ceil() + 2
            : yt.count;
        final double xSpacing = xt.spacing;
        final double ySpacing = yt.spacing;

        for (int ix = 0; ix < xCount; ix++) {
          final double dx = (bg.repeatX == HtmlBackgroundRepeat.repeat)
              ? startX + ix * tileW
              : rect.left + ix * (tileW + xSpacing);
          if (dx >= rect.right) break;
          if (dx + tileW <= rect.left) continue;

          for (int iy = 0; iy < yCount; iy++) {
            final double dy = (bg.repeatY == HtmlBackgroundRepeat.repeat)
                ? startY + iy * tileH
                : rect.top + iy * (tileH + ySpacing);
            if (dy >= rect.bottom) break;
            if (dy + tileH <= rect.top) continue;

            final Rect dst = Rect.fromLTWH(dx, dy, tileW, tileH);
            if (dst.overlaps(rect)) {
              canvas.drawImageRect(image, src, dst, paint);
            }
          }
        }
      }
    }
  }
}
