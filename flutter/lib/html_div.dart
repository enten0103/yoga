/// The core HTML-like layout and rendering library for Flutter Yoga.
///
/// This library provides [HtmlDiv], [HtmlImage], and their render objects
/// to create a CSS-like layout engine based on the Yoga flexbox library.
library;

import 'dart:ffi' as ffi;
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'src/image_size_hint.dart' as image_size_hint;
import 'src/yoga_ffi.dart';

import 'src/html_div/models/models.dart';
export 'src/html_div/models/models.dart';

// Private types and helpers
part 'src/html_div/private_types.dart';

// Public widgets
part 'src/html_div/widgets.dart';

// Public render objects
part 'src/html_div/renders/html_image.dart';
part 'src/html_div/renders/html_text.dart';

// Public measurement helpers
part 'src/html_div/text_measure.dart';

// RenderHtmlDiv functional areas
part 'src/html_div/renders/html_div_border_paint.dart';
part 'src/html_div/renders/html_div_transform_hit_test.dart';
part 'src/html_div/renders/html_div_background_paint.dart';
part 'src/html_div/renders/html_div_box_shadow_paint.dart';
part 'src/html_div/renders/html_div_image_streams.dart';
part 'src/html_div/renders/html_div_layout_yoga.dart';
part 'src/html_div/renders/html_div_inline_paragraph.dart';

// Part files contain: private types, widgets, and render objects.
// The rest of RenderHtmlDiv implementation continues below.

class HtmlDivParentData extends ContainerBoxParentData<RenderBox> {}

class _ParagraphRun {
  _ParagraphRun({
    required this.painter,
    required this.offset,
    required this.height,
  });

  final TextPainter painter;
  final Offset offset;
  final double height;
}

class RenderHtmlDiv extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, HtmlDivParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, HtmlDivParentData> {
  HtmlSize _width;
  HtmlSize _height;
  HtmlSize? _minWidth;
  HtmlSize? _maxWidth;
  HtmlSize? _minHeight;
  HtmlSize? _maxHeight;
  HtmlDisplay _display;
  HtmlFlexDirection _flexDirection;
  HtmlJustifyContent _justifyContent;
  HtmlAlignItems _alignItems;
  HtmlFlexWrap _flexWrap;
  double _flexGrow;
  double _flexShrink;
  HtmlLength _flexBasis;
  HtmlAlignSelf _alignSelf;
  HtmlTextAlign _textAlign;
  HtmlLength? _lineHeight;
  HtmlLength _textIndent;

  // Ephemeral, px indent passed from a parent block container to a transparent
  // inline wrapper, so text-indent can apply to nested inline content.
  final double _inheritedFirstLineIndentPx = 0.0;
  HtmlMargin? _margin;
  HtmlPadding? _padding;
  HtmlBorder? _border;
  HtmlBorderRadius? _borderRadius;
  HtmlBackground? _background;
  List<HtmlBoxShadow> _boxShadow;
  HtmlTransform? _transform;
  ImageConfiguration _imageConfiguration = ImageConfiguration.empty;
  final Map<ImageProvider, ImageStream> _borderImageStreams =
      <ImageProvider, ImageStream>{};
  final Map<ImageProvider, ImageInfo?> _borderImageInfos =
      <ImageProvider, ImageInfo?>{};
  final Map<ImageProvider, ImageStreamListener> _borderImageListeners =
      <ImageProvider, ImageStreamListener>{};
  ImageStream? _backgroundImageStream;
  ImageStreamListener? _backgroundImageListener;
  ImageInfo? _backgroundImageInfo;
  ImageProvider? _backgroundImageProvider;
  HtmlBoxSizing _boxSizing;

  Yoga? _yoga;

  static Yoga? _sharedYoga;
  static bool _sharedYogaUnavailable = false;

  EdgeInsets _computedBorderWidths = EdgeInsets.zero;
  EdgeInsets _computedPadding = EdgeInsets.zero;

  double? _lastLineBaselineFromTop;

  // When display != flex, we use a paragraph-style inline formatter powered by
  // TextPainter + placeholder spans (WidgetSpan-like). This provides much more
  // browser-like wrapping and baseline behavior than the legacy line-assembly
  // algorithm.
  bool _usingParagraphInlineLayout = false;
  TextPainter? _paragraphTextPainter;
  final List<RenderBox> _paragraphPlaceholderChildren = <RenderBox>[];
  Offset _paragraphContentOffset = Offset.zero;

  // Paragraph runs for block layout (each corresponds to a contiguous inline-run).
  final List<_ParagraphRun> _paragraphRuns = <_ParagraphRun>[];

  RenderHtmlDiv({
    required HtmlSize width,
    required HtmlSize height,
    HtmlSize? minWidth,
    HtmlSize? maxWidth,
    HtmlSize? minHeight,
    HtmlSize? maxHeight,
    HtmlDisplay display = HtmlDisplay.block,
    HtmlFlexDirection flexDirection = HtmlFlexDirection.row,
    HtmlJustifyContent justifyContent = HtmlJustifyContent.flexStart,
    HtmlAlignItems alignItems = HtmlAlignItems.stretch,
    HtmlFlexWrap flexWrap = HtmlFlexWrap.noWrap,
    double flexGrow = 0.0,
    double flexShrink = 1.0,
    HtmlLength flexBasis = const HtmlLength.auto(),
    HtmlAlignSelf alignSelf = HtmlAlignSelf.auto,
    HtmlTextAlign textAlign = HtmlTextAlign.start,
    HtmlLength? lineHeight,
    HtmlLength textIndent = const HtmlLength.px(0),
    HtmlMargin? margin,
    HtmlPadding? padding,
    HtmlBorder? border,
    HtmlBorderRadius? borderRadius,
    HtmlBackground? background,
    List<HtmlBoxShadow> boxShadow = const <HtmlBoxShadow>[],
    HtmlTransform? transform,
    ImageConfiguration imageConfiguration = ImageConfiguration.empty,
    HtmlBoxSizing boxSizing = HtmlBoxSizing.contentBox,
  }) : _width = width,
       _height = height,
       _minWidth = minWidth,
       _maxWidth = maxWidth,
       _minHeight = minHeight,
       _maxHeight = maxHeight,
       _display = display,
       _flexDirection = flexDirection,
       _justifyContent = justifyContent,
       _alignItems = alignItems,
       _flexWrap = flexWrap,
       _flexGrow = flexGrow,
       _flexShrink = flexShrink,
       _flexBasis = flexBasis,
       _alignSelf = alignSelf,
       _textAlign = textAlign,
       _lineHeight = lineHeight,
       _textIndent = textIndent,
       _margin = margin,
       _padding = padding,
       _border = border,
       _borderRadius = borderRadius,
       _background = background,
       _boxShadow = boxShadow,
       _transform = transform,
       _imageConfiguration = imageConfiguration,
       _boxSizing = boxSizing;

  // NOTE: Inline paragraph layout helpers live in
  // `src/html_div/renders/html_div_inline_paragraph.dart`.

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties.add(DiagnosticsProperty<HtmlSize>('width', _width));
    properties.add(DiagnosticsProperty<HtmlSize>('height', _height));
    properties.add(DiagnosticsProperty<HtmlSize?>('minWidth', _minWidth));
    properties.add(DiagnosticsProperty<HtmlSize?>('maxWidth', _maxWidth));
    properties.add(DiagnosticsProperty<HtmlSize?>('minHeight', _minHeight));
    properties.add(DiagnosticsProperty<HtmlSize?>('maxHeight', _maxHeight));

    properties.add(EnumProperty<HtmlDisplay>('display', _display));
    properties.add(
      EnumProperty<HtmlFlexDirection>('flexDirection', _flexDirection),
    );
    properties.add(
      EnumProperty<HtmlJustifyContent>('justifyContent', _justifyContent),
    );
    properties.add(EnumProperty<HtmlAlignItems>('alignItems', _alignItems));
    properties.add(EnumProperty<HtmlFlexWrap>('flexWrap', _flexWrap));

    properties.add(DoubleProperty('flexGrow', _flexGrow));
    properties.add(DoubleProperty('flexShrink', _flexShrink));
    properties.add(DiagnosticsProperty<HtmlLength>('flexBasis', _flexBasis));
    properties.add(EnumProperty<HtmlAlignSelf>('alignSelf', _alignSelf));

    properties.add(EnumProperty<HtmlTextAlign>('textAlign', _textAlign));
    properties.add(DiagnosticsProperty<HtmlLength?>('lineHeight', _lineHeight));
    properties.add(DiagnosticsProperty<HtmlLength>('textIndent', _textIndent));

    properties.add(DiagnosticsProperty<HtmlMargin?>('margin', _margin));
    properties.add(DiagnosticsProperty<HtmlPadding?>('padding', _padding));
    properties.add(DiagnosticsProperty<HtmlBorder?>('border', _border));
    properties.add(
      DiagnosticsProperty<HtmlBorderRadius?>('borderRadius', _borderRadius),
    );
    properties.add(EnumProperty<HtmlBoxSizing>('boxSizing', _boxSizing));
    properties.add(
      DiagnosticsProperty<HtmlBackground?>('background', _background),
    );
    properties.add(
      DiagnosticsProperty<List<HtmlBoxShadow>>('boxShadow', _boxShadow),
    );
    properties.add(
      DiagnosticsProperty<HtmlTransform?>('transform', _transform),
    );
    properties.add(
      DiagnosticsProperty<ImageConfiguration>(
        'imageConfiguration',
        _imageConfiguration,
      ),
    );

    // Runtime state (not inputs)
    properties.add(IntProperty('childCount', childCount));
    properties.add(
      FlagProperty(
        'hasYoga',
        value: _yoga != null || _sharedYoga != null,
        ifTrue: 'true',
        ifFalse: 'false',
      ),
    );
    properties.add(
      DiagnosticsProperty<EdgeInsets>(
        'computedBorderWidths',
        _computedBorderWidths,
      ),
    );
    properties.add(
      DiagnosticsProperty<EdgeInsets>('computedPadding', _computedPadding),
    );
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _resolveBorderImages();
    _resolveBackgroundImage();
  }

  @override
  void detach() {
    _stopListeningToBorderImages();
    _stopListeningToBackgroundImage();
    super.detach();
  }

  @override
  void dispose() {
    _stopListeningToBorderImages();
    _stopListeningToBackgroundImage();
    super.dispose();
  }

  HtmlSize get width => _width;
  set width(HtmlSize value) {
    if (_width != value) {
      _width = value;
      markNeedsLayout();
    }
  }

  HtmlSize get height => _height;
  set height(HtmlSize value) {
    if (_height != value) {
      _height = value;
      markNeedsLayout();
    }
  }

  HtmlSize? get minWidth => _minWidth;
  set minWidth(HtmlSize? value) {
    if (_minWidth != value) {
      _minWidth = value;
      markNeedsLayout();
    }
  }

  HtmlSize? get maxWidth => _maxWidth;
  set maxWidth(HtmlSize? value) {
    if (_maxWidth != value) {
      _maxWidth = value;
      markNeedsLayout();
    }
  }

  HtmlSize? get minHeight => _minHeight;
  set minHeight(HtmlSize? value) {
    if (_minHeight != value) {
      _minHeight = value;
      markNeedsLayout();
    }
  }

  HtmlSize? get maxHeight => _maxHeight;
  set maxHeight(HtmlSize? value) {
    if (_maxHeight != value) {
      _maxHeight = value;
      markNeedsLayout();
    }
  }

  HtmlDisplay get display => _display;
  set display(HtmlDisplay value) {
    if (_display != value) {
      _display = value;
      markNeedsLayout();
    }
  }

  HtmlFlexDirection get flexDirection => _flexDirection;
  set flexDirection(HtmlFlexDirection value) {
    if (_flexDirection != value) {
      _flexDirection = value;
      markNeedsLayout();
    }
  }

  HtmlJustifyContent get justifyContent => _justifyContent;
  set justifyContent(HtmlJustifyContent value) {
    if (_justifyContent != value) {
      _justifyContent = value;
      markNeedsLayout();
    }
  }

  HtmlAlignItems get alignItems => _alignItems;
  set alignItems(HtmlAlignItems value) {
    if (_alignItems != value) {
      _alignItems = value;
      markNeedsLayout();
    }
  }

  HtmlFlexWrap get flexWrap => _flexWrap;
  set flexWrap(HtmlFlexWrap value) {
    if (_flexWrap != value) {
      _flexWrap = value;
      markNeedsLayout();
    }
  }

  double get flexGrow => _flexGrow;
  set flexGrow(double value) {
    if (_flexGrow != value) {
      _flexGrow = value;
      markNeedsLayout();
    }
  }

  double get flexShrink => _flexShrink;
  set flexShrink(double value) {
    if (_flexShrink != value) {
      _flexShrink = value;
      markNeedsLayout();
    }
  }

  HtmlLength get flexBasis => _flexBasis;
  set flexBasis(HtmlLength value) {
    if (_flexBasis != value) {
      _flexBasis = value;
      markNeedsLayout();
    }
  }

  HtmlAlignSelf get alignSelf => _alignSelf;
  set alignSelf(HtmlAlignSelf value) {
    if (_alignSelf != value) {
      _alignSelf = value;
      markNeedsLayout();
    }
  }

  HtmlTextAlign get textAlign => _textAlign;
  set textAlign(HtmlTextAlign value) {
    if (_textAlign != value) {
      _textAlign = value;
      markNeedsLayout();
    }
  }

  HtmlLength? get lineHeight => _lineHeight;
  set lineHeight(HtmlLength? value) {
    if (_lineHeight != value) {
      _lineHeight = value;
      markNeedsLayout();
    }
  }

  HtmlLength get textIndent => _textIndent;
  set textIndent(HtmlLength value) {
    if (_textIndent != value) {
      _textIndent = value;
      markNeedsLayout();
    }
  }

  HtmlMargin? get margin => _margin;
  set margin(HtmlMargin? value) {
    if (_margin != value) {
      _margin = value;
      markNeedsLayout();
    }
  }

  HtmlPadding? get padding => _padding;
  set padding(HtmlPadding? value) {
    if (_padding != value) {
      _padding = value;
      markNeedsLayout();
    }
  }

  static double _collapseMargins(double a, double b) {
    if (a >= 0 && b >= 0) return math.max(a, b);
    if (a <= 0 && b <= 0) return math.min(a, b);
    return a + b;
  }

  static HtmlMargin? _readChildHtmlMargin(RenderBox child) {
    if (child is RenderHtmlDiv) return child._margin;
    return null;
  }

  static HtmlDisplay _readChildHtmlDisplay(RenderBox child) {
    if (child is RenderHtmlDiv) return child._display;
    // Treat plain text as inline-level content by default (CSS-like).
    if (child is RenderParagraph) return HtmlDisplay.inline;
    if (child is RenderHtmlText) return HtmlDisplay.inline;
    if (child is RenderHtmlImage) return HtmlDisplay.inline;
    return HtmlDisplay.block;
  }

  static const double _kDefaultStrutFontSize = 16.0;
  static const double _kStrutAscentRatio = 0.8;

  static double? _tryExtractFontSizeFromInlineSpan(InlineSpan span) {
    double? found;
    void visit(InlineSpan s) {
      if (found != null) return;
      if (s is TextSpan) {
        final double? fontSize = s.style?.fontSize;
        if (fontSize != null && fontSize.isFinite && fontSize > 0) {
          found = fontSize;
          return;
        }
        final List<InlineSpan>? children = s.children;
        if (children != null) {
          for (final InlineSpan child in children) {
            visit(child);
            if (found != null) return;
          }
        }
      }
    }

    visit(span);
    return found;
  }

  static double? _tryExtractFontSizeFromRenderBox(RenderBox box) {
    if (box is RenderParagraph) {
      final InlineSpan span = box.text;
      return _tryExtractFontSizeFromInlineSpan(span);
    }
    if (box is RenderHtmlDiv) {
      // If this is a transparent wrapper, peek into its inline/text children.
      return _estimateStrutFontSizeFromChildren(box.firstChild);
    }
    return null;
  }

  static double _estimateStrutFontSizeFromChildren(RenderBox? firstChild) {
    RenderBox? child = firstChild;
    while (child != null) {
      final double? size = _tryExtractFontSizeFromRenderBox(child);
      if (size != null && size.isFinite && size > 0) return size;
      child = (child.parentData as HtmlDivParentData).nextSibling;
    }
    return _kDefaultStrutFontSize;
  }

  static (double ascent, double descent) _computeLineHeightStrut(
    RenderBox? firstChild,
    HtmlLength? lineHeight,
  ) {
    // We only apply the CSS-like strut model when line-height is explicitly
    // set; for `auto`/unset we keep the existing behavior to avoid changing
    // layout for non-text content.
    if (lineHeight == null || lineHeight.isAuto) return (0.0, 0.0);

    final double fontSize = _estimateStrutFontSizeFromChildren(firstChild);
    double computedLineHeight;
    switch (lineHeight.unit) {
      case HtmlLengthUnit.px:
        computedLineHeight = lineHeight.value;
        break;
      case HtmlLengthUnit.multiplier:
        computedLineHeight = fontSize * lineHeight.value;
        break;
      case HtmlLengthUnit.percent:
        computedLineHeight = fontSize * lineHeight.value / 100.0;
        break;
      case HtmlLengthUnit.auto:
        computedLineHeight = fontSize * 1.2;
        break;
    }

    if (!computedLineHeight.isFinite || computedLineHeight <= 0) {
      return (0.0, 0.0);
    }

    final double fontAscent = fontSize * _kStrutAscentRatio;
    final double fontDescent = math.max(0.0, fontSize - fontAscent);
    final double leading = computedLineHeight - fontSize;
    final double halfLeading = leading / 2.0;

    // Distribute leading above/below the baseline around the font box.
    final double ascent = math.max(0.0, fontAscent + halfLeading);
    final double descent = math.max(0.0, fontDescent + halfLeading);
    return (ascent, descent);
  }

  static bool _hasInlineContent(RenderHtmlDiv div) {
    RenderBox? child = div.firstChild;
    while (child != null) {
      final HtmlDivParentData pd = child.parentData! as HtmlDivParentData;
      if (_readChildHtmlDisplay(child) == HtmlDisplay.inline) return true;
      child = pd.nextSibling;
    }
    return false;
  }

  static bool _isVisuallyTransparent(RenderHtmlDiv div) {
    final HtmlBackground? bg = div._background;
    final bool hasBackground =
        bg != null && (bg.color != null || bg.image != null);
    return !hasBackground &&
        div._border == null &&
        div._boxShadow.isEmpty &&
        div._transform == null;
  }

  static bool _paintsInInlineLayer(RenderBox child) {
    final HtmlDisplay d = _readChildHtmlDisplay(child);
    if (d == HtmlDisplay.inline) return true;
    // Special case: a transparent block that only exists to host inline/text
    // should paint in the inline layer so its text is not covered by later
    // block backgrounds when negative margins cause overlap.
    if (child is RenderHtmlDiv &&
        child._display == HtmlDisplay.block &&
        _isVisuallyTransparent(child) &&
        _hasInlineContent(child)) {
      return true;
    }
    return false;
  }

  static EdgeInsets _resolveChildMargin(
    RenderBox child,
    double referenceWidth,
  ) {
    final HtmlMargin? m = _readChildHtmlMargin(child);
    if (m == null) return EdgeInsets.zero;
    return m.resolve(referenceWidth: referenceWidth);
  }

  HtmlBorder? get border => _border;
  set border(HtmlBorder? value) {
    if (_border != value) {
      _border = value;
      _resolveBorderImages();
      markNeedsLayout();
      markNeedsPaint();
    }
  }

  HtmlBorderRadius? get borderRadius => _borderRadius;
  set borderRadius(HtmlBorderRadius? value) {
    if (_borderRadius != value) {
      _borderRadius = value;
      markNeedsPaint();
    }
  }

  HtmlBackground? get background => _background;
  set background(HtmlBackground? value) {
    if (_background != value) {
      _background = value;
      _resolveBackgroundImage();
      markNeedsPaint();
    }
  }

  List<HtmlBoxShadow> get boxShadow => _boxShadow;
  set boxShadow(List<HtmlBoxShadow> value) {
    if (!identical(_boxShadow, value)) {
      _boxShadow = value;
      markNeedsPaint();
    }
  }

  HtmlTransform? get transform => _transform;
  set transform(HtmlTransform? value) {
    if (_transform != value) {
      _transform = value;
      markNeedsPaint();
      markNeedsSemanticsUpdate();
    }
  }

  ImageConfiguration get imageConfiguration => _imageConfiguration;
  set imageConfiguration(ImageConfiguration value) {
    if (_imageConfiguration != value) {
      _imageConfiguration = value;
      _resolveBorderImages();
      _resolveBackgroundImage();
      markNeedsPaint();
    }
  }

  HtmlBoxSizing get boxSizing => _boxSizing;
  set boxSizing(HtmlBoxSizing value) {
    if (_boxSizing != value) {
      _boxSizing = value;
      markNeedsLayout();
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! HtmlDivParentData) {
      child.parentData = HtmlDivParentData();
    }
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    // CSS inline-block baseline: if the box has in-flow line boxes, use the
    // baseline of the last line box; otherwise use the bottom margin edge.
    // We approximate bottom margin edge by using the bottom edge of our box.
    final double? last = _lastLineBaselineFromTop;
    if (_display == HtmlDisplay.inline && last != null && last.isFinite) {
      return last;
    }
    return size.height;
  }

  double _getSideWidth(HtmlBorderSide side, double containerWidth) {
    if (side.style == HtmlBorderStyle.hidden) return 0.0;
    final w = side.width;
    if (w is FixedBorderWidth) return w.value;
    if (w is KeywordBorderWidth) {
      switch (w.keyword) {
        case BorderWidthKeyword.thin:
          return 1.0;
        case BorderWidthKeyword.medium:
          return 3.0;
        case BorderWidthKeyword.thick:
          return 5.0;
      }
    }
    if (w is PercentBorderWidth) {
      return containerWidth * w.value / 100.0;
    }
    return 0.0;
  }

  EdgeInsets _calculateBorderWidths(double containerWidth) {
    if (_border == null) return EdgeInsets.zero;
    return EdgeInsets.fromLTRB(
      _getSideWidth(_border!.left, containerWidth),
      _getSideWidth(_border!.top, containerWidth),
      _getSideWidth(_border!.right, containerWidth),
      _getSideWidth(_border!.bottom, containerWidth),
    );
  }

  static double _inlineMinContentWidth(RenderBox? firstChild, double height) {
    double maxBoxWidth = 0;
    RenderBox? child = firstChild;
    while (child != null) {
      final EdgeInsets m = _resolveChildMargin(child, 0);
      final double childWidth = child.getMinIntrinsicWidth(height);
      maxBoxWidth = math.max(maxBoxWidth, childWidth + m.horizontal);
      child = (child.parentData as HtmlDivParentData).nextSibling;
    }
    return maxBoxWidth;
  }

  static double _inlineMaxContentWidth(RenderBox? firstChild, double height) {
    double maxLineWidth = 0;
    double currentLineWidth = 0;

    RenderBox? child = firstChild;
    while (child != null) {
      final EdgeInsets m = _resolveChildMargin(child, 0);
      final HtmlDisplay d = _readChildHtmlDisplay(child);

      if (d == HtmlDisplay.inline) {
        final double childWidth = child.getMaxIntrinsicWidth(height);
        currentLineWidth += childWidth + m.horizontal;
      } else {
        maxLineWidth = math.max(maxLineWidth, currentLineWidth);
        final double childWidth = child.getMaxIntrinsicWidth(height);
        maxLineWidth = math.max(maxLineWidth, childWidth + m.horizontal);
        currentLineWidth = 0;
      }

      child = (child.parentData as HtmlDivParentData).nextSibling;
    }

    maxLineWidth = math.max(maxLineWidth, currentLineWidth);
    return maxLineWidth;
  }

  static double _inlineIntrinsicHeight(
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

    final (double strutAscent, double strutDescent) = _computeLineHeightStrut(
      firstChild,
      lineHeight,
    );

    double flushLine() {
      if (lineAscent + lineDescent <= 0) return 0;
      final double finalAscent = math.max(lineAscent, strutAscent);
      final double finalDescent = math.max(lineDescent, strutDescent);
      return finalAscent + finalDescent;
    }

    RenderBox? child = firstChild;
    while (child != null) {
      final HtmlDisplay d = _readChildHtmlDisplay(child);
      final EdgeInsets m = _resolveChildMargin(child, width);

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
          // Baseline-at-bottom for non-text.
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

          // Recompute with the new line's available width. This mirrors the
          // real layout path, where a child may wrap internally depending on
          // the maxWidth constraint.
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
          // After we've placed content on the first inline line, subsequent lines are not indented.
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

    if (inlineX > 0) currentY += flushLine();
    return currentY;
  }

  double _inlineParagraphIntrinsicHeight(
    double contentWidth,
    double borderBoxWidth,
  ) {
    if (!contentWidth.isFinite || contentWidth <= 0) return 0;

    final TextDirection textDirection = (() {
      RenderBox? c = firstChild;
      while (c != null) {
        if (c is RenderHtmlText) return c.textDirection;
        c = (c.parentData as HtmlDivParentData).nextSibling;
      }
      return TextDirection.ltr;
    })();

    final TextStyle defaultStyle = (() {
      RenderBox? c = firstChild;
      while (c != null) {
        if (c is RenderHtmlText) return c.style ?? const TextStyle();
        c = (c.parentData as HtmlDivParentData).nextSibling;
      }
      return const TextStyle();
    })();

    final double indentPx = _textIndent.isPercent
        ? _textIndent.resolvePx(reference: borderBoxWidth)
        : _textIndent.resolvePx(reference: contentWidth);

    StrutStyle? strutStyle;
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
    bool hasText = false;

    if (indentPx > 0) {
      spanChildren.add(
        const WidgetSpan(
          child: SizedBox.shrink(),
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
        ),
      );
      placeholderDims.add(
        PlaceholderDimensions(
          size: Size(indentPx, 0),
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
          baselineOffset: 0,
        ),
      );
    }

    RenderBox? child = firstChild;
    while (child != null) {
      final HtmlDisplay d = _readChildHtmlDisplay(child);
      if (d != HtmlDisplay.inline) {
        // Mixed flow: preserve existing intrinsic behavior.
        return _inlineIntrinsicHeight(
          firstChild,
          contentWidth,
          _lineHeight,
          _textIndent,
          borderBoxWidth,
        );
      }

      if (child is RenderHtmlText) {
        hasText = true;
        final String paragraphText = _breakAllTextIfNeeded(child.data);
        spanChildren.add(
          TextSpan(
            text: paragraphText,
            style: child.style,
            semanticsLabel: child.semanticsLabel,
          ),
        );
      } else {
        final EdgeInsets m = _resolveChildMargin(child, contentWidth);
        final double childMaxWidth = math.max(0.0, contentWidth - m.horizontal);
        final double w = math.min(
          child.getMaxIntrinsicWidth(double.infinity),
          childMaxWidth,
        );
        final double h = child.getMaxIntrinsicHeight(childMaxWidth);

        spanChildren.add(
          const WidgetSpan(
            child: SizedBox.shrink(),
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
          ),
        );
        placeholderDims.add(
          PlaceholderDimensions(
            size: Size(w + m.horizontal, h + m.vertical),
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            baselineOffset: m.top + h,
          ),
        );
      }

      child = (child.parentData as HtmlDivParentData).nextSibling;
    }

    final TextPainter painter = TextPainter(
      text: TextSpan(children: spanChildren, style: defaultStyle),
      textAlign: textAlign,
      textDirection: textDirection,
      textWidthBasis: TextWidthBasis.parent,
      strutStyle: strutStyle,
    );
    painter.setPlaceholderDimensions(placeholderDims);
    painter.layout(
      maxWidth: contentWidth.isFinite ? contentWidth : double.infinity,
    );

    double height = painter.height;
    if (!hasText && placeholderDims.isNotEmpty) {
      double maxPlaceholderHeight = 0.0;
      for (final PlaceholderDimensions d in placeholderDims) {
        maxPlaceholderHeight = math.max(maxPlaceholderHeight, d.size.height);
      }
      height = math.max(height, maxPlaceholderHeight);
    }
    return height;
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    EdgeInsets borderW = _calculateBorderWidths(0);
    final EdgeInsets paddingW =
        _padding?.resolve(referenceWidth: 0) ?? EdgeInsets.zero;
    final double nonContentHorizontal =
        borderW.horizontal + paddingW.horizontal;
    double contentW = 0;
    if (_width is FixedSize) {
      contentW = (_width as FixedSize).value;
    } else {
      if (_display == HtmlDisplay.inline) {
        contentW = _inlineMinContentWidth(firstChild, height);
      } else {
        RenderBox? child = firstChild;
        while (child != null) {
          // Percentage margins depend on containing block width; ignore in width intrinsics.
          final EdgeInsets m = _resolveChildMargin(child, 0);
          contentW = math.max(
            contentW,
            child.getMinIntrinsicWidth(height) + m.horizontal,
          );
          child = (child.parentData as HtmlDivParentData).nextSibling;
        }
      }
    }

    if (_boxSizing == HtmlBoxSizing.contentBox) {
      return contentW + nonContentHorizontal;
    } else {
      return math.max(contentW, nonContentHorizontal);
    }
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    EdgeInsets borderW = _calculateBorderWidths(0);
    final EdgeInsets paddingW =
        _padding?.resolve(referenceWidth: 0) ?? EdgeInsets.zero;
    final double nonContentHorizontal =
        borderW.horizontal + paddingW.horizontal;
    double contentW = 0;
    if (_width is FixedSize) {
      contentW = (_width as FixedSize).value;
    } else {
      if (_display == HtmlDisplay.inline) {
        contentW = _inlineMaxContentWidth(firstChild, height);
      } else {
        RenderBox? child = firstChild;
        while (child != null) {
          // Percentage margins depend on containing block width; ignore in width intrinsics.
          final EdgeInsets m = _resolveChildMargin(child, 0);
          contentW = math.max(
            contentW,
            child.getMaxIntrinsicWidth(height) + m.horizontal,
          );
          child = (child.parentData as HtmlDivParentData).nextSibling;
        }
      }
    }

    if (_boxSizing == HtmlBoxSizing.contentBox) {
      return contentW + nonContentHorizontal;
    } else {
      return math.max(contentW, nonContentHorizontal);
    }
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    EdgeInsets borderW = _calculateBorderWidths(width.isFinite ? width : 0);
    final EdgeInsets paddingW =
        _padding?.resolve(referenceWidth: width.isFinite ? width : 0) ??
        EdgeInsets.zero;
    final double nonContentVertical = borderW.vertical + paddingW.vertical;
    double contentH = 0;
    if (_height is FixedSize) {
      contentH = (_height as FixedSize).value;
    } else {
      final double referenceWidth = width.isFinite
          ? math.max(0.0, width - borderW.horizontal - paddingW.horizontal)
          : 0.0;

      if (_display == HtmlDisplay.inline) {
        contentH = _inlineParagraphIntrinsicHeight(
          referenceWidth,
          width.isFinite ? width : 0.0,
        );
      } else {
        double prevBottom = 0;
        RenderBox? child = firstChild;
        while (child != null) {
          final EdgeInsets m = _resolveChildMargin(child, referenceWidth);
          contentH += _collapseMargins(prevBottom, m.top);
          contentH += child.getMinIntrinsicHeight(width);
          prevBottom = m.bottom;
          child = (child.parentData as HtmlDivParentData).nextSibling;
        }
        contentH += prevBottom;
      }
    }

    if (_boxSizing == HtmlBoxSizing.contentBox) {
      return contentH + nonContentVertical;
    } else {
      return math.max(contentH, nonContentVertical);
    }
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    EdgeInsets borderW = _calculateBorderWidths(width.isFinite ? width : 0);
    final EdgeInsets paddingW =
        _padding?.resolve(referenceWidth: width.isFinite ? width : 0) ??
        EdgeInsets.zero;
    final double nonContentVertical = borderW.vertical + paddingW.vertical;
    double contentH = 0;
    if (_height is FixedSize) {
      contentH = (_height as FixedSize).value;
    } else {
      final double referenceWidth = width.isFinite
          ? math.max(0.0, width - borderW.horizontal - paddingW.horizontal)
          : 0.0;

      if (_display == HtmlDisplay.inline) {
        contentH = _inlineParagraphIntrinsicHeight(
          referenceWidth,
          width.isFinite ? width : 0.0,
        );
      } else {
        double prevBottom = 0;
        RenderBox? child = firstChild;
        while (child != null) {
          final EdgeInsets m = _resolveChildMargin(child, referenceWidth);
          contentH += _collapseMargins(prevBottom, m.top);
          contentH += child.getMaxIntrinsicHeight(width);
          prevBottom = m.bottom;
          child = (child.parentData as HtmlDivParentData).nextSibling;
        }
        contentH += prevBottom;
      }
    }

    if (_boxSizing == HtmlBoxSizing.contentBox) {
      return contentH + nonContentVertical;
    } else {
      return math.max(contentH, nonContentVertical);
    }
  }

  @override
  void performLayout() {
    final double containerBorderBoxWidth = constraints.hasBoundedWidth
        ? constraints.maxWidth
        : 0.0;
    _computedBorderWidths = _calculateBorderWidths(containerBorderBoxWidth);
    _computedPadding =
        _padding?.resolve(referenceWidth: containerBorderBoxWidth) ??
        EdgeInsets.zero;
    final double borderHorizontal = _computedBorderWidths.horizontal;
    final double borderVertical = _computedBorderWidths.vertical;
    final double paddingHorizontal = _computedPadding.horizontal;
    final double paddingVertical = _computedPadding.vertical;

    double availableBorderBoxWidth = constraints.hasBoundedWidth
        ? constraints.maxWidth
        : double.infinity;
    double availableBorderBoxHeight = constraints.hasBoundedHeight
        ? constraints.maxHeight
        : double.infinity;

    double availableSizingWidth;
    if (_boxSizing == HtmlBoxSizing.borderBox) {
      availableSizingWidth = availableBorderBoxWidth;
    } else {
      availableSizingWidth = availableBorderBoxWidth.isFinite
          ? math.max(
              0.0,
              availableBorderBoxWidth - borderHorizontal - paddingHorizontal,
            )
          : double.infinity;
    }

    double? resolveSizingLimit(HtmlSize? v, {required bool isWidthAxis}) {
      if (v == null) return null;

      final double availableBorderBox = isWidthAxis
          ? availableBorderBoxWidth
          : availableBorderBoxHeight;

      if (v is FixedSize) return v.value;
      if (v is PercentSize) {
        if (availableBorderBox.isFinite) {
          return availableBorderBox * v.value / 100.0;
        }
        return null;
      }

      double intrinsicBorderBox;
      if (isWidthAxis) {
        if (v is MinContent) {
          intrinsicBorderBox = computeMinIntrinsicWidth(double.infinity);
        } else if (v is MaxContent) {
          intrinsicBorderBox = computeMaxIntrinsicWidth(double.infinity);
        } else if (v is FitContent) {
          final double minI = computeMinIntrinsicWidth(double.infinity);
          final double maxI = computeMaxIntrinsicWidth(double.infinity);
          intrinsicBorderBox = math.min(
            maxI,
            math.max(minI, availableBorderBoxWidth),
          );
        } else {
          return null;
        }
      } else {
        if (v is MinContent) {
          intrinsicBorderBox = computeMinIntrinsicHeight(double.infinity);
        } else if (v is MaxContent) {
          intrinsicBorderBox = computeMaxIntrinsicHeight(double.infinity);
        } else if (v is FitContent) {
          final double minI = computeMinIntrinsicHeight(double.infinity);
          final double maxI = computeMaxIntrinsicHeight(double.infinity);
          intrinsicBorderBox = math.min(
            maxI,
            math.max(minI, availableBorderBoxHeight),
          );
        } else {
          return null;
        }
      }

      if (_boxSizing == HtmlBoxSizing.borderBox) {
        return intrinsicBorderBox;
      }
      final double border = isWidthAxis ? borderHorizontal : borderVertical;
      return math.max(0.0, intrinsicBorderBox - border);
    }

    double? minW = resolveSizingLimit(_minWidth, isWidthAxis: true);
    double? maxW = resolveSizingLimit(_maxWidth, isWidthAxis: true);
    if (minW != null && maxW != null && maxW < minW) {
      maxW = minW;
    }

    double sizingWidth;
    if (_width is FixedSize) {
      sizingWidth = (_width as FixedSize).value;
    } else if (_width is PercentSize && constraints.hasBoundedWidth) {
      sizingWidth =
          constraints.maxWidth * (_width as PercentSize).value / 100.0;
      if (_boxSizing == HtmlBoxSizing.contentBox) {
        // percent width is resolved against containing block width; keep as content-box width.
      }
    } else if (_width is AutoSize &&
        constraints.hasBoundedWidth &&
        (_display == HtmlDisplay.block || _display == HtmlDisplay.flex)) {
      sizingWidth = availableSizingWidth;
    } else {
      // Intrinsic / shrink-to-fit cases.
      final double intrinsicBorderBox;
      if (_width is MinContent) {
        intrinsicBorderBox = computeMinIntrinsicWidth(double.infinity);
      } else if (_width is MaxContent) {
        intrinsicBorderBox = computeMaxIntrinsicWidth(double.infinity);
      } else if (_width is AutoSize && _display == HtmlDisplay.inline) {
        final double minI = computeMinIntrinsicWidth(double.infinity);
        final double maxI = computeMaxIntrinsicWidth(double.infinity);
        final double available = availableBorderBoxWidth;
        // Inline auto is shrink-to-fit. When line-height/strut is in play,
        // text measurement can differ fractionally between intrinsic sizing
        // and final paragraph layout, which may wrap the last glyph to a new
        // line unexpectedly. Snap up to whole pixels to keep single-line
        // content stable.
        intrinsicBorderBox = math
            .min(maxI, math.max(minI, available))
            .ceilToDouble();
      } else if (_width is FitContent) {
        final double minI = computeMinIntrinsicWidth(double.infinity);
        final double maxI = computeMaxIntrinsicWidth(double.infinity);
        final double available = availableBorderBoxWidth;
        intrinsicBorderBox = math.min(maxI, math.max(minI, available));
      } else if (_width is AutoSize) {
        intrinsicBorderBox = computeMaxIntrinsicWidth(double.infinity);
      } else {
        intrinsicBorderBox = 0.0;
      }

      sizingWidth = _boxSizing == HtmlBoxSizing.borderBox
          ? intrinsicBorderBox
          : math.max(0.0, intrinsicBorderBox - borderHorizontal);
    }

    if (minW != null) sizingWidth = math.max(sizingWidth, minW);
    if (maxW != null) sizingWidth = math.min(sizingWidth, maxW);

    double borderBoxWidth = _boxSizing == HtmlBoxSizing.borderBox
        ? sizingWidth
        : sizingWidth + borderHorizontal + paddingHorizontal;
    borderBoxWidth = constraints.constrainWidth(borderBoxWidth);

    final double contentWidth = math.max(
      0.0,
      borderBoxWidth - borderHorizontal - paddingHorizontal,
    );

    final double? childContentMaxHeight = (() {
      double? borderBoxHeight;

      if (_height is FixedSize) {
        final double h = (_height as FixedSize).value;
        borderBoxHeight = _boxSizing == HtmlBoxSizing.borderBox
            ? h
            : (h + borderVertical + paddingVertical);
      } else if (_height is PercentSize && constraints.hasBoundedHeight) {
        final double h =
            constraints.maxHeight * (_height as PercentSize).value / 100.0;
        borderBoxHeight = _boxSizing == HtmlBoxSizing.borderBox
            ? h
            : (h + borderVertical + paddingVertical);
      } else if (constraints.hasBoundedHeight) {
        borderBoxHeight = constraints.maxHeight;
      } else {
        return null;
      }

      final double constrainedBorderBoxHeight = constraints.constrainHeight(
        borderBoxHeight,
      );
      final double contentH = math.max(
        0.0,
        constrainedBorderBoxHeight - borderVertical - paddingVertical,
      );
      if (!contentH.isFinite) return null;
      return contentH;
    })();

    double yOffset = _computedBorderWidths.top + _computedPadding.top;
    double xOffset = _computedBorderWidths.left + _computedPadding.left;
    double currentY = yOffset;
    double prevBottom = 0;

    _lastLineBaselineFromTop = null;

    // Inline-only switch: for display:inline, optionally use a TextPainter-based
    // paragraph formatter with placeholder spans.
    //
    // IMPORTANT: This intentionally does NOT replace the block formatting
    // implementation (margin collapsing/stacking/inline runs inside blocks).
    //
    if (_display == HtmlDisplay.inline) {
      _usingParagraphInlineLayout = true;
      _paragraphPlaceholderChildren.clear();

      final TextDirection textDirection = (() {
        // Prefer the first HtmlText child's direction if available.
        RenderBox? c = firstChild;
        while (c != null) {
          if (c is RenderHtmlText) return c.textDirection;
          c = (c.parentData as HtmlDivParentData).nextSibling;
        }
        return TextDirection.ltr;
      })();

      // Compute indent: prefer own textIndent; otherwise allow inherited indent
      // to flow through transparent wrappers.
      final double ownIndentPx = _textIndent.isPercent
          ? _textIndent.resolvePx(reference: availableBorderBoxWidth)
          : _textIndent.resolvePx(reference: contentWidth);
      final double indentPx = ownIndentPx != 0.0
          ? ownIndentPx
          : _inheritedFirstLineIndentPx;

      final List<InlineSpan> spanChildren = <InlineSpan>[];
      final List<PlaceholderDimensions> placeholderDims =
          <PlaceholderDimensions>[];
      final List<EdgeInsets> placeholderMargins = <EdgeInsets>[];

      // Track text ranges for each RenderHtmlText so we can map back to
      // per-child offsets and baseline overrides.
      final List<(RenderHtmlText child, int start, int end)> textSegments =
          <(RenderHtmlText, int, int)>[];
      int paragraphOffset = 0;

      // text-indent: model it as a leading placeholder box, which naturally
      // affects only the first formatted line.
      if (indentPx > 0) {
        spanChildren.add(
          const WidgetSpan(
            child: SizedBox.shrink(),
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
          ),
        );
        placeholderDims.add(
          PlaceholderDimensions(
            size: Size(indentPx, 0),
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            baselineOffset: 0,
          ),
        );
        // Placeholders occupy one character in the paragraph's plain text.
        paragraphOffset += 1;
      }

      // Infer a paragraph base style from the first HtmlText child. This keeps
      // behavior consistent with the existing engine where HtmlText already
      // carries an effective (merged) TextStyle.
      final TextStyle defaultStyle = (() {
        RenderBox? c = firstChild;
        while (c != null) {
          if (c is RenderHtmlText) return c.style ?? const TextStyle();
          c = (c.parentData as HtmlDivParentData).nextSibling;
        }
        return const TextStyle();
      })();

      StrutStyle? strutStyle;
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

      // Build spans and layout placeholder children.
      bool subtreeHasNonEmptyText(RenderBox root) {
        if (root is RenderHtmlText) return root.data.isNotEmpty;
        if (root is RenderHtmlDiv) {
          RenderBox? c = root.firstChild;
          while (c != null) {
            if (subtreeHasNonEmptyText(c)) return true;
            c = (c.parentData as HtmlDivParentData).nextSibling;
          }
        }
        return false;
      }

      RenderBox? child = firstChild;
      while (child != null) {
        final HtmlDivParentData pd = child.parentData as HtmlDivParentData;

        if (child is RenderHtmlText) {
          // Keep the child laid out for debug/measurement parity, but it will
          // not be painted/positioned by itself in paragraph mode.
          child.layout(
            childContentMaxHeight == null
                ? BoxConstraints(maxWidth: contentWidth)
                : BoxConstraints(
                    maxWidth: contentWidth,
                    maxHeight: childContentMaxHeight,
                  ),
            parentUsesSize: true,
          );
          // We'll position this child based on its glyph boxes after the
          // unified paragraph is laid out.

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
        } else {
          // Any non-text RenderBox participates as a placeholder (WidgetSpan).
          final EdgeInsets m = _resolveChildMargin(child, contentWidth);
          final double childMaxWidth = math.max(
            0.0,
            contentWidth - m.horizontal,
          );
          // IMPORTANT:
          // Placeholder children are treated as atomic inline boxes (WidgetSpan).
          // If we constrain them to the remaining line width, they may wrap
          // internally (creating multi-line content inside a single placeholder),
          // which is surprising in mixed inline experiments.
          //
          // For inline RenderHtmlDiv placeholders with auto sizing, prefer a
          // max-content measurement by using an unbounded maxWidth.
          final bool preferUnboundedWidth =
              child is RenderHtmlDiv &&
              child._display == HtmlDisplay.inline &&
              // Only opt into max-content measurement for inline wrappers that
              // explicitly set a line-height. This avoids breaking the
              // transparent wrapper used for delegated text-indent, which must
              // be forced to the full line width.
              child._lineHeight != null &&
              child._width is AutoSize &&
              child._minWidth == null &&
              child._maxWidth == null;

          final BoxConstraints placeholderConstraints =
              childContentMaxHeight == null
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

          child.layout(placeholderConstraints, parentUsesSize: true);

          // CSS-like baseline behavior:
          // - If an inline span wrapper has in-flow text, align by its
          //   alphabetic baseline (last line box).
          // - Otherwise (e.g. replaced elements), align by its bottom edge.
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

          _paragraphPlaceholderChildren.add(child);
          placeholderMargins.add(m);
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
          // Placeholders occupy one character in the paragraph's plain text.
          paragraphOffset += 1;
        }

        child = pd.nextSibling;
      }

      final TextAlign textAlign = switch (_textAlign) {
        HtmlTextAlign.start => TextAlign.start,
        HtmlTextAlign.center => TextAlign.center,
        HtmlTextAlign.end => TextAlign.end,
        HtmlTextAlign.justify => TextAlign.justify,
      };

      final TextPainter painter = TextPainter(
        text: TextSpan(children: spanChildren, style: defaultStyle),
        textAlign: textAlign,
        textDirection: textDirection,
        textWidthBasis: TextWidthBasis.parent,
        strutStyle: strutStyle,
      );
      painter.setPlaceholderDimensions(placeholderDims);
      final double maxWidth = contentWidth.isFinite
          ? contentWidth
          : double.infinity;
      final double minWidth = contentWidth.isFinite ? contentWidth : 0.0;
      painter.layout(minWidth: minWidth, maxWidth: maxWidth);
      _paragraphTextPainter = painter;
      // Some engines (especially with forced strut height) can place baseline-
      // aligned placeholders (replaced elements) above y=0 in paragraph
      // coordinates when line-height is smaller than the placeholder's height.
      //
      // If we don't account for negative tops, inline wrappers with a small
      // line-height can paint children above their own box.
      double minTop = 0.0;
      double maxBottom = painter.height;

      // Position placeholder children.
      final List<TextBox>? boxes = painter.inlinePlaceholderBoxes;
      if (boxes != null) {
        for (final TextBox b in boxes) {
          minTop = math.min(minTop, b.top);
          maxBottom = math.max(maxBottom, b.bottom);
        }
      }

      // Include text selection boxes in vertical extents too.
      for (final (RenderHtmlText _, int start, int end) in textSegments) {
        if (start == end) continue;
        final List<TextBox> tBoxes = painter.getBoxesForSelection(
          TextSelection(baseOffset: start, extentOffset: end),
        );
        for (final TextBox b in tBoxes) {
          minTop = math.min(minTop, b.top);
          maxBottom = math.max(maxBottom, b.bottom);
        }
      }

      final double shiftY = minTop < 0 ? -minTop : 0.0;
      _paragraphContentOffset = Offset(xOffset, yOffset + shiftY);

      if (boxes != null) {
        int boxIndex = 0;
        if (indentPx > 0) {
          // Skip indent placeholder.
          boxIndex++;
        }
        for (int i = 0; i < _paragraphPlaceholderChildren.length; i++) {
          final RenderBox ph = _paragraphPlaceholderChildren[i];
          final EdgeInsets m = placeholderMargins[i];
          final HtmlDivParentData pd = ph.parentData as HtmlDivParentData;
          final TextBox b = boxes[boxIndex++];
          pd.offset = Offset(
            xOffset + b.left + m.left,
            yOffset + shiftY + b.top + m.top,
          );
        }
      }

      // Position text children and provide baseline overrides derived from the
      // unified paragraph layout.
      final List<LineMetrics> metrics = painter.computeLineMetrics();
      int findLineIndexForBox(TextBox b) {
        final double y = (b.top + b.bottom) / 2.0;
        for (int i = 0; i < metrics.length; i++) {
          final LineMetrics m = metrics[i];
          final double top = m.baseline - m.ascent;
          final double bottom = m.baseline + m.descent;
          if (y >= top - 0.01 && y <= bottom + 0.01) return i;
        }
        // Fallback: closest baseline.
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

      for (final (RenderHtmlText t, int start, int end) in textSegments) {
        final HtmlDivParentData pd = t.parentData as HtmlDivParentData;
        // Clear any stale overrides first.
        t.clearParagraphBaselineOverrides();
        t.setParagraphDebugLineCount(null);

        if (start == end) {
          pd.offset = Offset(xOffset, yOffset + shiftY);
          continue;
        }

        final List<TextBox> tBoxes = painter.getBoxesForSelection(
          TextSelection(baseOffset: start, extentOffset: end),
        );
        if (tBoxes.isEmpty || metrics.isEmpty) {
          // Best-effort: place at caret.
          final Offset caret = painter.getOffsetForCaret(
            TextPosition(offset: start),
            Rect.zero,
          );
          pd.offset = Offset(xOffset + caret.dx, yOffset + shiftY + caret.dy);
          continue;
        }

        Rect r = tBoxes.first.toRect();
        for (int i = 1; i < tBoxes.length; i++) {
          r = r.expandToInclude(tBoxes[i].toRect());
        }

        final TextBox firstBox = tBoxes.first;
        final TextBox lastBox = tBoxes.last;
        final int firstLine = findLineIndexForBox(firstBox);
        final int lastLine = findLineIndexForBox(lastBox);
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
        final double firstBaselineFromTop = metrics[firstLine].baseline - r.top;
        final double lastBaselineFromTop = metrics[lastLine].baseline - r.top;
        t.setParagraphBaselineOverrides(
          firstLineBaselineFromTop: firstBaselineFromTop,
          lastLineBaselineFromTop: lastBaselineFromTop,
        );

        pd.offset = Offset(xOffset + r.left, yOffset + shiftY + r.top);
      }

      // Record last-line baseline for baseline queries.
      if (metrics.isNotEmpty) {
        _lastLineBaselineFromTop = yOffset + shiftY + metrics.last.baseline;
      }

      final double contentHeight = math.max(0.0, maxBottom - minTop);

      double? minH = resolveSizingLimit(_minHeight, isWidthAxis: false);
      double? maxH = resolveSizingLimit(_maxHeight, isWidthAxis: false);
      if (minH != null && maxH != null && maxH < minH) {
        maxH = minH;
      }

      double sizingHeight;
      if (_height is FixedSize) {
        sizingHeight = (_height as FixedSize).value;
      } else if (_height is PercentSize && constraints.hasBoundedHeight) {
        sizingHeight =
            constraints.maxHeight * (_height as PercentSize).value / 100.0;
      } else {
        sizingHeight = _boxSizing == HtmlBoxSizing.borderBox
            ? (contentHeight + borderVertical + paddingVertical)
            : contentHeight;
      }

      if (minH != null) sizingHeight = math.max(sizingHeight, minH);
      if (maxH != null) sizingHeight = math.min(sizingHeight, maxH);

      double borderBoxHeight;
      if (_boxSizing == HtmlBoxSizing.borderBox) {
        borderBoxHeight = sizingHeight;
      } else {
        borderBoxHeight = sizingHeight + borderVertical + paddingVertical;
      }
      borderBoxHeight = constraints.constrainHeight(borderBoxHeight);

      size = Size(borderBoxWidth, borderBoxHeight);
      return;
    }

    _usingParagraphInlineLayout = false;

    if (_display == HtmlDisplay.flex) {
      final double? contentHeight = _performFlexLayoutIfPossible(
        contentWidth: contentWidth,
        xOffset: xOffset,
        yOffset: yOffset,
        availableBorderBoxHeight: availableBorderBoxHeight,
        borderVertical: borderVertical,
        paddingVertical: paddingVertical,
      );

      if (contentHeight != null) {
        double? minH = resolveSizingLimit(_minHeight, isWidthAxis: false);
        double? maxH = resolveSizingLimit(_maxHeight, isWidthAxis: false);
        if (minH != null && maxH != null && maxH < minH) {
          maxH = minH;
        }

        double sizingHeight;
        if (_height is FixedSize) {
          sizingHeight = (_height as FixedSize).value;
        } else if (_height is PercentSize && constraints.hasBoundedHeight) {
          sizingHeight =
              constraints.maxHeight * (_height as PercentSize).value / 100.0;
        } else {
          // auto height depends on boxSizing.
          sizingHeight = _boxSizing == HtmlBoxSizing.borderBox
              ? (contentHeight + borderVertical + paddingVertical)
              : contentHeight;
        }

        if (minH != null) sizingHeight = math.max(sizingHeight, minH);
        if (maxH != null) sizingHeight = math.min(sizingHeight, maxH);

        double borderBoxHeight;
        if (_boxSizing == HtmlBoxSizing.borderBox) {
          borderBoxHeight = sizingHeight;
        } else {
          borderBoxHeight = sizingHeight + borderVertical + paddingVertical;
        }
        borderBoxHeight = constraints.constrainHeight(borderBoxHeight);

        size = Size(borderBoxWidth, borderBoxHeight);
        return;
      }
    }

    _paragraphRuns.clear();

    final double ownIndentPx = _textIndent.isPercent
        ? (availableBorderBoxWidth.isFinite
              ? _textIndent.resolvePx(reference: availableBorderBoxWidth)
              : 0.0)
        : _textIndent.resolvePx(reference: contentWidth);
    final double indentPx = ownIndentPx != 0.0
        ? ownIndentPx
        : _inheritedFirstLineIndentPx;
    bool indentApplied = false;

    RenderBox? child = firstChild;
    while (child != null) {
      final HtmlDivParentData childParentData =
          child.parentData as HtmlDivParentData;

      final HtmlDisplay childDisplay = _readChildHtmlDisplay(child);
      final bool isInline = childDisplay == HtmlDisplay.inline;

      if (isInline) {
        // Inline content does not participate in margin collapsing.
        currentY += prevBottom;
        prevBottom = 0;

        // Collect a contiguous inline run.
        final List<RenderBox> runChildren = <RenderBox>[];
        RenderBox? c = child;
        while (c != null && _readChildHtmlDisplay(c) == HtmlDisplay.inline) {
          runChildren.add(c);
          c = (c.parentData as HtmlDivParentData).nextSibling;
        }

        // First-line-only indent for the first inline formatted line.
        final double firstLineIndentPx = indentApplied ? 0.0 : indentPx;
        final _ParagraphRun run = _layoutParagraphRun(
          runChildren: runChildren,
          contentWidth: contentWidth,
          xOffset: xOffset,
          yTop: currentY,
          childContentMaxHeight: childContentMaxHeight,
          firstLineIndentPx: firstLineIndentPx,
        );
        _paragraphRuns.add(run);

        final List<LineMetrics> runMetrics = run.painter.computeLineMetrics();
        if (runMetrics.isNotEmpty) {
          _lastLineBaselineFromTop = currentY + runMetrics.last.baseline;
        }

        currentY += run.height;
        indentApplied = true;
        child = c;
        continue;
      }

      final HtmlMargin? childMarginObj = _readChildHtmlMargin(child);
      final EdgeInsets m = _resolveChildMargin(child, contentWidth);
      final double collapsed = _collapseMargins(prevBottom, m.top);
      currentY += collapsed;

      final double childMaxWidth = math.max(0.0, contentWidth - m.horizontal);
      final BoxConstraints childConstraints = childContentMaxHeight == null
          ? BoxConstraints(maxWidth: childMaxWidth)
          : BoxConstraints(
              maxWidth: childMaxWidth,
              maxHeight: childContentMaxHeight,
            );
      child.layout(childConstraints, parentUsesSize: true);

      double autoLeft = 0;
      if (childMarginObj != null &&
          (childMarginObj.left.isAuto || childMarginObj.right.isAuto)) {
        final double fixedHorizontal =
            (childMarginObj.left.isAuto ? 0.0 : m.left) +
            (childMarginObj.right.isAuto ? 0.0 : m.right);
        final double remaining = math.max(
          0.0,
          contentWidth - fixedHorizontal - child.size.width,
        );
        if (childMarginObj.left.isAuto && childMarginObj.right.isAuto) {
          autoLeft = remaining / 2.0;
        } else if (childMarginObj.left.isAuto) {
          autoLeft = remaining;
        }
      }

      childParentData.offset = Offset(xOffset + m.left + autoLeft, currentY);
      currentY += child.size.height;
      prevBottom = m.bottom;

      child = childParentData.nextSibling;
    }

    final double contentHeight = (currentY - yOffset) + prevBottom;

    double? minH = resolveSizingLimit(_minHeight, isWidthAxis: false);
    double? maxH = resolveSizingLimit(_maxHeight, isWidthAxis: false);
    if (minH != null && maxH != null && maxH < minH) {
      maxH = minH;
    }

    double sizingHeight;
    if (_height is FixedSize) {
      sizingHeight = (_height as FixedSize).value;
    } else if (_height is PercentSize && constraints.hasBoundedHeight) {
      sizingHeight =
          constraints.maxHeight * (_height as PercentSize).value / 100.0;
    } else {
      // auto height depends on boxSizing.
      sizingHeight = _boxSizing == HtmlBoxSizing.borderBox
          ? (contentHeight + borderVertical + paddingVertical)
          : contentHeight;
    }

    if (minH != null) sizingHeight = math.max(sizingHeight, minH);
    if (maxH != null) sizingHeight = math.min(sizingHeight, maxH);

    double borderBoxHeight;
    if (_boxSizing == HtmlBoxSizing.borderBox) {
      borderBoxHeight = sizingHeight;
    } else {
      borderBoxHeight = sizingHeight + borderVertical + paddingVertical;
    }
    borderBoxHeight = constraints.constrainHeight(borderBoxHeight);

    size = Size(borderBoxWidth, borderBoxHeight);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Matrix4? t = _effectiveTransform();
    if (t == null) {
      _paintWithoutTransform(context, offset);
      return;
    }

    context.pushTransform(needsCompositing, offset, t, _paintWithoutTransform);
  }

  void _paintWithoutTransform(PaintingContext context, Offset offset) {
    _paintBoxShadowIfNeeded(context, offset, inset: false);
    _paintBackgroundIfNeeded(context, offset);
    _paintBoxShadowIfNeeded(context, offset, inset: true);
    final bool paintedBorderImage = _paintBorderImageIfNeeded(context, offset);
    if (!paintedBorderImage && _border != null) {
      if (_border!.isUniform) {
        _paintUniformBorder(context, offset);
      } else {
        _paintMixedBorder(context, offset);
      }
    }
    if (_usingParagraphInlineLayout) {
      final TextPainter? p = _paragraphTextPainter;
      if (p != null) {
        p.paint(context.canvas, offset + _paragraphContentOffset);
      }
      for (final RenderBox child in _paragraphPlaceholderChildren) {
        final HtmlDivParentData pd = child.parentData! as HtmlDivParentData;
        context.paintChild(child, offset + pd.offset);
      }
      return;
    }

    // Legacy paint order policy:
    // - Paint all block-level children first.
    // - Then paint all inline-level children (on top), to match typical HTML expectations
    //   when inline content overlaps block backgrounds due to negative margins.
    if (_display == HtmlDisplay.flex) {
      defaultPaint(context, offset);
    } else {
      _paintChildrenSeparated(context, offset);
    }
  }

  void _paintChildrenSeparated(PaintingContext context, Offset offset) {
    RenderBox? child = firstChild;
    while (child != null) {
      final HtmlDivParentData childParentData =
          child.parentData! as HtmlDivParentData;
      final bool inlineLayer = _paintsInInlineLayer(child);
      if (!inlineLayer) {
        context.paintChild(child, childParentData.offset + offset);
      }
      child = childParentData.nextSibling;
    }

    // Paint unified paragraph text for inline runs after block backgrounds.
    final Canvas canvas = context.canvas;
    for (final _ParagraphRun run in _paragraphRuns) {
      run.painter.paint(canvas, offset + run.offset);
    }

    child = firstChild;
    while (child != null) {
      final HtmlDivParentData childParentData =
          child.parentData! as HtmlDivParentData;
      final bool inlineLayer = _paintsInInlineLayer(child);
      if (inlineLayer) {
        context.paintChild(child, childParentData.offset + offset);
      }
      child = childParentData.nextSibling;
    }
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    final Matrix4? t = _effectiveTransform();
    if (t == null) {
      return super.hitTest(result, position: position);
    }
    return result.addWithPaintTransform(
      transform: t,
      position: position,
      hitTest: (BoxHitTestResult result, Offset transformed) {
        return super.hitTest(result, position: transformed);
      },
    );
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    super.applyPaintTransform(child, transform);
    final Matrix4? t = _effectiveTransform();
    if (t != null) {
      transform.multiply(t);
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    if (_usingParagraphInlineLayout) {
      for (int i = _paragraphPlaceholderChildren.length - 1; i >= 0; i--) {
        final RenderBox child = _paragraphPlaceholderChildren[i];
        final HtmlDivParentData pd = child.parentData! as HtmlDivParentData;
        final bool isHit = result.addWithPaintOffset(
          offset: pd.offset,
          position: position,
          hitTest: (BoxHitTestResult result, Offset transformed) {
            return child.hitTest(result, position: transformed);
          },
        );
        if (isHit) return true;
      }
      return false;
    }
    if (_display == HtmlDisplay.flex) {
      return defaultHitTestChildren(result, position: position);
    }
    final List<RenderBox> blockChildren = <RenderBox>[];
    final List<RenderBox> inlineChildren = <RenderBox>[];

    RenderBox? child = firstChild;
    while (child != null) {
      final HtmlDivParentData childParentData =
          child.parentData! as HtmlDivParentData;
      final bool inlineLayer = _paintsInInlineLayer(child);
      (inlineLayer ? inlineChildren : blockChildren).add(child);
      child = childParentData.nextSibling;
    }

    bool hitTestChild(RenderBox child) {
      final HtmlDivParentData childParentData =
          child.parentData! as HtmlDivParentData;
      return result.addWithPaintOffset(
        offset: childParentData.offset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          return child.hitTest(result, position: transformed);
        },
      );
    }

    // Inline children paint last => hit test first.
    for (int i = inlineChildren.length - 1; i >= 0; i--) {
      if (hitTestChild(inlineChildren[i])) return true;
    }

    for (int i = blockChildren.length - 1; i >= 0; i--) {
      if (hitTestChild(blockChildren[i])) return true;
    }

    return false;
  }
}
