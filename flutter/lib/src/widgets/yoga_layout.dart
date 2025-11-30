import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_yoga/src/rendering/yoga_layout.dart';
import 'package:flutter_yoga/src/yoga_ffi.dart';
import 'package:flutter_yoga/src/yoga_node.dart';
import 'package:flutter_yoga/src/yoga_value.dart';
import 'package:flutter_yoga/src/yoga_border.dart';
import 'package:flutter_yoga/src/yoga_background.dart';

import 'package:flutter_yoga/src/rendering/yoga_sliver_layout.dart';

export '../yoga_value.dart';
export '../yoga_border.dart';
export '../yoga_background.dart';
export 'yoga_scroll_controller.dart';

class YogaLayout extends StatelessWidget {
  final int flexDirection;
  final int? justifyContent;
  final int? alignItems;
  final int alignContent;
  final int flexWrap;
  final TextAlign? textAlign;
  final YogaValue? width;
  final YogaValue? height;
  final YogaValue? minWidth;
  final YogaValue? maxWidth;
  final YogaValue? minHeight;
  final YogaValue? maxHeight;
  final YogaEdgeInsets? padding;
  final EdgeInsets? borderWidth;
  final YogaBackground? background;
  final bool useWebDefaults;
  final bool enableMarginCollapsing;

  // YogaItem properties
  final double? flexGrow;
  final double? flexShrink;
  final double? flexBasis;
  final YogaDisplay? display;
  final YogaEdgeInsets? margin;
  final YogaBorder? border;
  final int? alignSelf;
  final List<YogaBoxShadow>? boxShadow;
  final YogaBoxSizing? boxSizing;
  final YogaOverflow? overflow;
  final Matrix4? transform;
  final AlignmentGeometry? transformOrigin;

  final List<Widget> children;

  // New properties
  final bool scroll;
  final ScrollController? controller;

  const YogaLayout({
    super.key,
    this.flexDirection = YGFlexDirection.column,
    this.justifyContent,
    this.alignItems = YGAlign.baseline,
    this.alignContent = YGAlign.flexStart,
    this.flexWrap = YGWrap.noWrap,
    this.textAlign,
    this.width,
    this.height,
    this.minWidth,
    this.maxWidth,
    this.minHeight,
    this.maxHeight,
    this.padding,
    this.borderWidth,
    this.background,
    this.flexGrow,
    this.flexShrink,
    this.flexBasis,
    this.display = YogaDisplay.block,
    this.margin,
    this.border,
    this.alignSelf,
    this.boxShadow,
    this.boxSizing,
    this.overflow,
    this.transform,
    this.transformOrigin,
    this.useWebDefaults = true,
    this.enableMarginCollapsing = true,
    this.scroll = false,
    this.controller,
    this.children = const <Widget>[],
  });

  @override
  Widget build(BuildContext context) {
    if (scroll) {
      Widget sliver = _SliverYogaLayout(
        delegate: SliverChildBuilderDelegate(
          (context, index) => children[index],
          childCount: children.length,
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: false,
          addSemanticIndexes: false,
        ),
        flexDirection: flexDirection,
        justifyContent: justifyContent,
        alignItems: alignItems,
        useWebDefaults: useWebDefaults,
        enableMarginCollapsing: enableMarginCollapsing,
        controller: controller,
      );

      if (padding != null) {
        sliver = SliverPadding(
          padding: _yogaEdgeInsetsToEdgeInsets(padding!),
          sliver: sliver,
        );
      }

      return _YogaLayoutScope(
        isSliver: true,
        child: CustomScrollView(
          controller: controller,
          slivers: [sliver],
        ),
      );
    }

    return _YogaLayoutScope(
      isSliver: false,
      child: _YogaLayoutBox(
        flexDirection: flexDirection,
        justifyContent: justifyContent,
        alignItems: alignItems,
        alignContent: alignContent,
        flexWrap: flexWrap,
        textAlign: textAlign,
        width: width,
        height: height,
        minWidth: minWidth,
        maxWidth: maxWidth,
        minHeight: minHeight,
        maxHeight: maxHeight,
        padding: padding,
        borderWidth: borderWidth,
        background: background,
        flexGrow: flexGrow,
        flexShrink: flexShrink,
        flexBasis: flexBasis,
        display: display,
        margin: margin,
        border: border,
        alignSelf: alignSelf,
        boxShadow: boxShadow,
        boxSizing: boxSizing,
        overflow: overflow,
        transform: transform,
        transformOrigin: transformOrigin,
        useWebDefaults: useWebDefaults,
        enableMarginCollapsing: enableMarginCollapsing,
        children: children,
      ),
    );
  }
}

class _SliverYogaLayout extends SliverMultiBoxAdaptorWidget {
  final int flexDirection;
  final int? justifyContent;
  final int? alignItems;
  final bool useWebDefaults;
  final bool enableMarginCollapsing;
  final ScrollController? controller;

  const _SliverYogaLayout({
    required super.delegate,
    this.flexDirection = YGFlexDirection.column,
    this.justifyContent,
    this.alignItems,
    this.useWebDefaults = false,
    this.enableMarginCollapsing = false,
    this.controller,
  });

  @override
  RenderSliverYogaLayout createRenderObject(BuildContext context) {
    final SliverMultiBoxAdaptorElement element =
        context as SliverMultiBoxAdaptorElement;
    return RenderSliverYogaLayout(
      childManager: element,
      config:
          YogaConfig(), // We create a new config or share? RenderYogaLayout creates one.
      flexDirection: flexDirection,
      justifyContent: justifyContent ?? YGJustify.flexStart,
      alignItems: alignItems ?? YGAlign.stretch,
      useWebDefaults: useWebDefaults,
      enableMarginCollapsing: enableMarginCollapsing,
      controller: controller,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSliverYogaLayout renderObject,
  ) {
    renderObject
      ..flexDirection = flexDirection
      ..justifyContent = justifyContent ?? YGJustify.flexStart
      ..alignItems = alignItems ?? YGAlign.stretch
      ..useWebDefaults = useWebDefaults
      ..enableMarginCollapsing = enableMarginCollapsing
      ..controller = controller;
  }
}

class _YogaLayoutBox extends MultiChildRenderObjectWidget {
  final int flexDirection;
  final int? justifyContent;
  final int? alignItems;
  final int alignContent;
  final int flexWrap;
  final TextAlign? textAlign;
  final YogaValue? width;
  final YogaValue? height;
  final YogaValue? minWidth;
  final YogaValue? maxWidth;
  final YogaValue? minHeight;
  final YogaValue? maxHeight;
  final YogaEdgeInsets? padding;
  final EdgeInsets? borderWidth;
  final YogaBackground? background;
  final bool useWebDefaults;
  final bool enableMarginCollapsing;

  // YogaItem properties
  final double? flexGrow;
  final double? flexShrink;
  final double? flexBasis;
  final YogaDisplay? display;
  final YogaEdgeInsets? margin;
  final YogaBorder? border;
  final int? alignSelf;
  final List<YogaBoxShadow>? boxShadow;
  final YogaBoxSizing? boxSizing;
  final YogaOverflow? overflow;
  final Matrix4? transform;
  final AlignmentGeometry? transformOrigin;

  const _YogaLayoutBox({
    this.flexDirection = YGFlexDirection.column,
    this.justifyContent,
    this.alignItems = YGAlign.baseline,
    this.alignContent = YGAlign.flexStart,
    this.flexWrap = YGWrap.noWrap,
    this.textAlign,
    this.width,
    this.height,
    this.minWidth,
    this.maxWidth,
    this.minHeight,
    this.maxHeight,
    this.padding,
    this.borderWidth,
    this.background,
    this.flexGrow,
    this.flexShrink,
    this.flexBasis,
    this.display = YogaDisplay.block,
    this.margin,
    this.border,
    this.alignSelf,
    this.boxShadow,
    this.boxSizing,
    this.overflow,
    this.transform,
    this.transformOrigin,
    this.useWebDefaults = true,
    this.enableMarginCollapsing = true,
    super.children,
  });

  @override
  RenderYogaLayout createRenderObject(BuildContext context) {
    return RenderYogaLayout()
      ..flexDirection = flexDirection
      ..justifyContent = justifyContent
      ..alignItems = alignItems
      ..textAlign = textAlign
      ..rootNode.alignContent = alignContent
      ..rootNode.flexWrap = flexWrap
      ..width = width
      ..height = height
      ..minWidth = minWidth
      ..maxWidth = maxWidth
      ..minHeight = minHeight
      ..maxHeight = maxHeight
      ..useWebDefaults = useWebDefaults
      ..enableMarginCollapsing = enableMarginCollapsing
      ..padding = padding
      ..borderWidth = borderWidth
      ..background = background
      // YogaItem properties
      ..flexGrow = flexGrow
      ..flexShrink = flexShrink
      ..flexBasis = flexBasis
      ..display = display
      ..margin = margin
      ..border = border
      ..alignSelf = alignSelf
      ..boxShadow = boxShadow
      ..boxSizing = boxSizing
      ..overflow = overflow
      ..transform = transform
      ..transformOrigin = transformOrigin;
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderYogaLayout renderObject,
  ) {
    renderObject
      ..flexDirection = flexDirection
      ..justifyContent = justifyContent
      ..alignItems = alignItems
      ..textAlign = textAlign
      ..rootNode.alignContent = alignContent
      ..rootNode.flexWrap = flexWrap
      ..width = width
      ..height = height
      ..minWidth = minWidth
      ..maxWidth = maxWidth
      ..minHeight = minHeight
      ..maxHeight = maxHeight
      ..useWebDefaults = useWebDefaults
      ..enableMarginCollapsing = enableMarginCollapsing
      ..padding = padding
      ..borderWidth = borderWidth
      ..background = background
      // YogaItem properties
      ..flexGrow = flexGrow
      ..flexShrink = flexShrink
      ..flexBasis = flexBasis
      ..display = display
      ..margin = margin
      ..border = border
      ..alignSelf = alignSelf
      ..boxShadow = boxShadow
      ..boxSizing = boxSizing
      ..overflow = overflow
      ..transform = transform
      ..transformOrigin = transformOrigin;

    renderObject.markNeedsLayout();
  }
}

class YogaItem extends StatelessWidget {
  final double? flexGrow;
  final double? flexShrink;
  final double? flexBasis;
  final YogaDisplay? display;
  final YogaValue? width;
  final YogaValue? height;
  final YogaValue? minWidth;
  final YogaValue? maxWidth;
  final YogaValue? minHeight;
  final YogaValue? maxHeight;
  final YogaEdgeInsets? margin;
  final YogaBorder? border;
  final int? alignSelf;
  final TextAlign? textAlign;
  final List<YogaBoxShadow>? boxShadow;
  final YogaBoxSizing? boxSizing;
  final YogaOverflow? overflow;
  final Matrix4? transform;
  final AlignmentGeometry? transformOrigin;
  final Widget child;

  const YogaItem({
    super.key,
    this.flexGrow,
    this.flexShrink,
    this.flexBasis,
    this.display,
    this.width,
    this.height,
    this.minWidth,
    this.maxWidth,
    this.minHeight,
    this.maxHeight,
    this.margin,
    this.border,
    this.alignSelf,
    this.textAlign,
    this.boxShadow,
    this.boxSizing,
    this.overflow,
    this.transform,
    this.transformOrigin,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSliver = _YogaLayoutScope.of(context);
    if (isSliver) {
      return _YogaSliverItem(
        flexGrow: flexGrow,
        flexShrink: flexShrink,
        flexBasis: flexBasis,
        display: display,
        width: width,
        height: height,
        minWidth: minWidth,
        maxWidth: maxWidth,
        minHeight: minHeight,
        maxHeight: maxHeight,
        margin: margin,
        border: border,
        alignSelf: alignSelf,
        textAlign: textAlign,
        boxShadow: boxShadow,
        boxSizing: boxSizing,
        overflow: overflow,
        transform: transform,
        transformOrigin: transformOrigin,
        child: child,
      );
    } else {
      return _YogaBoxItem(
        flexGrow: flexGrow,
        flexShrink: flexShrink,
        flexBasis: flexBasis,
        display: display,
        width: width,
        height: height,
        minWidth: minWidth,
        maxWidth: maxWidth,
        minHeight: minHeight,
        maxHeight: maxHeight,
        margin: margin,
        border: border,
        alignSelf: alignSelf,
        textAlign: textAlign,
        boxShadow: boxShadow,
        boxSizing: boxSizing,
        overflow: overflow,
        transform: transform,
        transformOrigin: transformOrigin,
        child: child,
      );
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('flexGrow', flexGrow));
    properties.add(DoubleProperty('flexShrink', flexShrink));
    properties.add(DoubleProperty('flexBasis', flexBasis));
    properties.add(EnumProperty<YogaDisplay>('display', display));
    properties.add(DiagnosticsProperty<YogaValue>('width', width));
    properties.add(DiagnosticsProperty<YogaValue>('height', height));
    properties.add(DiagnosticsProperty<YogaValue>('minWidth', minWidth));
    properties.add(DiagnosticsProperty<YogaValue>('maxWidth', maxWidth));
    properties.add(DiagnosticsProperty<YogaValue>('minHeight', minHeight));
    properties.add(DiagnosticsProperty<YogaValue>('maxHeight', maxHeight));
    properties.add(DiagnosticsProperty<YogaEdgeInsets>('margin', margin));
    properties.add(DiagnosticsProperty<YogaBorder>('border', border));
    properties.add(IntProperty('alignSelf', alignSelf));
    properties.add(EnumProperty<TextAlign>('textAlign', textAlign));
    properties.add(
      DiagnosticsProperty<List<YogaBoxShadow>>('boxShadow', boxShadow),
    );
    properties.add(EnumProperty<YogaBoxSizing>('boxSizing', boxSizing));
    properties.add(EnumProperty<YogaOverflow>('overflow', overflow));
    properties.add(TransformProperty('transform', transform));
    properties.add(
      DiagnosticsProperty<AlignmentGeometry>(
        'transformOrigin',
        transformOrigin,
      ),
    );
  }
}

class _YogaBoxItem extends ParentDataWidget<YogaLayoutParentData> {
  final double? flexGrow;
  final double? flexShrink;
  final double? flexBasis;
  final YogaDisplay? display;
  final YogaValue? width;
  final YogaValue? height;
  final YogaValue? minWidth;
  final YogaValue? maxWidth;
  final YogaValue? minHeight;
  final YogaValue? maxHeight;
  final YogaEdgeInsets? margin;
  final YogaBorder? border;
  final int? alignSelf;
  final TextAlign? textAlign;
  final List<YogaBoxShadow>? boxShadow;
  final YogaBoxSizing? boxSizing;
  final YogaOverflow? overflow;
  final Matrix4? transform;
  final AlignmentGeometry? transformOrigin;

  const _YogaBoxItem({
    this.flexGrow,
    this.flexShrink,
    this.flexBasis,
    this.display,
    this.width,
    this.height,
    this.minWidth,
    this.maxWidth,
    this.minHeight,
    this.maxHeight,
    this.margin,
    this.border,
    this.alignSelf,
    this.textAlign,
    this.boxShadow,
    this.boxSizing,
    this.overflow,
    this.transform,
    this.transformOrigin,
    required super.child,
  });

  @override
  void applyParentData(RenderObject renderObject) {
    _applyYogaParentData(renderObject, this);
  }

  @override
  Type get debugTypicalAncestorWidgetClass => YogaLayout;
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('flexGrow', flexGrow));
    properties.add(DoubleProperty('flexShrink', flexShrink));
    properties.add(DoubleProperty('flexBasis', flexBasis));
    properties.add(EnumProperty<YogaDisplay>('display', display));
    properties.add(DiagnosticsProperty<YogaValue>('width', width));
    properties.add(DiagnosticsProperty<YogaValue>('height', height));
    properties.add(DiagnosticsProperty<YogaValue>('minWidth', minWidth));
    properties.add(DiagnosticsProperty<YogaValue>('maxWidth', maxWidth));
    properties.add(DiagnosticsProperty<YogaValue>('minHeight', minHeight));
    properties.add(DiagnosticsProperty<YogaValue>('maxHeight', maxHeight));
    properties.add(DiagnosticsProperty<YogaEdgeInsets>('margin', margin));
    properties.add(DiagnosticsProperty<YogaBorder>('border', border));
    properties.add(IntProperty('alignSelf', alignSelf));
    properties.add(EnumProperty<TextAlign>('textAlign', textAlign));
    properties.add(
      DiagnosticsProperty<List<YogaBoxShadow>>('boxShadow', boxShadow),
    );
    properties.add(EnumProperty<YogaBoxSizing>('boxSizing', boxSizing));
    properties.add(EnumProperty<YogaOverflow>('overflow', overflow));
    properties.add(TransformProperty('transform', transform));
    properties.add(
      DiagnosticsProperty<AlignmentGeometry>(
        'transformOrigin',
        transformOrigin,
      ),
    );
  }
}

class _YogaSliverItem extends ParentDataWidget<YogaSliverLayoutParentData> {
  final double? flexGrow;
  final double? flexShrink;
  final double? flexBasis;
  final YogaDisplay? display;
  final YogaValue? width;
  final YogaValue? height;
  final YogaValue? minWidth;
  final YogaValue? maxWidth;
  final YogaValue? minHeight;
  final YogaValue? maxHeight;
  final YogaEdgeInsets? margin;
  final YogaBorder? border;
  final int? alignSelf;
  final TextAlign? textAlign;
  final List<YogaBoxShadow>? boxShadow;
  final YogaBoxSizing? boxSizing;
  final YogaOverflow? overflow;
  final Matrix4? transform;
  final AlignmentGeometry? transformOrigin;

  const _YogaSliverItem({
    this.flexGrow,
    this.flexShrink,
    this.flexBasis,
    this.display,
    this.width,
    this.height,
    this.minWidth,
    this.maxWidth,
    this.minHeight,
    this.maxHeight,
    this.margin,
    this.border,
    this.alignSelf,
    this.textAlign,
    this.boxShadow,
    this.boxSizing,
    this.overflow,
    this.transform,
    this.transformOrigin,
    required super.child,
  });

  @override
  void applyParentData(RenderObject renderObject) {
    _applyYogaParentData(renderObject, this);
  }

  @override
  Type get debugTypicalAncestorWidgetClass => YogaLayout;
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('flexGrow', flexGrow));
    properties.add(DoubleProperty('flexShrink', flexShrink));
    properties.add(DoubleProperty('flexBasis', flexBasis));
    properties.add(EnumProperty<YogaDisplay>('display', display));
    properties.add(DiagnosticsProperty<YogaValue>('width', width));
    properties.add(DiagnosticsProperty<YogaValue>('height', height));
    properties.add(DiagnosticsProperty<YogaValue>('minWidth', minWidth));
    properties.add(DiagnosticsProperty<YogaValue>('maxWidth', maxWidth));
    properties.add(DiagnosticsProperty<YogaValue>('minHeight', minHeight));
    properties.add(DiagnosticsProperty<YogaValue>('maxHeight', maxHeight));
    properties.add(DiagnosticsProperty<YogaEdgeInsets>('margin', margin));
    properties.add(DiagnosticsProperty<YogaBorder>('border', border));
    properties.add(IntProperty('alignSelf', alignSelf));
    properties.add(EnumProperty<TextAlign>('textAlign', textAlign));
    properties.add(
      DiagnosticsProperty<List<YogaBoxShadow>>('boxShadow', boxShadow),
    );
    properties.add(EnumProperty<YogaBoxSizing>('boxSizing', boxSizing));
    properties.add(EnumProperty<YogaOverflow>('overflow', overflow));
    properties.add(TransformProperty('transform', transform));
    properties.add(
      DiagnosticsProperty<AlignmentGeometry>(
        'transformOrigin',
        transformOrigin,
      ),
    );
  }
}

void _applyYogaParentData(RenderObject renderObject, dynamic widget) {
  assert(renderObject.parentData is YogaParentDataMixin);
  final YogaParentDataMixin parentData =
      renderObject.parentData as YogaParentDataMixin;
  bool needsLayout = false;
  bool needsPaint = false;

  if (parentData.yogaNode == null) {
    parentData.yogaNode = YogaNode();
    needsLayout = true;
  }

  final node = parentData.yogaNode!;

  if (parentData.textAlign != widget.textAlign) {
    parentData.textAlign = widget.textAlign;
    needsLayout = true;
  }

  if (parentData.transform != widget.transform) {
    parentData.transform = widget.transform;
    needsPaint = true;
  }

  if (parentData.transformOrigin != widget.transformOrigin) {
    parentData.transformOrigin = widget.transformOrigin;
    needsPaint = true;
  }

  if (parentData.boxSizing != widget.boxSizing) {
    parentData.boxSizing = widget.boxSizing;
    needsLayout = true;
  }

  if (parentData.overflow != widget.overflow) {
    parentData.overflow = widget.overflow;
    needsPaint = true;
  }

  if (parentData.flexGrow != widget.flexGrow) {
    parentData.flexGrow = widget.flexGrow;
    if (widget.flexGrow != null) node.flexGrow = widget.flexGrow!;
    needsLayout = true;
  }

  if (parentData.flexShrink != widget.flexShrink) {
    parentData.flexShrink = widget.flexShrink;
    if (widget.flexShrink != null) node.flexShrink = widget.flexShrink!;
    needsLayout = true;
  }

  if (parentData.flexBasis != widget.flexBasis) {
    parentData.flexBasis = widget.flexBasis;
    if (widget.flexBasis != null) {
      node.flexBasis = widget.flexBasis!;
    } else {
      node.setFlexBasisAuto();
    }
    needsLayout = true;
  }

  // Handle Display and Width together
  if (parentData.display != widget.display ||
      parentData.width != widget.width) {
    parentData.display = widget.display;
    parentData.width = widget.width;

    // 1. Set Yoga Display
    if (widget.display == YogaDisplay.none) {
      node.display = YGDisplay.none;
    } else {
      node.display = YGDisplay.flex;
    }

    // 2. Set Yoga Width
    if (widget.width != null) {
      _applyWidth(node, widget.width!);
    } else {
      // Width is Auto (null)
      if (widget.display == YogaDisplay.block) {
        // Block behaves like width: 100%
        node.setWidthPercent(100);
      } else {
        // Inline, InlineBlock, Flex (default) behave like width: auto
        node.setWidthAuto();
      }
    }
    needsLayout = true;
  }

  if (parentData.height != widget.height) {
    parentData.height = widget.height;

    if (widget.height != null) {
      _applyHeight(node, widget.height!);
    } else {
      node.setHeightAuto();
    }
    needsLayout = true;
  }

  if (parentData.minWidth != widget.minWidth) {
    parentData.minWidth = widget.minWidth;
    if (widget.minWidth != null) {
      _applyMinWidth(node, widget.minWidth!);
    } else {
      node.minWidth = double.nan;
    }
    needsLayout = true;
  }

  if (parentData.maxWidth != widget.maxWidth) {
    parentData.maxWidth = widget.maxWidth;
    if (widget.maxWidth != null) {
      _applyMaxWidth(node, widget.maxWidth!);
    } else {
      node.maxWidth = double.nan;
    }
    needsLayout = true;
  }

  if (parentData.minHeight != widget.minHeight) {
    parentData.minHeight = widget.minHeight;
    if (widget.minHeight != null) {
      _applyMinHeight(node, widget.minHeight!);
    } else {
      node.minHeight = double.nan;
    }
    needsLayout = true;
  }

  if (parentData.maxHeight != widget.maxHeight) {
    parentData.maxHeight = widget.maxHeight;
    if (widget.maxHeight != null) {
      _applyMaxHeight(node, widget.maxHeight!);
    } else {
      node.maxHeight = double.nan;
    }
    needsLayout = true;
  }

  if (parentData.margin != widget.margin ||
      parentData.boxShadow != widget.boxShadow) {
    parentData.margin = widget.margin;
    parentData.boxShadow = widget.boxShadow;

    _applyMargin(node, widget.margin);
    needsLayout = true;
  }

  if (parentData.border != widget.border) {
    parentData.border = widget.border;
    needsLayout = true;
  }

  if (parentData.alignSelf != widget.alignSelf) {
    parentData.alignSelf = widget.alignSelf;
    if (widget.alignSelf != null) node.alignSelf = widget.alignSelf!;
    needsLayout = true;
  }

  if (needsLayout) {
    final targetParent = renderObject.parent;
    if (targetParent is RenderObject) {
      targetParent.markNeedsLayout();
    }
  } else if (needsPaint) {
    final targetParent = renderObject.parent;
    if (targetParent is RenderObject) {
      targetParent.markNeedsPaint();
    }
  }
}

void _applyWidth(YogaNode node, YogaValue width) {
  switch (width.unit) {
    case YogaUnit.point:
      node.width = width.value;
      break;
    case YogaUnit.percent:
      node.setWidthPercent(width.value);
      break;
    case YogaUnit.auto:
      node.setWidthAuto();
      break;
    case YogaUnit.undefined:
      node.setWidthAuto(); // Or undefined?
      break;
    case YogaUnit.maxContent:
      node.setWidthAuto();
      break;
    case YogaUnit.minContent:
      node.setWidthAuto();
      break;
    case YogaUnit.fitContent:
      node.setWidthAuto();
      break;
  }
}

void _applyHeight(YogaNode node, YogaValue height) {
  switch (height.unit) {
    case YogaUnit.point:
      node.height = height.value;
      break;
    case YogaUnit.percent:
      node.setHeightPercent(height.value);
      break;
    case YogaUnit.auto:
      node.setHeightAuto();
      break;
    case YogaUnit.undefined:
      node.setHeightAuto();
      break;
    case YogaUnit.maxContent:
      node.setHeightAuto();
      break;
    case YogaUnit.minContent:
      node.setHeightAuto();
      break;
    case YogaUnit.fitContent:
      node.setHeightAuto();
      break;
  }
}

void _applyMinWidth(YogaNode node, YogaValue minWidth) {
  switch (minWidth.unit) {
    case YogaUnit.point:
      node.minWidth = minWidth.value;
      break;
    case YogaUnit.percent:
      node.setMinWidthPercent(minWidth.value);
      break;
    case YogaUnit.auto:
    case YogaUnit.undefined:
    case YogaUnit.maxContent:
    case YogaUnit.minContent:
    case YogaUnit.fitContent:
      node.minWidth = double.nan;
      break;
  }
}

void _applyMaxWidth(YogaNode node, YogaValue maxWidth) {
  switch (maxWidth.unit) {
    case YogaUnit.point:
      node.maxWidth = maxWidth.value;
      break;
    case YogaUnit.percent:
      node.setMaxWidthPercent(maxWidth.value);
      break;
    case YogaUnit.auto:
    case YogaUnit.undefined:
    case YogaUnit.maxContent:
    case YogaUnit.minContent:
    case YogaUnit.fitContent:
      node.maxWidth = double.nan;
      break;
  }
}

void _applyMinHeight(YogaNode node, YogaValue minHeight) {
  switch (minHeight.unit) {
    case YogaUnit.point:
      node.minHeight = minHeight.value;
      break;
    case YogaUnit.percent:
      node.setMinHeightPercent(minHeight.value);
      break;
    case YogaUnit.auto:
    case YogaUnit.undefined:
    case YogaUnit.maxContent:
    case YogaUnit.minContent:
    case YogaUnit.fitContent:
      node.minHeight = double.nan;
      break;
  }
}

void _applyMaxHeight(YogaNode node, YogaValue maxHeight) {
  switch (maxHeight.unit) {
    case YogaUnit.point:
      node.maxHeight = maxHeight.value;
      break;
    case YogaUnit.percent:
      node.setMaxHeightPercent(maxHeight.value);
      break;
    case YogaUnit.auto:
    case YogaUnit.undefined:
    case YogaUnit.maxContent:
    case YogaUnit.minContent:
    case YogaUnit.fitContent:
      node.maxHeight = double.nan;
      break;
  }
}

void _applyMargin(YogaNode node, YogaEdgeInsets? margin) {
  _setMarginEdge(node, YGEdge.left, margin?.left);
  _setMarginEdge(node, YGEdge.top, margin?.top);
  _setMarginEdge(node, YGEdge.right, margin?.right);
  _setMarginEdge(node, YGEdge.bottom, margin?.bottom);
}

void _setMarginEdge(YogaNode node, int edge, YogaValue? value) {
  if (value == null) {
    node.setMargin(edge, 0);
    return;
  }
  switch (value.unit) {
    case YogaUnit.point:
      node.setMargin(edge, value.value);
      break;
    case YogaUnit.percent:
      node.setMarginPercent(edge, value.value);
      break;
    case YogaUnit.auto:
      node.setMarginAuto(edge);
      break;
    case YogaUnit.undefined:
      node.setMargin(edge, 0);
      break;
    case YogaUnit.maxContent:
    case YogaUnit.minContent:
    case YogaUnit.fitContent:
      node.setMargin(edge, 0);
      break;
  }
}

class _YogaLayoutScope extends InheritedWidget {
  final bool isSliver;

  const _YogaLayoutScope({required this.isSliver, required super.child});

  static bool of(BuildContext context) {
    final _YogaLayoutScope? result = context
        .dependOnInheritedWidgetOfExactType<_YogaLayoutScope>();
    return result?.isSliver ?? false;
  }

  @override
  bool updateShouldNotify(_YogaLayoutScope oldWidget) {
    return isSliver != oldWidget.isSliver;
  }
}

EdgeInsets _yogaEdgeInsetsToEdgeInsets(YogaEdgeInsets padding) {
  double left = 0;
  double top = 0;
  double right = 0;
  double bottom = 0;

  if (padding.left.unit == YogaUnit.point) {
    left = padding.left.value;
  }
  if (padding.top.unit == YogaUnit.point) {
    top = padding.top.value;
  }
  if (padding.right.unit == YogaUnit.point) {
    right = padding.right.value;
  }
  if (padding.bottom.unit == YogaUnit.point) {
    bottom = padding.bottom.value;
  }

  return EdgeInsets.fromLTRB(left, top, right, bottom);
}
