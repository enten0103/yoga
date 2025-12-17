part of '../../../html_div.dart';

extension _RenderHtmlDivBoxShadowPaintExt on RenderHtmlDiv {
  void _paintBoxShadowIfNeeded(
    PaintingContext context,
    Offset offset, {
    required bool inset,
  }) {
    if (_boxShadow.isEmpty) return;

    final Rect borderBox = offset & size;
    if (borderBox.isEmpty) return;

    final Canvas canvas = context.canvas;
    final HtmlBorderRadius? br = _borderRadius;
    final bool hasRadius =
        br != null && br.toBorderRadius() != BorderRadius.zero;
    final RRect? baseRRect = hasRadius
        ? br.toBorderRadius().toRRect(borderBox)
        : null;

    // CSS draws the first shadow on top.
    for (int i = _boxShadow.length - 1; i >= 0; i--) {
      final HtmlBoxShadow s = _boxShadow[i];
      if (s.inset != inset) continue;

      final Offset shadowOffset = s.offset.resolveForSize(borderBox.size);

      final Paint paint = BoxShadow(
        color: s.color,
        blurRadius: s.blurRadius,
      ).toPaint();

      if (!inset) {
        if (baseRRect != null) {
          final RRect rr = baseRRect
              .shift(shadowOffset)
              .inflate(s.spreadRadius);
          canvas.drawRRect(rr, paint);
        } else {
          final Rect r = borderBox.shift(shadowOffset).inflate(s.spreadRadius);
          canvas.drawRect(r, paint);
        }
        continue;
      }

      // Inset shadow approximation:
      // Draw a blurred ring (outer - shifted/deflated inner) clipped to the border box.
      canvas.save();
      if (baseRRect != null) {
        canvas.clipRRect(baseRRect);
        final Path outer = Path()..addRRect(baseRRect);
        final Offset invOffset = Offset(-shadowOffset.dx, -shadowOffset.dy);
        final RRect inner = baseRRect.deflate(s.spreadRadius).shift(invOffset);
        final Path hole = Path()..addRRect(inner);
        final Path ring = Path.combine(
          ui.PathOperation.difference,
          outer,
          hole,
        );
        canvas.drawPath(ring, paint);
      } else {
        canvas.clipRect(borderBox);
        final Path outer = Path()..addRect(borderBox);
        final Offset invOffset = Offset(-shadowOffset.dx, -shadowOffset.dy);
        final Rect inner = borderBox.deflate(s.spreadRadius).shift(invOffset);
        final Path hole = Path()..addRect(inner);
        final Path ring = Path.combine(
          ui.PathOperation.difference,
          outer,
          hole,
        );
        canvas.drawPath(ring, paint);
      }
      canvas.restore();
    }
  }
}
