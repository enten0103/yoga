import 'package:flutter/widgets.dart';
import '../rendering/yoga_layout.dart';
import '../yoga_ffi.dart';
import '../yoga_node.dart';
import '../yoga_value.dart';
import '../yoga_border.dart';

export '../yoga_value.dart';
export '../yoga_border.dart';

class YogaLayout extends MultiChildRenderObjectWidget {
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

  const YogaLayout({
    super.key,
    this.flexDirection = YGFlexDirection.column,
    this.justifyContent,
    this.alignItems,
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
    this.flexGrow,
    this.flexShrink,
    this.flexBasis,
    this.display,
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

class YogaItem extends ParentDataWidget<YogaLayoutParentData> {
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
  final List<YogaBoxShadow>? boxShadow;
  final YogaBoxSizing? boxSizing;
  final YogaOverflow? overflow;
  final Matrix4? transform;
  final AlignmentGeometry? transformOrigin;

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
    this.boxShadow,
    this.boxSizing,
    this.overflow,
    this.transform,
    this.transformOrigin,
    required super.child,
  });

  @override
  void applyParentData(RenderObject renderObject) {
    final parentData = renderObject.parentData as YogaLayoutParentData;
    bool needsLayout = false;
    bool needsPaint = false;

    if (parentData.yogaNode == null) {
      parentData.yogaNode = YogaNode();
      needsLayout = true;
    }

    final node = parentData.yogaNode!;

    if (parentData.transform != transform) {
      parentData.transform = transform;
      needsPaint = true;
    }

    if (parentData.transformOrigin != transformOrigin) {
      parentData.transformOrigin = transformOrigin;
      needsPaint = true;
    }

    if (parentData.boxSizing != boxSizing) {
      parentData.boxSizing = boxSizing;
      needsLayout = true;
    }

    if (parentData.overflow != overflow) {
      parentData.overflow = overflow;
      // Overflow affects painting, so we need to repaint.
      // But if it changes layout (scroll), it might need layout.
      // For now, we only support visible/hidden which is paint/clip.
      needsPaint = true;
    }

    if (parentData.flexGrow != flexGrow) {
      parentData.flexGrow = flexGrow;
      if (flexGrow != null) node.flexGrow = flexGrow!;
      needsLayout = true;
    }

    if (parentData.flexShrink != flexShrink) {
      parentData.flexShrink = flexShrink;
      if (flexShrink != null) node.flexShrink = flexShrink!;
      needsLayout = true;
    }

    if (parentData.flexBasis != flexBasis) {
      parentData.flexBasis = flexBasis;
      if (flexBasis != null) {
        node.flexBasis = flexBasis!;
      } else {
        node.setFlexBasisAuto();
      }
      needsLayout = true;
    }

    // Handle Display and Width together
    if (parentData.display != display || parentData.width != width) {
      parentData.display = display;
      parentData.width = width;

      // 1. Set Yoga Display
      if (display == YogaDisplay.none) {
        node.display = YGDisplay.none;
      } else {
        node.display = YGDisplay.flex;
      }

      // 2. Set Yoga Width
      if (width != null) {
        _applyWidth(node, width!);
      } else {
        // Width is Auto (null)
        if (display == YogaDisplay.block) {
          // Block behaves like width: 100%
          node.setWidthPercent(100);
        } else {
          // Inline, InlineBlock, Flex (default) behave like width: auto
          node.setWidthAuto();
        }
      }
      needsLayout = true;
    }

    if (parentData.height != height) {
      parentData.height = height;

      if (height != null) {
        _applyHeight(node, height!);
      } else {
        node.setHeightAuto();
      }
      needsLayout = true;
    }

    if (parentData.minWidth != minWidth) {
      parentData.minWidth = minWidth;
      if (minWidth != null) {
        _applyMinWidth(node, minWidth!);
      } else {
        // Default minWidth is usually 0 or auto depending on context, but Yoga default is NaN (undefined) which means 0 usually?
        // Actually Yoga default minWidth is 0.
        // But we don't have a "clear" method easily exposed here without checking unit.
        // Let's assume if null, we set to undefined/0.
        // YogaNode.setMinWidth(NaN) -> undefined.
        node.minWidth = double.nan;
      }
      needsLayout = true;
    }

    if (parentData.maxWidth != maxWidth) {
      parentData.maxWidth = maxWidth;
      if (maxWidth != null) {
        _applyMaxWidth(node, maxWidth!);
      } else {
        node.maxWidth = double.nan;
      }
      needsLayout = true;
    }

    if (parentData.minHeight != minHeight) {
      parentData.minHeight = minHeight;
      if (minHeight != null) {
        _applyMinHeight(node, minHeight!);
      } else {
        node.minHeight = double.nan;
      }
      needsLayout = true;
    }

    if (parentData.maxHeight != maxHeight) {
      parentData.maxHeight = maxHeight;
      if (maxHeight != null) {
        _applyMaxHeight(node, maxHeight!);
      } else {
        node.maxHeight = double.nan;
      }
      needsLayout = true;
    }

    if (parentData.margin != margin || parentData.boxShadow != boxShadow) {
      parentData.margin = margin;
      parentData.boxShadow = boxShadow;

      _applyMargin(node, margin);
      needsLayout = true;
    }

    if (parentData.border != border) {
      parentData.border = border;
      // We can't fully resolve border here without TextDirection,
      // but we can set physical borders if they are explicit.
      // However, RenderYogaLayout.performLayout will handle the full resolution
      // and setting of border widths on the YogaNode.
      // So we just mark for layout.
      needsLayout = true;
    }

    if (parentData.alignSelf != alignSelf) {
      parentData.alignSelf = alignSelf;
      if (alignSelf != null) node.alignSelf = alignSelf!;
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
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => YogaLayout;
}
