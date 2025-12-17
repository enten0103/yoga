part of '../../../html_div.dart';

extension _RenderHtmlDivTransformHitTestExt on RenderHtmlDiv {
  Offset _resolveTransformOrigin(HtmlTransform t) {
    if (size.isEmpty) {
      return t.originOffset.resolve(referenceWidth: 0, referenceHeight: 0);
    }
    final Offset aligned = t.originAlignment.alongSize(size);
    final Offset offset = t.originOffset.resolveForSize(size);
    return aligned + offset;
  }

  Matrix4? _effectiveTransform() {
    final HtmlTransform? t = _transform;
    if (t == null) return null;

    final Offset origin = _resolveTransformOrigin(t);
    final Matrix4 m = Matrix4.identity()
      ..translateByDouble(origin.dx, origin.dy, 0.0, 1.0)
      ..multiply(t.matrix)
      ..translateByDouble(-origin.dx, -origin.dy, 0.0, 1.0);

    // Avoid creating a compositing layer for pure identity.
    if (m.isIdentity()) return null;
    return m;
  }
}
