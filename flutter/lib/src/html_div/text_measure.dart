part of '../../html_div.dart';

/// 【工具方法】计算给定文本在指定宽度/样式/缩进规则下占用的“排版行数”。
///
/// 该方法用于测试：让“纯测量”结果尽量对齐实际渲染。
///
/// 当前 HtmlDiv 的 unified paragraph 会通过一个“首行缩进占位符”(WidgetSpan)
/// 来实现 text-indent，因此这里也复用相同的 TextPainter + placeholder
/// 方案来计算行数。
///
/// 注意：行数是“在给定布局约束下”的结果；若 maxWidth/字体/平台不同，结果也可能不同。
int measureTextLineCount({
  required String text,
  required TextStyle style,
  required double maxWidth,
  double firstLineIndentPx = 0.0,
  TextAlign textAlign = TextAlign.start,
  required TextDirection textDirection,
  TextScaler textScaler = TextScaler.noScaling,
  Locale? locale,
  StrutStyle? strutStyle,
  TextWidthBasis textWidthBasis = TextWidthBasis.parent,
  TextHeightBehavior? textHeightBehavior,
  int? maxLines,
  String? semanticsLabel,
}) {
  // 与渲染路径一致：无界宽度时按无限宽处理。
  final double effectiveMaxWidth = maxWidth.isFinite
      ? maxWidth
      : double.infinity;

  String breakAllIfNeeded(String s) {
    if (s.length <= 1) return s;
    if (s.contains(RegExp(r'\s'))) return s;
    if (s.contains('\u200B')) return s;
    return s.characters.join('\u200B');
  }

  final String paragraphText = breakAllIfNeeded(text);

  // Mirror HtmlDiv's unified paragraph behavior:
  // - optional first-line indent implemented via a placeholder span
  // - the paragraph is laid out with minWidth=maxWidth=contentWidth
  //   to match CSS-like line box semantics.
  final List<InlineSpan> spanChildren = <InlineSpan>[];
  final List<PlaceholderDimensions> placeholderDims = <PlaceholderDimensions>[];

  // Extreme indent: match current rendering behavior by ignoring indent when
  // it consumes the whole line width (indent >= maxWidth).
  final bool applyIndentPlaceholder =
      firstLineIndentPx > 0.0 &&
      effectiveMaxWidth.isFinite &&
      firstLineIndentPx < effectiveMaxWidth;

  if (applyIndentPlaceholder) {
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
  }

  spanChildren.add(
    TextSpan(text: paragraphText, style: style, semanticsLabel: semanticsLabel),
  );

  final TextPainter painter = TextPainter(
    text: TextSpan(children: spanChildren),
    textAlign: textAlign,
    textDirection: textDirection,
    textScaler: textScaler,
    maxLines: maxLines,
    locale: locale,
    strutStyle: strutStyle,
    textWidthBasis: textWidthBasis,
    textHeightBehavior: textHeightBehavior,
    ellipsis: null,
  );

  if (placeholderDims.isNotEmpty) {
    painter.setPlaceholderDimensions(placeholderDims);
  }

  if (effectiveMaxWidth.isFinite) {
    painter.layout(minWidth: effectiveMaxWidth, maxWidth: effectiveMaxWidth);
  } else {
    painter.layout(maxWidth: effectiveMaxWidth);
  }

  return painter.computeLineMetrics().length;
}

int _adjustCjkSplitIndexIfNeeded({required String text, required int end}) {
  // 与 RenderHtmlText 当前逻辑一致：只对“无空格”的字符串做 CJK 断行微调。
  if (end <= 0 || end >= text.length) return end;
  if (text.contains(RegExp(r'\s'))) return end;

  int stepBackOneRune(int index) {
    int newIndex = index - 1;
    if (newIndex > 0) {
      final int cu = text.codeUnitAt(newIndex);
      // 如果落在低代理项上，再退一格。
      if (cu >= 0xDC00 && cu <= 0xDFFF) {
        newIndex = math.max(0, newIndex - 1);
      }
    }
    return newIndex;
  }

  bool isCommonPunctuationOrSpace(int ch) {
    if (ch == 0x20) return true; // space
    if (ch >= 0x3000 && ch <= 0x303F) return true; // CJK punctuation
    if (ch >= 0xFF00 && ch <= 0xFF65) return true; // Fullwidth forms/punct
    if (ch == 0x0021 ||
        ch == 0x002C ||
        ch == 0x002E ||
        ch == 0x003A ||
        ch == 0x003B ||
        ch == 0x003F) {
      return true;
    }
    return false;
  }

  bool isAllPunctOrSpace(String s) {
    if (s.isEmpty) return false;
    for (final int r in s.runes) {
      if (!isCommonPunctuationOrSpace(r)) return false;
    }
    return true;
  }

  int adjusted = end;

  // 【尽量填满】默认不做“尾巴过短”回退，避免首行留白过大。
  // 仅当 remainder 全是标点（末行可能只剩标点）时才有限回退。
  const int kMaxStepBackRunes = 8;
  int steps = 0;
  while (adjusted > 0 && adjusted < text.length && steps < kMaxStepBackRunes) {
    final String restProbe = text.substring(adjusted);
    if (!isAllPunctOrSpace(restProbe)) {
      break;
    }
    final int newEnd = stepBackOneRune(adjusted);
    if (newEnd < 0 || newEnd >= adjusted) break;
    adjusted = newEnd;
    steps++;
  }

  // 避免出现“，第”把“第”留在行尾。
  if (adjusted > 1 && adjusted < text.length) {
    final int lastCu = text.codeUnitAt(adjusted - 1);
    if (lastCu == 0x7B2C) {
      // '第'
      final int prevCu = text.codeUnitAt(adjusted - 2);
      if (isCommonPunctuationOrSpace(prevCu)) {
        adjusted = stepBackOneRune(adjusted);
      }
    }
  }

  if (adjusted < 0) return 0;
  if (adjusted > text.length) return text.length;
  return adjusted;
}
