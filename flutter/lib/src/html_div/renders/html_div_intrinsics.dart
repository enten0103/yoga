part of '../../../html_div.dart';

// Intrinsic sizing helpers for RenderHtmlDiv.
//
// These are split out from html_div.dart to keep RenderHtmlDiv's core layout
// logic readable, while sharing the same private helpers/types.

double _inlineMinContentWidth(RenderBox? firstChild, double height) {
  double maxBoxWidth = 0;
  RenderBox? child = firstChild;
  while (child != null) {
    final EdgeInsets m = RenderHtmlDiv._resolveChildMargin(child, 0);
    final double childWidth = child.getMinIntrinsicWidth(height);
    maxBoxWidth = math.max(maxBoxWidth, childWidth + m.horizontal);
    child = (child.parentData as HtmlDivParentData).nextSibling;
  }
  return maxBoxWidth;
}

double _paragraphRunMaxContentWidth(
  List<RenderBox> runChildren,
  double height,
) {
  RenderHtmlText? firstText;
  for (final RenderBox c in runChildren) {
    if (c is RenderHtmlText) {
      firstText = c;
      break;
    }
  }

  final TextDirection textDirection =
      firstText?.textDirection ?? TextDirection.ltr;
  final TextStyle defaultStyle = firstText?.style ?? const TextStyle();
  final TextScaler textScaler = firstText?.textScaler ?? TextScaler.noScaling;
  final Locale? locale = firstText?.locale;
  final TextHeightBehavior? textHeightBehavior = firstText?.textHeightBehavior;

  final List<InlineSpan> spans = <InlineSpan>[];
  final List<PlaceholderDimensions> placeholderDims = <PlaceholderDimensions>[];

  for (final RenderBox child in runChildren) {
    final EdgeInsets m = RenderHtmlDiv._resolveChildMargin(child, 0);
    if (child is RenderHtmlText) {
      spans.add(
        TextSpan(
          text: child.data,
          style: child.style,
          semanticsLabel: child.semanticsLabel,
        ),
      );
    } else {
      final double w = child.getMaxIntrinsicWidth(height) + m.horizontal;
      spans.add(
        const WidgetSpan(
          child: SizedBox.shrink(),
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
        ),
      );
      placeholderDims.add(
        PlaceholderDimensions(
          size: Size(w, 0),
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
          baselineOffset: 0,
        ),
      );
    }
  }

  final TextPainter painter = TextPainter(
    text: TextSpan(children: spans, style: defaultStyle),
    textDirection: textDirection,
    textScaler: textScaler,
    locale: locale,
    textHeightBehavior: textHeightBehavior,
    textWidthBasis: TextWidthBasis.parent,
  );
  if (placeholderDims.isNotEmpty) {
    painter.setPlaceholderDimensions(placeholderDims);
  }
  painter.layout(maxWidth: double.infinity);
  return painter.width;
}

double _paragraphLikeMaxContentWidth(RenderBox? firstChild, double h) {
  double maxLineWidth = 0;
  final List<RenderBox> run = <RenderBox>[];

  void flushRun() {
    if (run.isEmpty) return;
    maxLineWidth = math.max(maxLineWidth, _paragraphRunMaxContentWidth(run, h));
    run.clear();
  }

  RenderBox? child = firstChild;
  while (child != null) {
    final HtmlDisplay d = RenderHtmlDiv._readChildHtmlDisplay(child);
    if (d == HtmlDisplay.inline) {
      run.add(child);
    } else {
      flushRun();
      final EdgeInsets m = RenderHtmlDiv._resolveChildMargin(child, 0);
      maxLineWidth = math.max(
        maxLineWidth,
        child.getMaxIntrinsicWidth(h) + m.horizontal,
      );
    }
    child = (child.parentData as HtmlDivParentData).nextSibling;
  }

  flushRun();
  return maxLineWidth;
}

double _inlineIntrinsicHeight(
  RenderBox? firstChild,
  double width,
  HtmlLength? lineHeight,
  HtmlLength textIndent,
  double indentReferenceWidth,
) {
  if (!width.isFinite || width <= 0) return 0;

  final double indentPx = textIndent.isPercent
      ? textIndent.resolvePx(reference: indentReferenceWidth)
      : textIndent.resolvePx(reference: width);
  bool indentApplied = false;
  double currentLineIndent = 0;

  double currentY = 0;
  double inlineX = 0;
  double lineAscent = 0;
  double lineDescent = 0;

  final (double strutAscent, double strutDescent) =
      RenderHtmlDiv._computeLineHeightStrut(firstChild, lineHeight);

  double flushLine() {
    if (lineAscent + lineDescent <= 0) return 0;
    final double finalAscent = math.max(lineAscent, strutAscent);
    final double finalDescent = math.max(lineDescent, strutDescent);
    return finalAscent + finalDescent;
  }

  RenderBox? child = firstChild;
  while (child != null) {
    final HtmlDisplay d = RenderHtmlDiv._readChildHtmlDisplay(child);
    final EdgeInsets m = RenderHtmlDiv._resolveChildMargin(child, width);

    if (d == HtmlDisplay.inline) {
      if (inlineX == 0) {
        currentLineIndent = indentApplied ? 0.0 : indentPx;
      }
      final double available = math.max(0.0, width - currentLineIndent);
      final double childMaxWidth = math.max(0.0, available - m.horizontal);

      (double w, double h, double baseline) measure(
        RenderBox box,
        double maxWidth,
      ) {
        if (box is RenderParagraph) {
          final RenderParagraph p = box;
          final TextPainter painter = TextPainter(
            text: p.text,
            textAlign: p.textAlign,
            textDirection: p.textDirection,
            textScaler: p.textScaler,
            maxLines: p.maxLines,
            locale: p.locale,
            strutStyle: p.strutStyle,
            textWidthBasis: p.textWidthBasis,
            textHeightBehavior: p.textHeightBehavior,
          )..layout(maxWidth: maxWidth);

          final double h = painter.height;
          final double baseline = painter.computeDistanceToActualBaseline(
            TextBaseline.alphabetic,
          );
          return (painter.width, h, baseline.clamp(0.0, h));
        }

        final double w = math.min(
          box.getMaxIntrinsicWidth(double.infinity),
          maxWidth,
        );
        final double h = box.getMaxIntrinsicHeight(maxWidth);
        return (w, h, h);
      }

      final RenderBox childBox = child;
      var (double childWidth, double childHeight, double baselineDistance) =
          measure(childBox, childMaxWidth);

      double inlineBoxWidth = childWidth + m.horizontal;
      if (inlineX > 0 && inlineX + inlineBoxWidth > available) {
        currentY += flushLine();
        inlineX = 0;
        lineAscent = 0;
        lineDescent = 0;
        indentApplied = true;
        currentLineIndent = 0;

        final double newAvailable = math.max(0.0, width - currentLineIndent);
        final double newChildMaxWidth = math.max(
          0.0,
          newAvailable - m.horizontal,
        );
        final measured = measure(childBox, newChildMaxWidth);
        childWidth = measured.$1;
        childHeight = measured.$2;
        baselineDistance = measured.$3;
        inlineBoxWidth = childWidth + m.horizontal;
      }

      inlineX += inlineBoxWidth;
      final double ascent = m.top + baselineDistance;
      final double descent =
          m.bottom + math.max(0.0, childHeight - baselineDistance);
      lineAscent = math.max(lineAscent, ascent);
      lineDescent = math.max(lineDescent, descent);

      if (!indentApplied) {
        indentApplied = true;
      }
    } else {
      if (inlineX > 0) {
        currentY += flushLine();
        inlineX = 0;
        lineAscent = 0;
        lineDescent = 0;
        indentApplied = true;
        currentLineIndent = 0;
      }
      final double childMaxWidth = math.max(0.0, width - m.horizontal);
      final double childHeight = child.getMaxIntrinsicHeight(childMaxWidth);
      currentY += m.top + childHeight + m.bottom;
    }

    child = (child.parentData as HtmlDivParentData).nextSibling;
  }

  if (inlineX > 0) {
    currentY += flushLine();
  }

  return currentY;
}
