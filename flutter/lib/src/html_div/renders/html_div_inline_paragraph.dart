part of '../../../html_div.dart';

final RegExp _breakAllWhitespaceRegExp = RegExp(r'\s');

extension _RenderHtmlDivInlineParagraphExt on RenderHtmlDiv {
  String _breakAllTextIfNeeded(String s) {
    // Prefer normal whitespace wrapping when there are break opportunities.
    // For long unbroken runs, add zero-width break points so trailing text
    // can still consume remaining line space (CSS-like break-all).
    if (s.length <= 1) return s;
    if (s.contains(_breakAllWhitespaceRegExp)) return s;
    if (s.contains('\u200B')) return s;
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

        final String paragraphText = _breakAllTextIfNeeded(child.data);
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
        final BoxConstraints childConstraints = childContentMaxHeight == null
            ? BoxConstraints(maxWidth: childMaxWidth)
            : BoxConstraints(
                maxWidth: childMaxWidth,
                maxHeight: childContentMaxHeight,
              );
        child.layout(childConstraints, parentUsesSize: true);

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
            baselineOffset: m.top + child.size.height,
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
        pd.offset = Offset(
          xOffset + lineLeft + b.left + indentCorrection + m.left,
          yTop + b.top + m.top,
        );
      }
    }

    int textSegmentIndex = 0;
    for (final (RenderHtmlText t, int start, int end) in textSegments) {
      final HtmlDivParentData pd = t.parentData as HtmlDivParentData;
      if (start == end) {
        pd.offset = Offset(xOffset, yTop);
        continue;
      }

      final List<TextBox> tBoxes = cachedTextBoxes[textSegmentIndex++];
      if (tBoxes.isEmpty) {
        final Offset caret = painter.getOffsetForCaret(
          TextPosition(offset: start),
          Rect.zero,
        );
        pd.offset = Offset(xOffset + caret.dx, yTop + caret.dy);
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
      pd.offset = Offset(xOffset + r.left, yTop + r.top);
    }

    double runHeight = painter.height;
    if (textSegments.isEmpty && placeholderDims.isNotEmpty) {
      double maxPlaceholderHeight = 0.0;
      for (final PlaceholderDimensions d in placeholderDims) {
        maxPlaceholderHeight = math.max(maxPlaceholderHeight, d.size.height);
      }
      runHeight = math.max(runHeight, maxPlaceholderHeight);
    }

    return _ParagraphRun(
      painter: painter,
      offset: Offset(xOffset, yTop),
      height: runHeight,
    );
  }
}
