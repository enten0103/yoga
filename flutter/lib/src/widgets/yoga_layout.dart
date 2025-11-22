import 'package:flutter/widgets.dart';
import '../rendering/yoga_layout.dart';
import '../yoga_ffi.dart';
import '../yoga_node.dart';

class YogaLayout extends MultiChildRenderObjectWidget {
  final int flexDirection;
  final int justifyContent;
  final int alignItems;
  final int alignContent;
  final int flexWrap;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
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
      ..rootNode.width = width ?? double.nan
      ..rootNode.height = height ?? double.nan
      ..useWebDefaults = useWebDefaults
      ..enableMarginCollapsing = enableMarginCollapsing
      .._updatePadding(padding)
      .._updateBorderWidth(borderWidth);
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
      ..rootNode.width = width ?? double.nan
      ..rootNode.height = height ?? double.nan
      ..useWebDefaults = useWebDefaults
      ..enableMarginCollapsing = enableMarginCollapsing
      .._updatePadding(padding)
      .._updateBorderWidth(borderWidth);

    renderObject.markNeedsLayout();
  }
}

extension _RenderYogaLayoutPadding on RenderYogaLayout {
  void _updatePadding(EdgeInsets? padding) {
    if (padding != null) {
      rootNode.setPadding(YGEdge.left, padding.left);
      rootNode.setPadding(YGEdge.top, padding.top);
      rootNode.setPadding(YGEdge.right, padding.right);
      rootNode.setPadding(YGEdge.bottom, padding.bottom);
    } else {
      rootNode.setPadding(YGEdge.all, 0);
    }
  }

  void _updateBorderWidth(EdgeInsets? borderWidth) {
    if (borderWidth != null) {
      rootNode.setBorder(YGEdge.left, borderWidth.left);
      rootNode.setBorder(YGEdge.top, borderWidth.top);
      rootNode.setBorder(YGEdge.right, borderWidth.right);
      rootNode.setBorder(YGEdge.bottom, borderWidth.bottom);
    } else {
      rootNode.setBorder(YGEdge.all, 0);
    }
  }
}

class YogaItem extends ParentDataWidget<YogaLayoutParentData> {
  final double? flexGrow;
  final double? flexShrink;
  final double? flexBasis;
  final double? width;
  final double? height;
  final EdgeInsets? margin;
  final EdgeInsets? borderWidth;
  final int? alignSelf;

  const YogaItem({
    super.key,
    this.flexGrow,
    this.flexShrink,
    this.flexBasis,
    this.width,
    this.height,
    this.margin,
    this.borderWidth,
    this.alignSelf,
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

    if (parentData.width != width) {
      parentData.width = width;
      if (width != null) {
        node.width = width!;
      } else {
        node.setWidthAuto();
      }
      needsLayout = true;
    }

    if (parentData.height != height) {
      parentData.height = height;
      if (height != null) {
        node.height = height!;
      } else {
        node.setHeightAuto();
      }
      needsLayout = true;
    }
    if (parentData.margin != margin) {
      parentData.margin = margin;
      if (margin != null) {
        node.setMargin(YGEdge.left, margin!.left);
        node.setMargin(YGEdge.top, margin!.top);
        node.setMargin(YGEdge.right, margin!.right);
        node.setMargin(YGEdge.bottom, margin!.bottom);
      }
      needsLayout = true;
    }

    if (parentData.borderWidth != borderWidth) {
      parentData.borderWidth = borderWidth;
      if (borderWidth != null) {
        node.setBorder(YGEdge.left, borderWidth!.left);
        node.setBorder(YGEdge.top, borderWidth!.top);
        node.setBorder(YGEdge.right, borderWidth!.right);
        node.setBorder(YGEdge.bottom, borderWidth!.bottom);
      } else {
        node.setBorder(YGEdge.all, 0);
      }
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

  @override
  Type get debugTypicalAncestorWidgetClass => YogaLayout;
}
