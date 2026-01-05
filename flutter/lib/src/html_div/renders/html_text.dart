part of '../../../html_div.dart';

class HtmlText extends LeafRenderObjectWidget {
  final String data;
  final TextStyle? style;
  final TextAlign textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final StrutStyle? strutStyle;
  final TextWidthBasis textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final TextScaler textScaler;
  final int? maxLines;
  final String? semanticsLabel;

  const HtmlText(
    this.data, {
    super.key,
    this.style,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.locale,
    this.strutStyle,
    this.textWidthBasis = TextWidthBasis.parent,
    this.textHeightBehavior,
    this.textScaler = TextScaler.noScaling,
    this.maxLines,
    this.semanticsLabel,
  });

  factory HtmlText.fromText(Text text) {
    final String data = text.data ?? '';
    return HtmlText(
      data,
      key: text.key,
      style: text.style,
      textAlign: text.textAlign ?? TextAlign.start,
      textDirection: text.textDirection,
      locale: text.locale,
      strutStyle: text.strutStyle,
      textWidthBasis: text.textWidthBasis ?? TextWidthBasis.parent,
      textHeightBehavior: text.textHeightBehavior,
      textScaler: text.textScaler ?? TextScaler.noScaling,
      maxLines: text.maxLines,
      semanticsLabel: text.semanticsLabel,
    );
  }

  @override
  RenderObject createRenderObject(BuildContext context) {
    final TextStyle baseStyle = DefaultTextStyle.of(context).style;
    final TextStyle effectiveStyle = style == null
        ? baseStyle
        : baseStyle.merge(style);
    return RenderHtmlText(
      data: data,
      style: effectiveStyle,
      textAlign: textAlign,
      textDirection: textDirection ?? Directionality.of(context),
      locale: locale,
      strutStyle: strutStyle,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      textScaler: textScaler,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderHtmlText renderObject) {
    final TextStyle baseStyle = DefaultTextStyle.of(context).style;
    final TextStyle effectiveStyle = style == null
        ? baseStyle
        : baseStyle.merge(style);
    renderObject
      ..data = data
      ..style = effectiveStyle
      ..textAlign = textAlign
      ..textDirection = textDirection ?? Directionality.of(context)
      ..locale = locale
      ..strutStyle = strutStyle
      ..textWidthBasis = textWidthBasis
      ..textHeightBehavior = textHeightBehavior
      ..textScaler = textScaler
      ..maxLines = maxLines
      ..semanticsLabel = semanticsLabel;
  }
}

class RenderHtmlText extends RenderBox {
  RenderHtmlText({
    required String data,
    TextStyle? style,
    TextAlign textAlign = TextAlign.start,
    required TextDirection textDirection,
    Locale? locale,
    StrutStyle? strutStyle,
    TextWidthBasis textWidthBasis = TextWidthBasis.parent,
    TextHeightBehavior? textHeightBehavior,
    TextScaler textScaler = TextScaler.noScaling,
    int? maxLines,
    String? semanticsLabel,
  }) : _data = data,
       _style = style,
       _textAlign = textAlign,
       _textDirection = textDirection,
       _locale = locale,
       _strutStyle = strutStyle,
       _textWidthBasis = textWidthBasis,
       _textHeightBehavior = textHeightBehavior,
       _textScaler = textScaler,
       _maxLines = maxLines,
       _semanticsLabel = semanticsLabel;

  String _data;
  TextStyle? _style;
  TextAlign _textAlign;
  TextDirection _textDirection;
  Locale? _locale;
  StrutStyle? _strutStyle;
  TextWidthBasis _textWidthBasis;
  TextHeightBehavior? _textHeightBehavior;
  TextScaler _textScaler;
  int? _maxLines;
  String? _semanticsLabel;

  // Applied during the last layout/paint.
  double _firstLineIndentPx = 0.0;

  // Set by parent during its performLayout. This must NOT call markNeedsLayout
  // because that would be a descendant mutation during layout (asserted by Flutter).
  double _pendingFirstLineIndentPx = 0.0;

  TextPainter? _painterFull;
  TextPainter? _painterFirst;
  TextPainter? _painterRest;
  double _firstLineHeight = 0.0;
  // For inline formatting, browsers align an inline box by the baseline of its
  // LAST line box (not the first). This value stores the distance from this
  // RenderBox's top to the last line's alphabetic baseline.
  double _baselineFromTop = 0.0;

  // First line metrics (distance from top and line box height). These are
  // useful when a multi-line text box participates in the first line box
  // together with other inline boxes (e.g. images): in CSS, each line box
  // aligns by that line's baseline, not the last line of the whole run.
  double _firstLineBaselineFromTop = 0.0;
  double _firstLineBoxHeight = 0.0;

  // Optional overrides provided by a parent that lays out this text as part of
  // a unified paragraph (WidgetSpan/TextPainter-based inline formatting).
  double? _paragraphOverrideFirstLineBaselineFromTop;
  double? _paragraphOverrideLastLineBaselineFromTop;

  // When an ancestor renders this text as part of a unified paragraph, this
  // RenderBox must not paint itself (to avoid double painting).
  bool _paintDisabledByParentParagraph = false;

  // Optional override for tests/debugging when a parent lays out this text as
  // part of a unified paragraph (WidgetSpan/TextPainter-based inline formatting).
  int? _paragraphOverrideDebugLineCount;

  double get firstLineBaselineFromTop =>
      _paragraphOverrideFirstLineBaselineFromTop ?? _firstLineBaselineFromTop;
  double get firstLineBoxHeight => _firstLineBoxHeight;

  // Baseline of the LAST formatted line, measured from this box's top.
  // This mirrors the inline baseline semantics used by RenderHtmlDiv.
  double get lastLineBaselineFromTop =>
      _paragraphOverrideLastLineBaselineFromTop ?? _baselineFromTop;

  void setParagraphBaselineOverrides({
    double? firstLineBaselineFromTop,
    double? lastLineBaselineFromTop,
  }) {
    _paragraphOverrideFirstLineBaselineFromTop = firstLineBaselineFromTop;
    _paragraphOverrideLastLineBaselineFromTop = lastLineBaselineFromTop;
  }

  void clearParagraphBaselineOverrides() {
    _paragraphOverrideFirstLineBaselineFromTop = null;
    _paragraphOverrideLastLineBaselineFromTop = null;
  }

  void setPaintDisabledByParentParagraph(bool disabled) {
    _paintDisabledByParentParagraph = disabled;
  }

  // For inline flow advancement, browsers treat the “advance width” of a
  // multi-line inline text run as the width of its LAST line. This allows
  // following inline boxes (e.g. images) to appear after the text on the last
  // line if there is remaining space.
  double _inlineAdvanceWidth = 0.0;

  double get inlineAdvanceWidth => _inlineAdvanceWidth;

  /// 【测试辅助】返回当前布局结果对应的行数。
  ///
  /// 说明：该值依赖最近一次 performLayout 生成的 TextPainter 状态。
  /// - 未缩进或无需 split 时使用 _painterFull 的 lineMetrics。
  /// - split 时：首行固定为 1 行 + rest 的 lineMetrics。
  @visibleForTesting
  int get debugLineCount {
    final int? override = _paragraphOverrideDebugLineCount;
    int result;
    if (override != null) {
      result = override;
    } else {
      final TextPainter? full = _painterFull;
      if (full != null) {
        result = full.computeLineMetrics().length;
      } else {
        final TextPainter? first = _painterFirst;
        if (first == null) {
          result = 0;
        } else {
          final TextPainter? rest = _painterRest;
          final int restLines = rest == null
              ? 0
              : rest.computeLineMetrics().length;
          result = 1 + restLines;
        }
      }
    }

    return result;
  }

  void setParagraphDebugLineCount(int? value) {
    _paragraphOverrideDebugLineCount = value;
  }

  // Expose inputs for parent layout engines that want to build a unified
  // paragraph (e.g. WidgetSpan/TextPainter-based inline formatting).
  String get data => _data;
  TextStyle? get style => _style;
  TextDirection get textDirection => _textDirection;
  String? get semanticsLabel => _semanticsLabel;
  TextScaler get textScaler => _textScaler;
  Locale? get locale => _locale;
  StrutStyle? get strutStyle => _strutStyle;
  TextWidthBasis get textWidthBasis => _textWidthBasis;
  TextHeightBehavior? get textHeightBehavior => _textHeightBehavior;
  int? get maxLines => _maxLines;

  set data(String value) {
    if (_data != value) {
      _data = value;
      markNeedsLayout();
      markNeedsPaint();
    }
  }

  set style(TextStyle? value) {
    if (_style != value) {
      _style = value;
      markNeedsLayout();
      markNeedsPaint();
    }
  }

  set textAlign(TextAlign value) {
    if (_textAlign != value) {
      _textAlign = value;
      markNeedsLayout();
      markNeedsPaint();
    }
  }

  set textDirection(TextDirection value) {
    if (_textDirection != value) {
      _textDirection = value;
      markNeedsLayout();
      markNeedsPaint();
    }
  }

  set locale(Locale? value) {
    if (_locale != value) {
      _locale = value;
      markNeedsLayout();
      markNeedsPaint();
    }
  }

  set strutStyle(StrutStyle? value) {
    if (_strutStyle != value) {
      _strutStyle = value;
      markNeedsLayout();
      markNeedsPaint();
    }
  }

  set textWidthBasis(TextWidthBasis value) {
    if (_textWidthBasis != value) {
      _textWidthBasis = value;
      markNeedsLayout();
      markNeedsPaint();
    }
  }

  set textHeightBehavior(TextHeightBehavior? value) {
    if (_textHeightBehavior != value) {
      _textHeightBehavior = value;
      markNeedsLayout();
      markNeedsPaint();
    }
  }

  set textScaler(TextScaler value) {
    if (_textScaler != value) {
      _textScaler = value;
      markNeedsLayout();
      markNeedsPaint();
    }
  }

  set maxLines(int? value) {
    if (_maxLines != value) {
      _maxLines = value;
      markNeedsLayout();
      markNeedsPaint();
    }
  }

  set semanticsLabel(String? value) {
    if (_semanticsLabel != value) {
      _semanticsLabel = value;
      markNeedsLayout();
      markNeedsPaint();
    }
  }

  // 【text-indent 完整工作流程（中文说明 / RenderHtmlText 侧）】
  // RenderHtmlDiv 在拼装 inline 行盒时，如果发现当前 child 是“第一条排版行的第一个文本节点”，
  // 会把父容器的 text-indent（像素值）委托给这里：
  // - 通过 `setFirstLineIndentPx(value, forParentLayout: true)` 写入 pending 值；
  // - 注意：这发生在父级 performLayout 期间，不能 markNeedsLayout，否则会触发
  //   Flutter 的「layout 期间修改后代」断言。
  //
  // 本 RenderObject 会在自己的 performLayout 中消费 pending 值，并在 _layoutText 里实现：
  // - 仅缩进首行（first formatted line）；
  // - 后续行使用完整 maxWidth；
  // - 如果在“缩进后的首行宽度”下文本其实不折行，则不做 split（避免出现“看起来单行但高度像两行”的回归）。
  void setFirstLineIndentPx(double value, {bool forParentLayout = false}) {
    if (forParentLayout) {
      _pendingFirstLineIndentPx = value;
      return;
    }

    if (_firstLineIndentPx != value || _pendingFirstLineIndentPx != value) {
      _firstLineIndentPx = value;
      _pendingFirstLineIndentPx = 0.0;
      markNeedsLayout();
      markNeedsPaint();
    }
  }

  InlineSpan _buildSpan(String text) {
    return TextSpan(text: text, style: _style);
  }

  TextPainter _newPainter(InlineSpan span, {int? maxLines}) {
    return TextPainter(
      text: span,
      textAlign: _textAlign,
      textDirection: _textDirection,
      textScaler: _textScaler,
      maxLines: maxLines ?? _maxLines,
      locale: _locale,
      strutStyle: _strutStyle,
      textWidthBasis: _textWidthBasis,
      textHeightBehavior: _textHeightBehavior,
    );
  }

  // 【布局算法（中文说明）】
  // 输入：maxWidth（父级给定的本行可用宽度）以及 _firstLineIndentPx。
  // 输出：
  // - 若不需要首行缩进：用一个 TextPainter 直接 layout。
  // - 若需要首行缩进：
  //   1) 用 firstLineMaxWidth=maxWidth-indent 先 probe 一次，判断是否真的折行；
  //   2) 若 probe 只有 1 行：说明即使考虑缩进也不会折行 -> 不拆分，直接视作单行；
  //   3) 若 probe 多行：计算第一行边界 end，把文本切成 first/rest；
  //   4) first 用 firstLineMaxWidth layout，并在 paint 时整体右移 indent；
  //      rest 用 maxWidth layout，从第二行开始绘制（y 偏移为 first 的高度）；
  //   5) 对无空格的 CJK 文本做一点“尾巴太短(widow)”与“，第”序数前缀的边界微调。
  void _layoutText(double maxWidth) {
    final String full = _data;

    if (_firstLineIndentPx == 0.0 || !maxWidth.isFinite) {
      final TextPainter painter = _newPainter(_buildSpan(full))
        ..layout(maxWidth: maxWidth.isFinite ? maxWidth : double.infinity);
      _painterFull = painter;
      _painterFirst = null;
      _painterRest = null;
      _firstLineHeight = 0.0;
      final List<LineMetrics> metrics = painter.computeLineMetrics();
      if (metrics.isEmpty) {
        _baselineFromTop = 0.0;
        _inlineAdvanceWidth = 0.0;
        _firstLineBaselineFromTop = 0.0;
        _firstLineBoxHeight = 0.0;
      } else {
        final LineMetrics first = metrics.first;
        final LineMetrics last = metrics.last;
        _baselineFromTop = last.baseline;
        _inlineAdvanceWidth = last.width;
        _firstLineBaselineFromTop = first.baseline;
        _firstLineBoxHeight = first.height;
      }
      size = constraints.constrain(Size(painter.width, painter.height));
      return;
    }

    final double indent = _firstLineIndentPx;
    final double firstLineMaxWidth = math.max(0.0, maxWidth - indent);

    // maxLines 需要对“拆分后的 first/rest”整体生效：
    // - first 只能占 1 行；
    // - rest 最多占 (maxLines - 1) 行；
    // 否则会出现：maxLines=2 但实际渲染出 3 行（first 1 行 + rest 2 行）。
    final int? maxLines = _maxLines;
    if (maxLines != null && maxLines <= 1) {
      final TextPainter painterFirst = _newPainter(
        _buildSpan(full),
        maxLines: 1,
      )..layout(maxWidth: firstLineMaxWidth);

      _painterFull = null;
      _painterFirst = painterFirst;
      _painterRest = null;

      _firstLineHeight = painterFirst.height;
      final List<LineMetrics> metrics = painterFirst.computeLineMetrics();
      if (metrics.isEmpty) {
        _baselineFromTop = 0.0;
        _inlineAdvanceWidth = math.max(0.0, indent);
        _firstLineBaselineFromTop = 0.0;
        _firstLineBoxHeight = _firstLineHeight;
      } else {
        final LineMetrics last = metrics.last;
        _baselineFromTop = last.baseline;
        // The text is painted with an x-offset indent.
        _inlineAdvanceWidth = last.width + math.max(0.0, indent);
        _firstLineBaselineFromTop = last.baseline;
        _firstLineBoxHeight = last.height;
      }

      final double w = painterFirst.width + math.max(0.0, indent);
      final double h = painterFirst.height;
      size = constraints.constrain(Size(w, h));
      return;
    }

    // Layout once to find the first-line boundary under the first-line width.
    final TextPainter probe = _newPainter(_buildSpan(full))
      ..layout(maxWidth: firstLineMaxWidth);

    // Use line metrics to detect whether the text actually wraps under the
    // first-line width. When it doesn't wrap, we must NOT split, otherwise
    // we end up with a visually single-line paragraph that still occupies
    // two lines of height.
    final List<LineMetrics> metrics = probe.computeLineMetrics();
    int end;
    if (metrics.length <= 1) {
      end = full.length;
    } else {
      final Offset probeOffset = Offset(
        firstLineMaxWidth,
        probe.preferredLineHeight / 2.0,
      );
      final TextPosition pos = probe.getPositionForOffset(probeOffset);
      final TextRange firstLineRange = probe.getLineBoundary(pos);
      end = firstLineRange.end;
    }
    if (end < 0) end = 0;
    if (end > full.length) end = full.length;

    // CJK-friendly adjustment: when applying a first-line indent by splitting
    // the text, the naive boundary may leave a very short remainder (e.g. a
    // single Han character + punctuation) on the next line. For whitespace-free
    // strings, shift the boundary back by one rune to avoid that.
    if (end > 0 && end < full.length && !full.contains(RegExp(r'\s'))) {
      int stepBackOneRune(int index) {
        int newIndex = index - 1;
        if (newIndex > 0) {
          final int cu = full.codeUnitAt(newIndex);
          // If we landed on a low-surrogate, step back once more.
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

      String restProbe = full.substring(end);

      bool isAllPunctOrSpace(String s) {
        if (s.isEmpty) return false;
        for (final int r in s.runes) {
          if (!isCommonPunctuationOrSpace(r)) return false;
        }
        return true;
      }

      // 【尽量填满】
      // 我们默认使用 TextPainter 给出的首行边界，不做“尾巴过短”回退，
      // 这样首行能尽量填满，避免出现首行末尾留出很大空白却提前折行的情况。
      //
      // 仅当 remainder 几乎全是标点时（常见表现：末行只剩“！”“。”等标点），
      // 才做有限的回退，把少量字符挪到后面，让标点不至于单独成行。
      const int kMaxStepBackRunes = 8;
      int steps = 0;
      while (end > 0 && end < full.length && steps < kMaxStepBackRunes) {
        restProbe = full.substring(end);
        if (!isAllPunctOrSpace(restProbe)) {
          break;
        }
        final int newEnd = stepBackOneRune(end);
        if (newEnd < 0 || newEnd >= end) break;
        end = newEnd;
        steps++;
      }

      // Additional CJK typography tweak: avoid leaving the ordinal prefix
      // "第" at the end of a line when it's preceded by punctuation (e.g. "，第"),
      // so we prefer breaking before "第" and keep "第四..." together.
      if (end > 1 && end < full.length) {
        final int lastCu = full.codeUnitAt(end - 1);
        if (lastCu == 0x7B2C) {
          // '第'
          final int prevCu = full.codeUnitAt(end - 2);
          if (isCommonPunctuationOrSpace(prevCu)) {
            end = stepBackOneRune(end);
          }
        }
      }
    }

    final String first = full.substring(0, end);
    final String rest = full.substring(end);

    final TextPainter painterFirst = _newPainter(_buildSpan(first), maxLines: 1)
      ..layout(maxWidth: firstLineMaxWidth);

    final int? restMaxLines = maxLines == null
        ? null
        : math.max(0, maxLines - 1);
    final TextPainter? painterRest = (rest.isEmpty || restMaxLines == 0)
        ? null
        : (_newPainter(_buildSpan(rest), maxLines: restMaxLines)
            ..layout(maxWidth: maxWidth));

    _painterFull = null;
    _painterFirst = painterFirst;
    _painterRest = painterRest;

    _firstLineHeight = painterFirst.height;
    {
      final List<LineMetrics> fm = painterFirst.computeLineMetrics();
      if (fm.isEmpty) {
        _firstLineBaselineFromTop = 0.0;
        _firstLineBoxHeight = _firstLineHeight;
      } else {
        final LineMetrics firstLine = fm.first;
        _firstLineBaselineFromTop = firstLine.baseline;
        _firstLineBoxHeight = firstLine.height;
      }
    }
    if (painterRest == null) {
      final List<LineMetrics> m = painterFirst.computeLineMetrics();
      if (m.isEmpty) {
        _baselineFromTop = 0.0;
        _inlineAdvanceWidth = math.max(0.0, indent);
      } else {
        final LineMetrics last = m.last;
        _baselineFromTop = last.baseline;
        _inlineAdvanceWidth = last.width + math.max(0.0, indent);
      }
    } else {
      final List<LineMetrics> m = painterRest.computeLineMetrics();
      if (m.isEmpty) {
        // No line metrics is unexpected, but fall back to first line.
        final List<LineMetrics> fm = painterFirst.computeLineMetrics();
        if (fm.isEmpty) {
          _baselineFromTop = 0.0;
          _inlineAdvanceWidth = 0.0;
        } else {
          final LineMetrics last = fm.last;
          _baselineFromTop = last.baseline;
          _inlineAdvanceWidth = last.width + math.max(0.0, indent);
        }
      } else {
        final LineMetrics last = m.last;
        _baselineFromTop = _firstLineHeight + last.baseline;
        _inlineAdvanceWidth = last.width;
      }
    }

    final double restWidth = painterRest?.width ?? 0.0;
    final double restHeight = painterRest?.height ?? 0.0;
    final double w = math.max(
      restWidth,
      painterFirst.width + math.max(0.0, indent),
    );
    final double h = painterFirst.height + restHeight;
    size = constraints.constrain(Size(w, h));
  }

  double _measureIntrinsicHeight(double maxWidth) {
    final String full = _data;
    final double effectiveMaxWidth = maxWidth.isFinite
        ? maxWidth
        : double.infinity;

    if (_firstLineIndentPx == 0.0 || !effectiveMaxWidth.isFinite) {
      final TextPainter painter = _newPainter(_buildSpan(full))
        ..layout(maxWidth: effectiveMaxWidth);
      return painter.height;
    }

    final double indent = _firstLineIndentPx;
    final double firstLineMaxWidth = math.max(0.0, effectiveMaxWidth - indent);

    final int? maxLines = _maxLines;
    if (maxLines != null && maxLines <= 1) {
      final TextPainter painterFirst = _newPainter(
        _buildSpan(full),
        maxLines: 1,
      )..layout(maxWidth: firstLineMaxWidth);
      return painterFirst.height;
    }

    final TextPainter probe = _newPainter(_buildSpan(full))
      ..layout(maxWidth: firstLineMaxWidth);
    final List<LineMetrics> metrics = probe.computeLineMetrics();
    int end;
    if (metrics.length <= 1) {
      end = full.length;
    } else {
      final Offset probeOffset = Offset(
        firstLineMaxWidth,
        probe.preferredLineHeight / 2.0,
      );
      final TextPosition pos = probe.getPositionForOffset(probeOffset);
      final TextRange firstLineRange = probe.getLineBoundary(pos);
      end = firstLineRange.end;
    }
    if (end < 0) end = 0;
    if (end > full.length) end = full.length;

    if (end > 0 && end < full.length && !full.contains(RegExp(r'\s'))) {
      end = _adjustCjkSplitIndexIfNeeded(text: full, end: end);
    }

    final String first = full.substring(0, end);
    final String rest = full.substring(end);

    final TextPainter painterFirst = _newPainter(_buildSpan(first), maxLines: 1)
      ..layout(maxWidth: firstLineMaxWidth);

    final int? restMaxLines = maxLines == null
        ? null
        : math.max(0, maxLines - 1);
    final TextPainter? painterRest = (rest.isEmpty || restMaxLines == 0)
        ? null
        : (_newPainter(_buildSpan(rest), maxLines: restMaxLines)
            ..layout(maxWidth: effectiveMaxWidth));

    return painterFirst.height + (painterRest?.height ?? 0.0);
  }

  @override
  void performLayout() {
    final double maxWidth = constraints.hasBoundedWidth
        ? constraints.maxWidth
        : double.infinity;

    final double nextIndent = _pendingFirstLineIndentPx;
    _pendingFirstLineIndentPx = 0.0;
    _firstLineIndentPx = nextIndent;
    _layoutText(maxWidth);
  }

  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) {
    return _baselineFromTop;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_paintDisabledByParentParagraph) return;
    final Canvas canvas = context.canvas;

    final TextPainter? painterFull = _painterFull;
    if (painterFull != null) {
      painterFull.paint(canvas, offset);
      return;
    }

    final TextPainter? painterFirst = _painterFirst;
    if (painterFirst == null) return;

    painterFirst.paint(canvas, offset + Offset(_firstLineIndentPx, 0));

    final TextPainter? painterRest = _painterRest;
    if (painterRest != null) {
      painterRest.paint(canvas, offset + Offset(0, _firstLineHeight));
    }
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    final TextPainter painter = _newPainter(_buildSpan(_data))
      ..layout(maxWidth: double.infinity);
    final double w = painter.minIntrinsicWidth;
    if (_firstLineIndentPx > 0) {
      return w + _firstLineIndentPx;
    }
    return w;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    // CSS max-content width: format on a single line with infinite available
    // width (i.e. do not use soft wrap opportunities). Flutter's
    // `maxIntrinsicWidth` can behave closer to "longest word" for some
    // texts with wrap opportunities, which makes `fit-content` under-measure
    // and causes unexpected wrapping.
    final TextPainter painter = _newPainter(_buildSpan(_data))
      ..layout(maxWidth: double.infinity);
    final double w = painter.width;
    if (_firstLineIndentPx > 0) {
      return w + _firstLineIndentPx;
    }
    return w;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return _measureIntrinsicHeight(width);
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return _measureIntrinsicHeight(width);
  }
}
