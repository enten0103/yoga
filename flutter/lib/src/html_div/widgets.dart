part of '../../html_div.dart';

class HtmlDiv extends MultiChildRenderObjectWidget {
  final HtmlSize width;
  final HtmlSize height;
  final HtmlSize? minWidth;
  final HtmlSize? maxWidth;
  final HtmlSize? minHeight;
  final HtmlSize? maxHeight;
  final HtmlDisplay display;
  // Flex container styles (used when display == flex)
  final HtmlFlexDirection flexDirection;
  final HtmlJustifyContent justifyContent;
  final HtmlAlignItems alignItems;
  final HtmlFlexWrap flexWrap;

  // Flex item styles (used when parent is flex)
  final double flexGrow;
  final double flexShrink;
  final HtmlLength flexBasis;
  final HtmlAlignSelf alignSelf;
  final HtmlTextAlign textAlign;
  final HtmlOverflowWrap overflowWrap;
  final HtmlLength? lineHeight;
  final HtmlLength textIndent;
  final HtmlMargin? margin;
  final HtmlPadding? padding;
  final HtmlBorder? border;
  final HtmlBorderRadius? borderRadius;
  final HtmlBoxSizing boxSizing;
  final HtmlBackground? background;
  final List<HtmlBoxShadow> boxShadow;
  final HtmlTransform? transform;

  final List<Widget> _rawChildren;

  const HtmlDiv({
    super.key,
    this.width = const AutoSize(),
    this.height = const AutoSize(),
    this.minWidth,
    this.maxWidth,
    this.minHeight,
    this.maxHeight,
    this.display = HtmlDisplay.block,
    this.flexDirection = HtmlFlexDirection.row,
    this.justifyContent = HtmlJustifyContent.flexStart,
    this.alignItems = HtmlAlignItems.stretch,
    this.flexWrap = HtmlFlexWrap.noWrap,
    this.flexGrow = 0.0,
    this.flexShrink = 1.0,
    this.flexBasis = const HtmlLength.auto(),
    this.alignSelf = HtmlAlignSelf.auto,
    this.textAlign = HtmlTextAlign.start,
    this.overflowWrap = HtmlOverflowWrap.normal,
    this.lineHeight,
    this.textIndent = const HtmlLength.px(0),
    this.margin,
    this.padding,
    this.border,
    this.borderRadius,
    this.boxSizing = HtmlBoxSizing.contentBox,
    this.background,
    this.boxShadow = const <HtmlBoxShadow>[],
    this.transform,
    super.children = const <Widget>[],
  }) : _rawChildren = children;

  static bool _isTransparentInlineWrapper(HtmlDiv div) {
    if (div.display != HtmlDisplay.inline) return false;
    if (div.width is! AutoSize) return false;
    if (div.height is! AutoSize) return false;
    if (div.minWidth != null || div.maxWidth != null) return false;
    if (div.minHeight != null || div.maxHeight != null) return false;
    if (div.margin != null) return false;
    if (div.padding != null) return false;
    if (div.border != null) return false;
    if (div.borderRadius != null) return false;
    if (div.background != null) return false;
    if (div.boxShadow.isNotEmpty) return false;
    if (div.transform != null) return false;
    if (div.textAlign != HtmlTextAlign.start) return false;
    if (div.overflowWrap != HtmlOverflowWrap.normal) return false;
    if (div.lineHeight != null) return false;
    if (div.textIndent != const HtmlLength.px(0)) return false;
    if (div.flexGrow != 0.0) return false;
    if (div.flexShrink != 1.0) return false;
    if (div.flexBasis != const HtmlLength.auto()) return false;
    if (div.alignSelf != HtmlAlignSelf.auto) return false;
    return true;
  }

  static List<Widget> _normalizeChildren(List<Widget> children) {
    final List<Widget> out = <Widget>[];
    for (final Widget child in children) {
      if (child is Text) {
        out.add(HtmlText.fromText(child));
        continue;
      }

      // Flatten a visual/semantic no-op wrapper into the same inline run.
      // We keep keyed wrappers intact so callers/tests can still find them.
      if (child is HtmlDiv &&
          child.key == null &&
          _isTransparentInlineWrapper(child)) {
        out.addAll(_normalizeChildren(child._rawChildren));
        continue;
      }

      out.add(child);
    }
    return out;
  }

  @override
  List<Widget> get children => _normalizeChildren(_rawChildren);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderHtmlDiv(
      width: width,
      height: height,
      minWidth: minWidth,
      maxWidth: maxWidth,
      minHeight: minHeight,
      maxHeight: maxHeight,
      display: display,
      flexDirection: flexDirection,
      justifyContent: justifyContent,
      alignItems: alignItems,
      flexWrap: flexWrap,
      flexGrow: flexGrow,
      flexShrink: flexShrink,
      flexBasis: flexBasis,
      alignSelf: alignSelf,
      textAlign: textAlign,
      overflowWrap: overflowWrap,
      lineHeight: lineHeight,
      textIndent: textIndent,
      margin: margin,
      padding: padding,
      border: border,
      borderRadius: borderRadius,
      background: background,
      boxShadow: boxShadow,
      transform: transform,
      imageConfiguration: createLocalImageConfiguration(context),
      boxSizing: boxSizing,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderHtmlDiv renderObject) {
    renderObject
      ..width = width
      ..height = height
      ..minWidth = minWidth
      ..maxWidth = maxWidth
      ..minHeight = minHeight
      ..maxHeight = maxHeight
      ..display = display
      ..flexDirection = flexDirection
      ..justifyContent = justifyContent
      ..alignItems = alignItems
      ..flexWrap = flexWrap
      ..flexGrow = flexGrow
      ..flexShrink = flexShrink
      ..flexBasis = flexBasis
      ..alignSelf = alignSelf
      ..textAlign = textAlign
      ..overflowWrap = overflowWrap
      ..lineHeight = lineHeight
      ..textIndent = textIndent
      ..margin = margin
      ..padding = padding
      ..border = border
      ..borderRadius = borderRadius
      ..background = background
      ..boxShadow = boxShadow
      ..transform = transform
      ..imageConfiguration = createLocalImageConfiguration(context)
      ..boxSizing = boxSizing;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties.add(DiagnosticsProperty<HtmlSize>('width', width));
    properties.add(DiagnosticsProperty<HtmlSize>('height', height));
    properties.add(DiagnosticsProperty<HtmlSize?>('minWidth', minWidth));
    properties.add(DiagnosticsProperty<HtmlSize?>('maxWidth', maxWidth));
    properties.add(DiagnosticsProperty<HtmlSize?>('minHeight', minHeight));
    properties.add(DiagnosticsProperty<HtmlSize?>('maxHeight', maxHeight));

    properties.add(EnumProperty<HtmlDisplay>('display', display));
    properties.add(
      EnumProperty<HtmlFlexDirection>('flexDirection', flexDirection),
    );
    properties.add(
      EnumProperty<HtmlJustifyContent>('justifyContent', justifyContent),
    );
    properties.add(EnumProperty<HtmlAlignItems>('alignItems', alignItems));
    properties.add(EnumProperty<HtmlFlexWrap>('flexWrap', flexWrap));

    properties.add(DoubleProperty('flexGrow', flexGrow));
    properties.add(DoubleProperty('flexShrink', flexShrink));
    properties.add(DiagnosticsProperty<HtmlLength>('flexBasis', flexBasis));
    properties.add(EnumProperty<HtmlAlignSelf>('alignSelf', alignSelf));

    properties.add(EnumProperty<HtmlTextAlign>('textAlign', textAlign));
    properties.add(
      EnumProperty<HtmlOverflowWrap>('overflowWrap', overflowWrap),
    );
    properties.add(DiagnosticsProperty<HtmlLength?>('lineHeight', lineHeight));
    properties.add(DiagnosticsProperty<HtmlLength>('textIndent', textIndent));

    properties.add(DiagnosticsProperty<HtmlMargin?>('margin', margin));
    properties.add(DiagnosticsProperty<HtmlPadding?>('padding', padding));
    properties.add(DiagnosticsProperty<HtmlBorder?>('border', border));
    properties.add(
      DiagnosticsProperty<HtmlBorderRadius?>('borderRadius', borderRadius),
    );
    properties.add(EnumProperty<HtmlBoxSizing>('boxSizing', boxSizing));
    properties.add(
      DiagnosticsProperty<HtmlBackground?>('background', background),
    );
    properties.add(
      DiagnosticsProperty<List<HtmlBoxShadow>>('boxShadow', boxShadow),
    );
    properties.add(DiagnosticsProperty<HtmlTransform?>('transform', transform));
  }
}

class HtmlImage extends LeafRenderObjectWidget {
  final ImageProvider image;
  final BoxFit fit;
  final Alignment alignment;
  final FilterQuality filterQuality;

  /// CSS-like used width/height for the replaced element box.
  ///
  /// Supported values:
  /// - [FixedSize]
  /// - [PercentSize] (resolves against the incoming maxWidth/maxHeight if bounded)
  /// - [AutoSize]
  ///
  /// Any other [HtmlSize] (e.g. [FitContent]/[MinContent]/[MaxContent]) is
  /// treated as the default: [AutoSize].
  final HtmlSize width;
  final HtmlSize height;

  /// Natural size of the image in source pixels (encoded bitmap size).
  ///
  /// When provided, this is used as the preferred intrinsic size for
  /// `width/height: auto` calculations, avoiding async header probing.
  ///
  /// The corresponding logical size is `naturalPixelSize / naturalPixelScale`.
  final Size? naturalPixelSize;

  /// Scale that maps [naturalPixelSize] to logical pixels.
  ///
  /// This matches Flutter's image scale semantics (e.g. an @2x asset typically
  /// has scale=2.0). Defaults to 1.0.
  final double naturalPixelScale;

  final Size placeholderSize;
  final String? debugLabel;
  final TextStyle debugLabelTextStyle;
  final EdgeInsets debugLabelPadding;
  final Color debugLabelBackgroundColor;

  const HtmlImage({
    super.key,
    required this.image,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.filterQuality = FilterQuality.low,
    this.width = const AutoSize(),
    this.height = const AutoSize(),
    this.naturalPixelSize,
    this.naturalPixelScale = 1.0,
    this.placeholderSize = const Size(0, 0),
    this.debugLabel,
    this.debugLabelTextStyle = const TextStyle(
      color: Color(0xFFFFFFFF),
      fontSize: 11,
    ),
    this.debugLabelPadding = const EdgeInsets.symmetric(
      horizontal: 6,
      vertical: 4,
    ),
    this.debugLabelBackgroundColor = const Color(0x66000000),
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderHtmlImage(
      image: image,
      fit: fit,
      alignment: alignment,
      filterQuality: filterQuality,
      width: width,
      height: height,
      naturalPixelSize: naturalPixelSize,
      naturalPixelScale: naturalPixelScale,
      placeholderSize: placeholderSize,
      debugLabel: debugLabel,
      debugLabelTextStyle: debugLabelTextStyle,
      debugLabelPadding: debugLabelPadding,
      debugLabelBackgroundColor: debugLabelBackgroundColor,
      imageConfiguration: createLocalImageConfiguration(context),
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderHtmlImage renderObject) {
    renderObject
      ..image = image
      ..fit = fit
      ..alignment = alignment
      ..filterQuality = filterQuality
      ..width = width
      ..height = height
      ..naturalPixelSize = naturalPixelSize
      ..naturalPixelScale = naturalPixelScale
      ..placeholderSize = placeholderSize
      ..debugLabel = debugLabel
      ..debugLabelTextStyle = debugLabelTextStyle
      ..debugLabelPadding = debugLabelPadding
      ..debugLabelBackgroundColor = debugLabelBackgroundColor
      ..imageConfiguration = createLocalImageConfiguration(context);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties.add(DiagnosticsProperty<ImageProvider>('image', image));
    properties.add(EnumProperty<BoxFit>('fit', fit));
    properties.add(DiagnosticsProperty<Alignment>('alignment', alignment));
    properties.add(EnumProperty<FilterQuality>('filterQuality', filterQuality));

    properties.add(DiagnosticsProperty<HtmlSize>('width', width));
    properties.add(DiagnosticsProperty<HtmlSize>('height', height));
    properties.add(
      DiagnosticsProperty<Size?>('naturalPixelSize', naturalPixelSize),
    );
    properties.add(DoubleProperty('naturalPixelScale', naturalPixelScale));
    properties.add(
      DiagnosticsProperty<Size>('placeholderSize', placeholderSize),
    );

    properties.add(StringProperty('debugLabel', debugLabel));
    properties.add(
      DiagnosticsProperty<TextStyle>(
        'debugLabelTextStyle',
        debugLabelTextStyle,
      ),
    );
    properties.add(
      DiagnosticsProperty<EdgeInsets>('debugLabelPadding', debugLabelPadding),
    );
    properties.add(
      ColorProperty('debugLabelBackgroundColor', debugLabelBackgroundColor),
    );
  }

  @override
  void didUnmountRenderObject(RenderHtmlImage renderObject) {}
}
