part of '../../../html_div.dart';

final RegExp _breakAllWhitespaceRegExp = RegExp(r'\s');
// CJK scripts typically have native per-character line break opportunities.
// Avoid injecting \u200B for these ranges, because it can affect text
// shaping/measurement on some engines (notably Windows) and introduce
// unexpected wrapping.
final RegExp _cjkLikeRegExp = RegExp(
  r'[\u3040-\u30FF\u3400-\u4DBF\u4E00-\u9FFF\uAC00-\uD7AF]',
);

extension _RenderHtmlDivInlineParagraphExt on RenderHtmlDiv {
  String _breakAllTextIfNeeded(
    String s, {
    required TextStyle style,
    required double maxLineWidth,
    required TextDirection textDirection,
    required TextScaler textScaler,
    required Locale? locale,
    required TextWidthBasis textWidthBasis,
    required TextHeightBehavior? textHeightBehavior,
  }) {
    if (_overflowWrap == HtmlOverflowWrap.normal) return s;
    // Prefer normal whitespace wrapping when there are break opportunities.
    // For long unbroken runs, add zero-width break points so trailing text
    // can still consume remaining line space (CSS-like break-all).
    if (s.length <= 1) return s;
    if (s.contains(_breakAllWhitespaceRegExp)) return s;
    if (s.contains(_cjkLikeRegExp)) return s;
    if (s.contains('\u200B')) return s;

    // Only inject break opportunities when the unbroken run cannot fit within
    // a single line by itself. This avoids splitting short words like "NESTED"
    // when the paragraph wraps for other reasons (e.g. surrounding whitespace).
    if (!maxLineWidth.isFinite || maxLineWidth <= 0) return s;
    final TextPainter probe = TextPainter(
      text: TextSpan(text: s, style: style),
      textDirection: textDirection,
      textScaler: textScaler,
      locale: locale,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      maxLines: 1,
      ellipsis: null,
    )..layout(maxWidth: double.infinity);
    if (probe.width <= maxLineWidth) return s;

    return s.characters.join('\u200B');
  }

  _ParagraphRun _layoutParagraphRun({
    required List<RenderBox> runChildren,
    required double contentWidth,
    required double xOffset,
    required double yTop,
    required double? childContentMaxHeight,
    required double firstLineIndentPx,
  }) {
    bool subtreeHasNonEmptyText(RenderBox root) {
      if (root is RenderHtmlText) return root.data.isNotEmpty;
      if (root is RenderHtmlDiv) {
        RenderBox? c = root.firstChild;
        while (c != null) {
          if (subtreeHasNonEmptyText(c)) return true;
          final HtmlDivParentData pd = c.parentData as HtmlDivParentData;
          c = pd.nextSibling;
        }
      }
      return false;
    }

    RenderHtmlText? findFirstTextInSubtree(RenderBox root) {
      if (root is RenderHtmlText) return root;
      if (root is RenderHtmlDiv) {
        RenderBox? c = root.firstChild;
        while (c != null) {
          final RenderHtmlText? found = findFirstTextInSubtree(c);
          if (found != null) return found;
          final HtmlDivParentData pd = c.parentData as HtmlDivParentData;
          c = pd.nextSibling;
        }
      }
      return null;
    }

    RenderHtmlText? findFirstTextInRun() {
      for (final RenderBox c in runChildren) {
        final RenderHtmlText? t = findFirstTextInSubtree(c);
        if (t != null) return t;
      }
      return null;
    }

    final RenderHtmlText? firstText = findFirstTextInRun();
    final TextDirection textDirection =
        firstText?.textDirection ?? TextDirection.ltr;

    final TextStyle defaultStyle = firstText?.style ?? const TextStyle();

    final TextScaler textScaler = firstText?.textScaler ?? TextScaler.noScaling;
    final Locale? locale = firstText?.locale;
    final TextWidthBasis textWidthBasis =
        firstText?.textWidthBasis ?? TextWidthBasis.parent;
    final TextHeightBehavior? textHeightBehavior =
        firstText?.textHeightBehavior;
    final int? maxLines = firstText?.maxLines;

    StrutStyle? strutStyle = firstText?.strutStyle;
    if (_lineHeight != null) {
      final double baseFontSize = defaultStyle.fontSize ?? 14.0;
      final double lhPx = _lineHeight!.resolvePx(reference: baseFontSize);
      if (lhPx.isFinite && lhPx > 0) {
        strutStyle = StrutStyle(
          fontSize: baseFontSize,
          height: lhPx / baseFontSize,
          forceStrutHeight: true,
        );
      }
    }

    final TextAlign textAlign = switch (_textAlign) {
      HtmlTextAlign.start => TextAlign.start,
      HtmlTextAlign.center => TextAlign.center,
      HtmlTextAlign.end => TextAlign.end,
      HtmlTextAlign.justify => TextAlign.justify,
    };

    final List<InlineSpan> spanChildren = <InlineSpan>[];
    final List<PlaceholderDimensions> placeholderDims =
        <PlaceholderDimensions>[];
    final List<RenderBox> placeholderChildren = <RenderBox>[];
    final List<EdgeInsets> placeholderMargins = <EdgeInsets>[];
    final List<int> placeholderCharOffsets = <int>[];
    final List<(RenderHtmlText child, int start, int end)> textSegments =
        <(RenderHtmlText, int, int)>[];

    int paragraphOffset = 0;

    final bool hasIndentPlaceholder = firstLineIndentPx > 0;
    if (firstLineIndentPx > 0) {
      spanChildren.add(
        const WidgetSpan(
          child: SizedBox.shrink(),
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
        ),
      );
      placeholderDims.add(
        PlaceholderDimensions(
          size: Size(firstLineIndentPx, 0),
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
          baselineOffset: 0,
        ),
      );
      paragraphOffset += 1;
    }

    final BoxConstraints baseConstraints = childContentMaxHeight == null
        ? BoxConstraints(maxWidth: contentWidth)
        : BoxConstraints(
            maxWidth: contentWidth,
            maxHeight: childContentMaxHeight,
          );

    for (final RenderBox child in runChildren) {
      final HtmlDivParentData pd = child.parentData as HtmlDivParentData;

      if (child is RenderHtmlText) {
        child.setPaintDisabledByParentParagraph(true);
        child.clearParagraphBaselineOverrides();
        child.setParagraphDebugLineCount(null);

        child.layout(baseConstraints, parentUsesSize: true);

        final String paragraphText = _breakAllTextIfNeeded(
          child.data,
          style: child.style ?? defaultStyle,
          maxLineWidth: contentWidth,
          textDirection: textDirection,
          textScaler: textScaler,
          locale: locale,
          textWidthBasis: textWidthBasis,
          textHeightBehavior: textHeightBehavior,
        );
        final int start = paragraphOffset;
        final int end = start + paragraphText.length;
        textSegments.add((child, start, end));
        paragraphOffset = end;

        spanChildren.add(
          TextSpan(
            text: paragraphText,
            style: child.style,
            semanticsLabel: child.semanticsLabel,
          ),
        );
        // We'll set pd.offset after paragraph layout.
        pd.offset = const Offset(-1e9, -1e9);
      } else {
        final EdgeInsets m = RenderHtmlDiv._resolveChildMargin(
          child,
          contentWidth,
        );
        final double childMaxWidth = math.max(0.0, contentWidth - m.horizontal);
        // See display:inline paragraph path in html_div.dart: placeholder
        // children are atomic inline boxes, so prefer max-content measurement
        // for inline RenderHtmlDiv placeholders with auto sizing.
        final bool preferUnboundedWidth =
            child is RenderHtmlDiv &&
            child._display == HtmlDisplay.inline &&
            // Prefer max-content measurement for inline wrappers when the
            // caller explicitly opts into intrinsic sizing (Min/MaxContent)
            // or when line-height is explicitly set.
            //
            // Keep the default behavior for the transparent wrapper used for
            // delegated text-indent (width:auto, no lineHeight), which must be
            // forced to the full line width.
            (child._lineHeight != null ||
                child._width is MinContent ||
                child._width is MaxContent) &&
            child._minWidth == null &&
            child._maxWidth == null;

        final BoxConstraints childConstraints = childContentMaxHeight == null
            ? BoxConstraints(
                maxWidth: preferUnboundedWidth
                    ? double.infinity
                    : childMaxWidth,
              )
            : BoxConstraints(
                maxWidth: preferUnboundedWidth
                    ? double.infinity
                    : childMaxWidth,
                maxHeight: childContentMaxHeight,
              );
        child.layout(childConstraints, parentUsesSize: true);

        // CSS-like baseline behavior:
        // - Inline span wrappers with in-flow text align by alphabetic baseline.
        // - Otherwise align by bottom edge (replaced elements).
        final bool useAlphabeticBaseline =
            child is RenderHtmlDiv &&
            child._display == HtmlDisplay.inline &&
            subtreeHasNonEmptyText(child);
        final double baselineFromTop = useAlphabeticBaseline
            ? (child.getDistanceToBaseline(
                    TextBaseline.alphabetic,
                    onlyReal: true,
                  ) ??
                  child.getDistanceToBaseline(TextBaseline.alphabetic) ??
                  child.size.height)
            : child.size.height;

        placeholderChildren.add(child);
        placeholderMargins.add(m);
        placeholderCharOffsets.add(paragraphOffset);
        spanChildren.add(
          const WidgetSpan(
            child: SizedBox.shrink(),
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
          ),
        );
        placeholderDims.add(
          PlaceholderDimensions(
            size: Size(
              child.size.width + m.horizontal,
              child.size.height + m.vertical,
            ),
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            baselineOffset: m.top + baselineFromTop,
          ),
        );
        paragraphOffset += 1;
        // Placeholder children will be positioned by TextBoxes derived from
        // getBoxesForSelection for the placeholder character.
      }
    }

    final TextPainter painter = TextPainter(
      text: TextSpan(children: spanChildren, style: defaultStyle),
      textAlign: textAlign,
      textDirection: textDirection,
      textScaler: textScaler,
      maxLines: maxLines,
      locale: locale,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      strutStyle: strutStyle,
    );
    painter.setPlaceholderDimensions(placeholderDims);
    final double maxWidth = contentWidth.isFinite
        ? contentWidth
        : double.infinity;
    final double minWidth = contentWidth.isFinite ? contentWidth : 0.0;
    // IMPORTANT: TextPainter may choose a width smaller than maxWidth unless
    // minWidth is also provided. For CSS-like text-align, the line box width
    // must be the available content width.
    painter.layout(minWidth: minWidth, maxWidth: maxWidth);

    final List<LineMetrics> metrics = painter.computeLineMetrics();

    int findLineIndexForBox(TextBox b) {
      if (metrics.isEmpty) return 0;
      final double y = (b.top + b.bottom) / 2.0;
      for (int i = 0; i < metrics.length; i++) {
        final LineMetrics m = metrics[i];
        final double top = m.baseline - m.ascent;
        final double bottom = m.baseline + m.descent;
        if (y >= top - 0.01 && y <= bottom + 0.01) return i;
      }
      int best = 0;
      double bestDist = double.infinity;
      for (int i = 0; i < metrics.length; i++) {
        final double dist = (metrics[i].baseline - y).abs();
        if (dist < bestDist) {
          bestDist = dist;
          best = i;
        }
      }
      return best;
    }

    // In mixed paragraphs that include WidgetSpan-like placeholders, the line
    // widths reported by LineMetrics can be influenced by the leading indent
    // placeholder in ways that break textAlign for wrapped non-first lines.
    // To keep CSS-like semantics, compute per-line content bounds using actual
    // TextBoxes (text + placeholders) in paragraph coordinates.
    final int lineCount = metrics.length;
    final List<double> lineMinX = List<double>.filled(
      lineCount,
      double.infinity,
    );
    final List<double> lineMaxX = List<double>.filled(
      lineCount,
      -double.infinity,
    );
    void recordLineBox(int lineIndex, TextBox b) {
      if (lineCount == 0) return;
      final int i = lineIndex.clamp(0, lineCount - 1);
      lineMinX[i] = math.min(lineMinX[i], b.left);
      lineMaxX[i] = math.max(lineMaxX[i], b.right);
    }

    // Collect placeholder boxes using selection so they are in the same
    // coordinate space as text selection boxes.
    if (hasIndentPlaceholder) {
      final List<TextBox> b = painter.getBoxesForSelection(
        const TextSelection(baseOffset: 0, extentOffset: 1),
      );
      if (b.isNotEmpty) {
        recordLineBox(findLineIndexForBox(b.first), b.first);
      }
    }

    final List<TextBox> placeholderChildBoxes = <TextBox>[];
    for (final int off in placeholderCharOffsets) {
      final List<TextBox> b = painter.getBoxesForSelection(
        TextSelection(baseOffset: off, extentOffset: off + 1),
      );
      if (b.isEmpty) {
        // Fallback: best-effort to keep layout working if selection boxes are
        // unavailable for placeholders on a given engine.
        //
        // NOTE: This may reintroduce alignment inconsistencies on some
        // platforms/versions; prefer the selection-based path.
        final List<TextBox>? fallback = painter.inlinePlaceholderBoxes;
        final int baseIndex = hasIndentPlaceholder ? 1 : 0;
        final int i = placeholderChildBoxes.length;
        if (fallback != null && baseIndex + i < fallback.length) {
          placeholderChildBoxes.add(fallback[baseIndex + i]);
          recordLineBox(
            findLineIndexForBox(fallback[baseIndex + i]),
            fallback[baseIndex + i],
          );
        }
        continue;
      }
      // A placeholder occupies a single box in typical cases.
      placeholderChildBoxes.add(b.first);
      for (final TextBox tb in b) {
        recordLineBox(findLineIndexForBox(tb), tb);
      }
    }

    final List<List<TextBox>> cachedTextBoxes = <List<TextBox>>[];
    for (final (RenderHtmlText _, int start, int end) in textSegments) {
      if (start == end) {
        cachedTextBoxes.add(const <TextBox>[]);
        continue;
      }
      final List<TextBox> tBoxes = painter.getBoxesForSelection(
        TextSelection(baseOffset: start, extentOffset: end),
      );
      cachedTextBoxes.add(tBoxes);
      for (final TextBox b in tBoxes) {
        recordLineBox(findLineIndexForBox(b), b);
      }
    }

    // Some engines (notably with forced strut height) can position large
    // baseline-aligned placeholders above y=0 in paragraph coordinates when a
    // small line-height is combined with a tall replaced element.
    //
    // IMPORTANT:
    // - For text-only runs, keep legacy behavior: run height ~= painter.height
    //   (tests rely on this).
    // - When baseline-aligned placeholders produce negative tops, painter.height
    //   may be measured in a different implicit coordinate system (top-clamped
    //   to 0), which can double-count height if combined with negative tops.
    //   In that case, derive maxRunBottom from aligned bottoms instead.
    double minRunTop = 0.0;
    double maxRunBottom = painter.height;

    double maxAlignedBottom = 0.0;
    // NOTE: We intentionally don't use LineMetrics for bottom extents here,
    // because different Flutter engines/versions can disagree on how the
    // "leading" portion is represented. Selection boxes already reflect the
    // painted extents for text, and placeholderTop+size reflects the intended
    // extents for placeholders.

    final int placeholderDimsBaseIndex = hasIndentPlaceholder ? 1 : 0;
    for (int i = 0; i < placeholderChildBoxes.length; i++) {
      final TextBox b = placeholderChildBoxes[i];
      final int lineIndex = findLineIndexForBox(b);
      if (metrics.isNotEmpty &&
          lineIndex >= 0 &&
          lineIndex < metrics.length &&
          placeholderDimsBaseIndex + i < placeholderDims.length) {
        final PlaceholderDimensions d =
            placeholderDims[placeholderDimsBaseIndex + i];
        final double phTop =
            (metrics[lineIndex].baseline - (d.baselineOffset ?? 0.0))
                .toDouble();
        minRunTop = math.min(minRunTop, phTop);
        maxAlignedBottom = math.max(maxAlignedBottom, phTop + d.size.height);
      } else {
        // Fallback to box-reported extents.
        minRunTop = math.min(minRunTop, b.top);
        maxAlignedBottom = math.max(maxAlignedBottom, b.bottom);
      }
    }
    for (final List<TextBox> boxes in cachedTextBoxes) {
      for (final TextBox b in boxes) {
        minRunTop = math.min(minRunTop, b.top);
        maxAlignedBottom = math.max(maxAlignedBottom, b.bottom);
      }
    }

    // Always expand to include any aligned bottoms we observed.
    maxRunBottom = math.max(maxRunBottom, maxAlignedBottom);

    // If we detected negative tops, avoid mixing with painter.height. In this
    // scenario, use aligned bottoms (line metrics + placeholders + text boxes)
    // as the run's bottom extent.
    if (minRunTop < 0) {
      maxRunBottom = math.max(maxAlignedBottom, 0.0);
    }
    final double runShiftY = minRunTop < 0 ? -minRunTop : 0.0;

    double computedLineWidth(int lineIndex) {
      if (lineCount == 0) return 0.0;
      final int i = lineIndex.clamp(0, lineCount - 1);
      final double minX = lineMinX[i];
      if (minX == double.infinity) {
        return metrics[i].width;
      }
      return math.max(0.0, lineMaxX[i] - minX);
    }

    double computedLineMin(int lineIndex) {
      if (lineCount == 0) return 0.0;
      final int i = lineIndex.clamp(0, lineCount - 1);
      final double minX = lineMinX[i];
      return minX == double.infinity ? 0.0 : minX;
    }

    // If this paragraph run is only a single HtmlText (plus optional indent placeholder),
    // we can directly expose the paragraph's line count via the text render box for tests.
    if (textSegments.length == 1 && placeholderChildren.isEmpty) {
      textSegments.first.$1.setParagraphDebugLineCount(metrics.length);
    }

    // IMPORTANT:
    // - In practice, TextPainter's text boxes for placeholders
    //   (inlinePlaceholderBoxes) can already include the paragraph's alignment
    //   offset, while text selection boxes do not.
    // - To keep placeholders synced with painted text, we position placeholders
    //   using their TextBox coordinates directly (no extra line-left shift),
    //   but still compute per-line alignment offsets for mapping text selection
    //   boxes back to per-child offsets/baselines.

    double lineStartOffsetX(int lineIndex) {
      if (metrics.isEmpty) return 0.0;
      // Do not rely on LineMetrics.width here. After forcing TextPainter to
      // occupy the full content width (minWidth=maxWidth), some engines report
      // LineMetrics.width equal to that full width, which would make
      // center/end alignment appear as start. Instead, compute the per-line
      // content bounds from selection boxes (text + placeholders).
      final double lineWidth = computedLineWidth(lineIndex);
      final double lineMin = computedLineMin(lineIndex);
      final bool isRtl = textDirection == TextDirection.rtl;

      double alignOffset;
      switch (textAlign) {
        case TextAlign.center:
          alignOffset = (contentWidth - lineWidth) / 2.0;
          break;
        case TextAlign.right:
          alignOffset = contentWidth - lineWidth;
          break;
        case TextAlign.left:
          alignOffset = 0.0;
          break;
        case TextAlign.end:
          alignOffset = isRtl ? 0.0 : (contentWidth - lineWidth);
          break;
        case TextAlign.start:
          alignOffset = isRtl ? (contentWidth - lineWidth) : 0.0;
          break;
        case TextAlign.justify:
          alignOffset = 0.0;
          break;
      }

      // Normalize boxes so the left-most content starts at alignOffset.
      alignOffset -= lineMin;

      // Support negative text-indent by shifting the first formatted line.
      // Positive indent is represented via the leading placeholder.
      if (lineIndex == 0 && firstLineIndentPx < 0) {
        alignOffset += firstLineIndentPx;
      }

      return alignOffset;
    }

    // In mixed inline paragraphs that include placeholders (WidgetSpan-like),
    // some engines treat a leading indent placeholder as paragraph padding.
    // We want CSS-like semantics: positive text-indent affects only the first
    // formatted line.
    //
    // For center/end/right alignment, our per-line width/minX based
    // lineStartOffsetX() normalization is sufficient.
    // For start/left/justify alignment, we still need an explicit correction
    // to avoid the indent leaking onto subsequent lines.
    double positiveIndentCorrectionForLine(int lineIndex) {
      if (firstLineIndentPx <= 0) return 0.0;
      if (lineIndex == 0) return 0.0;
      if (textSegments.isEmpty || placeholderChildren.isEmpty) return 0.0;
      switch (textAlign) {
        case TextAlign.start:
        case TextAlign.left:
        case TextAlign.justify:
          return -firstLineIndentPx;
        case TextAlign.center:
        case TextAlign.right:
        case TextAlign.end:
          return 0.0;
      }
    }

    if (placeholderChildBoxes.isNotEmpty) {
      for (int i = 0; i < placeholderChildren.length; i++) {
        if (i >= placeholderChildBoxes.length) break;
        final RenderBox ph = placeholderChildren[i];
        final EdgeInsets m = placeholderMargins[i];
        final HtmlDivParentData pd = ph.parentData as HtmlDivParentData;
        final TextBox b = placeholderChildBoxes[i];
        final int lineIndex = findLineIndexForBox(b);
        final double lineLeft = lineStartOffsetX(lineIndex);
        final double indentCorrection = positiveIndentCorrectionForLine(
          lineIndex,
        );
        double placeholderTop = b.top;
        if (metrics.isNotEmpty &&
            lineIndex >= 0 &&
            lineIndex < metrics.length &&
            placeholderDimsBaseIndex + i < placeholderDims.length) {
          final PlaceholderDimensions d =
              placeholderDims[placeholderDimsBaseIndex + i];
          placeholderTop =
              (metrics[lineIndex].baseline - (d.baselineOffset ?? 0.0))
                  .toDouble();
        }
        pd.offset = Offset(
          xOffset + lineLeft + b.left + indentCorrection + m.left,
          yTop + runShiftY + placeholderTop + m.top,
        );
      }
    }

    int textSegmentIndex = 0;
    for (final (RenderHtmlText t, int start, int end) in textSegments) {
      final HtmlDivParentData pd = t.parentData as HtmlDivParentData;
      if (start == end) {
        pd.offset = Offset(xOffset, yTop + runShiftY);
        continue;
      }

      final List<TextBox> tBoxes = cachedTextBoxes[textSegmentIndex++];
      if (tBoxes.isEmpty) {
        final Offset caret = painter.getOffsetForCaret(
          TextPosition(offset: start),
          Rect.zero,
        );
        pd.offset = Offset(xOffset + caret.dx, yTop + runShiftY + caret.dy);
        continue;
      }

      Rect r = tBoxes.first.toRect().shift(
        Offset(
          lineStartOffsetX(findLineIndexForBox(tBoxes.first)) +
              positiveIndentCorrectionForLine(
                findLineIndexForBox(tBoxes.first),
              ),
          0,
        ),
      );
      for (int i = 1; i < tBoxes.length; i++) {
        final TextBox tb = tBoxes[i];
        final int lineIndex = findLineIndexForBox(tb);
        final double lineLeft = lineStartOffsetX(lineIndex);
        final double indentCorrection = positiveIndentCorrectionForLine(
          lineIndex,
        );
        r = r.expandToInclude(
          tb.toRect().shift(Offset(lineLeft + indentCorrection, 0)),
        );
      }

      final int firstLine = findLineIndexForBox(tBoxes.first);
      final int lastLine = findLineIndexForBox(tBoxes.last);
      // Keep DevTools/tests in sync with actual unified paragraph wrapping.
      // Derive the line count from the segment's own selection boxes to avoid
      // off-by-one issues when the paragraph includes indent-only/placeholder lines.
      int countLinesFromBoxes(List<TextBox> boxes) {
        if (boxes.isEmpty) return 0;
        final Set<int> lines = <int>{};
        for (final TextBox b in boxes) {
          lines.add(findLineIndexForBox(b));
        }
        return lines.length;
      }

      t.setParagraphDebugLineCount(countLinesFromBoxes(tBoxes));
      final double firstBaselineFromTop = metrics.isEmpty
          ? 0.0
          : metrics[firstLine].baseline - r.top;
      final double lastBaselineFromTop = metrics.isEmpty
          ? 0.0
          : metrics[lastLine].baseline - r.top;
      t.setParagraphBaselineOverrides(
        firstLineBaselineFromTop: firstBaselineFromTop,
        lastLineBaselineFromTop: lastBaselineFromTop,
      );
      pd.offset = Offset(xOffset + r.left, yTop + runShiftY + r.top);
    }

    final double runHeight = math.max(0.0, maxRunBottom - minRunTop);

    return _ParagraphRun(
      painter: painter,
      offset: Offset(xOffset, yTop + runShiftY),
      height: runHeight,
    );
  }
}
