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
    super.children = const [],
  });

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
