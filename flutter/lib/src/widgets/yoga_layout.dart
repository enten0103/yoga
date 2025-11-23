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
  final int justifyContent;
  final int alignItems;
  final int alignContent;
  final int flexWrap;
  final YogaValue? width;
  final YogaValue? height;
  final YogaEdgeInsets? padding;
  final EdgeInsets? borderWidth;
  final bool useWebDefaults;
  final bool enableMarginCollapsing;

  const YogaLayout({
    super.key,
    this.flexDirection = YGFlexDirection.column,
    this.justifyContent = YGJustify.flexStart,
    this.alignItems = YGAlign.stretch,
    this.alignContent = YGAlign.flexStart,
    this.flexWrap = YGWrap.noWrap,
    this.width,
    this.height,
    this.padding,
    this.borderWidth,
    this.useWebDefaults = false,
    this.enableMarginCollapsing = false,
    super.children,
  });

  @override
  RenderYogaLayout createRenderObject(BuildContext context) {
    return RenderYogaLayout()
      ..rootNode.flexDirection = flexDirection
      ..rootNode.justifyContent = justifyContent
      ..rootNode.alignItems = alignItems
      ..rootNode.alignContent = alignContent
      ..rootNode.flexWrap = flexWrap
      ..width = width
      ..height = height
      ..useWebDefaults = useWebDefaults
      ..enableMarginCollapsing = enableMarginCollapsing
      ..padding = padding
      ..borderWidth = borderWidth;
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderYogaLayout renderObject,
  ) {
    renderObject
      ..rootNode.flexDirection = flexDirection
      ..rootNode.justifyContent = justifyContent
      ..rootNode.alignItems = alignItems
      ..rootNode.alignContent = alignContent
      ..rootNode.flexWrap = flexWrap
      ..width = width
      ..height = height
      ..useWebDefaults = useWebDefaults
      ..enableMarginCollapsing = enableMarginCollapsing
      ..padding = padding
      ..borderWidth = borderWidth;

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
  final YogaEdgeInsets? margin;
  final YogaBorder? border;
  final int? alignSelf;
  final List<YogaBoxShadow>? boxShadow;
  final YogaBoxSizing? boxSizing;

  const YogaItem({
    super.key,
    this.flexGrow,
    this.flexShrink,
    this.flexBasis,
    this.display,
    this.width,
    this.height,
    this.margin,
    this.border,
    this.alignSelf,
    this.boxShadow,
    this.boxSizing,
    required super.child,
  });

  @override
  void applyParentData(RenderObject renderObject) {
    final parentData = renderObject.parentData as YogaLayoutParentData;
    bool needsLayout = false;

    if (parentData.yogaNode == null) {
      parentData.yogaNode = YogaNode();
      needsLayout = true;
    }

    final node = parentData.yogaNode!;

    if (parentData.boxSizing != boxSizing) {
      parentData.boxSizing = boxSizing;
      // boxSizing affects how width/height are applied, so we need to re-apply them
      // But width/height application logic is currently in _applyWidth/_applyHeight which are simple setters.
      // The actual box-sizing logic needs to happen in RenderYogaLayout.performLayout or here if we have enough info.
      // Since we don't have padding/border info fully resolved here (border depends on direction),
      // we should defer the calculation to RenderYogaLayout.performLayout.
      // So we just mark needsLayout.
      needsLayout = true;
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
