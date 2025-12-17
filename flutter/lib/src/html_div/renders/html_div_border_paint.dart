part of '../../../html_div.dart';

extension _RenderHtmlDivBorderPaintExt on RenderHtmlDiv {
  bool _paintBorderImageIfNeeded(PaintingContext context, Offset offset) {
    if (_border == null) return false;
    final HtmlBorderImage? base = _border!.borderImage;
    if (base == null) return false;
    if (_computedBorderWidths == EdgeInsets.zero) return false;

    // Per CSS: if border-style is none/hidden, border image shouldn't show.
    if (_border!.top.style == HtmlBorderStyle.hidden &&
        _border!.right.style == HtmlBorderStyle.hidden &&
        _border!.bottom.style == HtmlBorderStyle.hidden &&
        _border!.left.style == HtmlBorderStyle.hidden) {
      return false;
    }

    ImageInfo? infoFor(HtmlBorderImage bi) => _borderImageInfos[bi.image];

    final ImageInfo? baseInfo = infoFor(base);
    if (baseInfo == null) return false;

    HtmlBorderImage pickSide(HtmlBorderImage? override) {
      if (override == null) return base;
      return infoFor(override) == null ? base : override;
    }

    final HtmlBorderImageSides? sideOverrides = _border!.borderImageSides;
    final HtmlBorderImage topBi = pickSide(sideOverrides?.top);
    final HtmlBorderImage rightBi = pickSide(sideOverrides?.right);
    final HtmlBorderImage bottomBi = pickSide(sideOverrides?.bottom);
    final HtmlBorderImage leftBi = pickSide(sideOverrides?.left);

    final ImageInfo topInfo = infoFor(topBi) ?? baseInfo;
    final ImageInfo rightInfo = infoFor(rightBi) ?? baseInfo;
    final ImageInfo bottomInfo = infoFor(bottomBi) ?? baseInfo;
    final ImageInfo leftInfo = infoFor(leftBi) ?? baseInfo;

    final Rect borderBox = offset & size;

    final EdgeInsets borderWidths = _computedBorderWidths;

    final EdgeInsets imageWidths = EdgeInsets.fromLTRB(
      leftBi.width.left.resolve(
        borderWidth: borderWidths.left,
        reference: borderBox.width,
      ),
      topBi.width.top.resolve(
        borderWidth: borderWidths.top,
        reference: borderBox.height,
      ),
      rightBi.width.right.resolve(
        borderWidth: borderWidths.right,
        reference: borderBox.width,
      ),
      bottomBi.width.bottom.resolve(
        borderWidth: borderWidths.bottom,
        reference: borderBox.height,
      ),
    );

    final EdgeInsets outset = EdgeInsets.fromLTRB(
      leftBi.outset.left.resolveOutset(
        borderWidth: borderWidths.left,
        reference: borderBox.width,
      ),
      topBi.outset.top.resolveOutset(
        borderWidth: borderWidths.top,
        reference: borderBox.height,
      ),
      rightBi.outset.right.resolveOutset(
        borderWidth: borderWidths.right,
        reference: borderBox.width,
      ),
      bottomBi.outset.bottom.resolveOutset(
        borderWidth: borderWidths.bottom,
        reference: borderBox.height,
      ),
    );

    final Rect outer = Rect.fromLTRB(
      borderBox.left - outset.left,
      borderBox.top - outset.top,
      borderBox.right + outset.right,
      borderBox.bottom + outset.bottom,
    );

    final Rect inner = Rect.fromLTRB(
      borderBox.left + imageWidths.left,
      borderBox.top + imageWidths.top,
      borderBox.right - imageWidths.right,
      borderBox.bottom - imageWidths.bottom,
    );

    if (outer.width <= 0 || outer.height <= 0) return false;
    if (inner.left > inner.right || inner.top > inner.bottom) return false;

    _NineSliceSrcRects srcFor(HtmlBorderImage bi, ui.Image image) {
      final double imgW = image.width.toDouble();
      final double imgH = image.height.toDouble();
      double sliceTop = bi.slice.top
          .resolvePx(referencePx: imgH)
          .clamp(0.0, imgH);
      double sliceBottom = bi.slice.bottom
          .resolvePx(referencePx: imgH)
          .clamp(0.0, imgH);
      double sliceLeft = bi.slice.left
          .resolvePx(referencePx: imgW)
          .clamp(0.0, imgW);
      double sliceRight = bi.slice.right
          .resolvePx(referencePx: imgW)
          .clamp(0.0, imgW);

      if (sliceLeft + sliceRight > imgW) {
        final double scaleFactor = imgW / (sliceLeft + sliceRight);
        sliceLeft *= scaleFactor;
        sliceRight *= scaleFactor;
      }
      if (sliceTop + sliceBottom > imgH) {
        final double scaleFactor = imgH / (sliceTop + sliceBottom);
        sliceTop *= scaleFactor;
        sliceBottom *= scaleFactor;
      }

      final Rect srcTopLeft = Rect.fromLTWH(0, 0, sliceLeft, sliceTop);
      final Rect srcTop = Rect.fromLTRB(
        sliceLeft,
        0,
        imgW - sliceRight,
        sliceTop,
      );
      final Rect srcTopRight = Rect.fromLTRB(
        imgW - sliceRight,
        0,
        imgW,
        sliceTop,
      );

      final Rect srcLeft = Rect.fromLTRB(
        0,
        sliceTop,
        sliceLeft,
        imgH - sliceBottom,
      );
      final Rect srcCenter = Rect.fromLTRB(
        sliceLeft,
        sliceTop,
        imgW - sliceRight,
        imgH - sliceBottom,
      );
      final Rect srcRight = Rect.fromLTRB(
        imgW - sliceRight,
        sliceTop,
        imgW,
        imgH - sliceBottom,
      );

      final Rect srcBottomLeft = Rect.fromLTRB(
        0,
        imgH - sliceBottom,
        sliceLeft,
        imgH,
      );
      final Rect srcBottom = Rect.fromLTRB(
        sliceLeft,
        imgH - sliceBottom,
        imgW - sliceRight,
        imgH,
      );
      final Rect srcBottomRight = Rect.fromLTRB(
        imgW - sliceRight,
        imgH - sliceBottom,
        imgW,
        imgH,
      );

      return _NineSliceSrcRects(
        topLeft: srcTopLeft,
        top: srcTop,
        topRight: srcTopRight,
        left: srcLeft,
        center: srcCenter,
        right: srcRight,
        bottomLeft: srcBottomLeft,
        bottom: srcBottom,
        bottomRight: srcBottomRight,
      );
    }

    final Rect dstTopLeft = Rect.fromLTRB(
      outer.left,
      outer.top,
      inner.left,
      inner.top,
    );
    final Rect dstTop = Rect.fromLTRB(
      inner.left,
      outer.top,
      inner.right,
      inner.top,
    );
    final Rect dstTopRight = Rect.fromLTRB(
      inner.right,
      outer.top,
      outer.right,
      inner.top,
    );

    final Rect dstLeft = Rect.fromLTRB(
      outer.left,
      inner.top,
      inner.left,
      inner.bottom,
    );
    final Rect dstCenter = Rect.fromLTRB(
      inner.left,
      inner.top,
      inner.right,
      inner.bottom,
    );
    final Rect dstRight = Rect.fromLTRB(
      inner.right,
      inner.top,
      outer.right,
      inner.bottom,
    );

    final Rect dstBottomLeft = Rect.fromLTRB(
      outer.left,
      inner.bottom,
      inner.left,
      outer.bottom,
    );
    final Rect dstBottom = Rect.fromLTRB(
      inner.left,
      inner.bottom,
      inner.right,
      outer.bottom,
    );
    final Rect dstBottomRight = Rect.fromLTRB(
      inner.right,
      inner.bottom,
      outer.right,
      outer.bottom,
    );

    final Canvas canvas = context.canvas;

    // Clip to border box radius if any.
    if (_borderRadius != null) {
      canvas.save();
      final RRect clipRRect = _borderRadius!.toBorderRadius().toRRect(
        borderBox,
      );
      canvas.clipRRect(clipRRect);
    }

    final bool topHidden = _border!.top.style == HtmlBorderStyle.hidden;
    final bool rightHidden = _border!.right.style == HtmlBorderStyle.hidden;
    final bool bottomHidden = _border!.bottom.style == HtmlBorderStyle.hidden;
    final bool leftHidden = _border!.left.style == HtmlBorderStyle.hidden;

    // Corners follow vertical sides (left/right) when overrides differ.
    if (!(topHidden && leftHidden)) {
      final ui.Image cornerImage = leftInfo.image;
      final _NineSliceSrcRects src = srcFor(leftBi, cornerImage);
      _drawImageRectSafe(canvas, cornerImage, src.topLeft, dstTopLeft);
    }
    if (!topHidden) {
      final ui.Image edgeImage = topInfo.image;
      final _NineSliceSrcRects src = srcFor(topBi, edgeImage);
      _drawEdge(
        canvas,
        edgeImage,
        src.top,
        dstTop,
        axis: Axis.horizontal,
        repeat: topBi.repeatX,
        scale: topInfo.scale,
      );
    }
    if (!(topHidden && rightHidden)) {
      final ui.Image cornerImage = rightInfo.image;
      final _NineSliceSrcRects src = srcFor(rightBi, cornerImage);
      _drawImageRectSafe(canvas, cornerImage, src.topRight, dstTopRight);
    }

    if (!leftHidden) {
      final ui.Image edgeImage = leftInfo.image;
      final _NineSliceSrcRects src = srcFor(leftBi, edgeImage);
      _drawEdge(
        canvas,
        edgeImage,
        src.left,
        dstLeft,
        axis: Axis.vertical,
        repeat: leftBi.repeatY,
        scale: leftInfo.scale,
      );
    }

    HtmlBorderImage? fillBi;
    ImageInfo? fillInfo;
    if (topBi.slice.fill) {
      fillBi = topBi;
      fillInfo = topInfo;
    } else if (rightBi.slice.fill) {
      fillBi = rightBi;
      fillInfo = rightInfo;
    } else if (bottomBi.slice.fill) {
      fillBi = bottomBi;
      fillInfo = bottomInfo;
    } else if (leftBi.slice.fill) {
      fillBi = leftBi;
      fillInfo = leftInfo;
    } else if (base.slice.fill) {
      fillBi = base;
      fillInfo = baseInfo;
    }
    if (fillBi != null && fillInfo != null) {
      final ui.Image fillImage = fillInfo.image;
      final _NineSliceSrcRects src = srcFor(fillBi, fillImage);
      _drawImageRectSafe(canvas, fillImage, src.center, dstCenter);
    }

    if (!rightHidden) {
      final ui.Image edgeImage = rightInfo.image;
      final _NineSliceSrcRects src = srcFor(rightBi, edgeImage);
      _drawEdge(
        canvas,
        edgeImage,
        src.right,
        dstRight,
        axis: Axis.vertical,
        repeat: rightBi.repeatY,
        scale: rightInfo.scale,
      );
    }

    if (!(bottomHidden && leftHidden)) {
      final ui.Image cornerImage = leftInfo.image;
      final _NineSliceSrcRects src = srcFor(leftBi, cornerImage);
      _drawImageRectSafe(canvas, cornerImage, src.bottomLeft, dstBottomLeft);
    }
    if (!bottomHidden) {
      final ui.Image edgeImage = bottomInfo.image;
      final _NineSliceSrcRects src = srcFor(bottomBi, edgeImage);
      _drawEdge(
        canvas,
        edgeImage,
        src.bottom,
        dstBottom,
        axis: Axis.horizontal,
        repeat: bottomBi.repeatX,
        scale: bottomInfo.scale,
      );
    }
    if (!(bottomHidden && rightHidden)) {
      final ui.Image cornerImage = rightInfo.image;
      final _NineSliceSrcRects src = srcFor(rightBi, cornerImage);
      _drawImageRectSafe(canvas, cornerImage, src.bottomRight, dstBottomRight);
    }

    if (_borderRadius != null) {
      canvas.restore();
    }

    return true;
  }

  void _drawImageRectSafe(Canvas canvas, ui.Image image, Rect src, Rect dst) {
    if (src.width <= 0 || src.height <= 0) return;
    if (dst.width <= 0 || dst.height <= 0) return;
    canvas.drawImageRect(image, src, dst, Paint());
  }

  void _drawEdge(
    Canvas canvas,
    ui.Image image,
    Rect src,
    Rect dst, {
    required Axis axis,
    required HtmlBorderImageRepeat repeat,
    required double scale,
  }) {
    if (src.width <= 0 || src.height <= 0) return;
    if (dst.width <= 0 || dst.height <= 0) return;

    if (repeat == HtmlBorderImageRepeat.stretch) {
      _drawImageRectSafe(canvas, image, src, dst);
      return;
    }

    final double srcMainPx = axis == Axis.horizontal ? src.width : src.height;
    final double dstMain = axis == Axis.horizontal ? dst.width : dst.height;
    final double dstCross = axis == Axis.horizontal ? dst.height : dst.width;

    final double tileMain = srcMainPx / scale;
    if (tileMain <= 0) {
      _drawImageRectSafe(canvas, image, src, dst);
      return;
    }

    int tileCount;
    double tileMainAdjusted = tileMain;
    double gap = 0.0;

    switch (repeat) {
      case HtmlBorderImageRepeat.repeat:
        tileCount = math.max(1, (dstMain / tileMain).ceil());
        break;
      case HtmlBorderImageRepeat.round:
        tileCount = math.max(1, (dstMain / tileMain).round());
        tileMainAdjusted = dstMain / tileCount;
        break;
      case HtmlBorderImageRepeat.space:
        tileCount = math.max(1, (dstMain / tileMain).floor());
        if (tileCount > 1) {
          gap = (dstMain - tileCount * tileMain) / (tileCount - 1);
        }
        break;
      case HtmlBorderImageRepeat.stretch:
        tileCount = 1;
        break;
    }

    double cursor = 0.0;
    for (int i = 0; i < tileCount; i++) {
      final double remaining = dstMain - cursor;
      if (remaining <= 0) break;

      final double segmentMain = (repeat == HtmlBorderImageRepeat.round)
          ? tileMainAdjusted
          : math.min(tileMain, remaining);

      Rect dstSegment;
      if (axis == Axis.horizontal) {
        dstSegment = Rect.fromLTWH(
          dst.left + cursor,
          dst.top,
          segmentMain,
          dstCross,
        );
      } else {
        dstSegment = Rect.fromLTWH(
          dst.left,
          dst.top + cursor,
          dstCross,
          segmentMain,
        );
      }

      Rect srcSegment = src;
      if (repeat != HtmlBorderImageRepeat.round && segmentMain < tileMain) {
        final double segmentPx = segmentMain * scale;
        if (axis == Axis.horizontal) {
          srcSegment = Rect.fromLTRB(
            src.left,
            src.top,
            src.left + segmentPx,
            src.bottom,
          );
        } else {
          srcSegment = Rect.fromLTRB(
            src.left,
            src.top,
            src.right,
            src.top + segmentPx,
          );
        }
      }

      _drawImageRectSafe(canvas, image, srcSegment, dstSegment);
      cursor += (repeat == HtmlBorderImageRepeat.round)
          ? tileMainAdjusted
          : (tileMain + gap);
    }
  }

  void _paintUniformBorder(PaintingContext context, Offset offset) {
    final HtmlBorderSide side = _border!.top;
    final double width = _computedBorderWidths.top;

    if (side.style == HtmlBorderStyle.hidden || width <= 0) return;

    final Paint paint = Paint()
      ..color = side.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;

    final Rect borderRect = (offset & size).deflate(width / 2.0);
    RRect? borderRRect;
    if (_borderRadius != null) {
      borderRRect = _borderRadius!.toBorderRadius().toRRect(borderRect);
    }

    switch (side.style) {
      case HtmlBorderStyle.solid:
        if (borderRRect != null) {
          context.canvas.drawRRect(borderRRect, paint);
        } else {
          context.canvas.drawRect(borderRect, paint);
        }
        break;
      case HtmlBorderStyle.double:
        double third = width / 3.0;
        paint.strokeWidth = third;
        if (borderRRect != null) {
          context.canvas.drawRRect(borderRRect.deflate(third), paint);
          context.canvas.drawRRect(borderRRect.deflate(-third), paint);
        } else {
          context.canvas.drawRect((offset & size).deflate(third / 2.0), paint);
          context.canvas.drawRect(
            (offset & size).deflate(width - third / 2.0),
            paint,
          );
        }
        break;
      case HtmlBorderStyle.dotted:
      case HtmlBorderStyle.dashed:
        if (borderRRect != null) {
          _drawDashedRRect(context.canvas, borderRRect, paint, side.style);
        } else {
          _drawDashedRect(context.canvas, borderRect, paint, side.style);
        }
        break;
      default:
        break;
    }
  }

  void _paintMixedBorder(PaintingContext context, Offset offset) {
    final Rect outer = offset & size;
    final Rect inner = Rect.fromLTRB(
      outer.left + _computedBorderWidths.left,
      outer.top + _computedBorderWidths.top,
      outer.right - _computedBorderWidths.right,
      outer.bottom - _computedBorderWidths.bottom,
    );

    _paintSide(
      context.canvas,
      _border!.top,
      outer.topLeft,
      outer.topRight,
      inner.topRight,
      inner.topLeft,
    );
    _paintSide(
      context.canvas,
      _border!.right,
      outer.topRight,
      outer.bottomRight,
      inner.bottomRight,
      inner.topRight,
    );
    _paintSide(
      context.canvas,
      _border!.bottom,
      outer.bottomRight,
      outer.bottomLeft,
      inner.bottomLeft,
      inner.bottomRight,
    );
    _paintSide(
      context.canvas,
      _border!.left,
      outer.bottomLeft,
      outer.topLeft,
      inner.topLeft,
      inner.bottomLeft,
    );
  }

  void _paintSide(
    Canvas canvas,
    HtmlBorderSide side,
    Offset p1,
    Offset p2,
    Offset p3,
    Offset p4,
  ) {
    if (side.style == HtmlBorderStyle.hidden) return;

    final Paint paint = Paint()..color = side.color;
    paint.style = PaintingStyle.fill;
    final Path path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..lineTo(p4.dx, p4.dy)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawDashedRect(
    Canvas canvas,
    Rect rect,
    Paint paint,
    HtmlBorderStyle style,
  ) {
    final Path path = Path()..addRect(rect);
    _drawDashedPath(canvas, path, paint, style);
  }

  void _drawDashedRRect(
    Canvas canvas,
    RRect rrect,
    Paint paint,
    HtmlBorderStyle style,
  ) {
    final Path path = Path()..addRRect(rrect);
    _drawDashedPath(canvas, path, paint, style);
  }

  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint,
    HtmlBorderStyle style,
  ) {
    final double dashWidth = style == HtmlBorderStyle.dotted
        ? paint.strokeWidth
        : paint.strokeWidth * 3;
    final double dashSpace = style == HtmlBorderStyle.dotted
        ? paint.strokeWidth
        : paint.strokeWidth * 2;

    final ui.PathMetrics metrics = path.computeMetrics();
    for (ui.PathMetric metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }
}
