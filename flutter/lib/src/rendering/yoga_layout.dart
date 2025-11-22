import 'dart:math' as math;
import 'package:flutter/rendering.dart';
import '../yoga_ffi.dart';
import '../yoga_node.dart';

class YogaLayoutParentData extends ContainerBoxParentData<RenderBox> {
  YogaNode? yogaNode;

  // Cache for diffing
  double? flexGrow;
  double? flexShrink;
  double? flexBasis;
  double? width;
  double? height;
  EdgeInsets? margin;
  EdgeInsets? borderWidth;
  int? alignSelf;

  @override
  String toString() => '${super.toString()}; yogaNode=$yogaNode';
}

class RenderYogaLayout extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, YogaLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, YogaLayoutParentData> {
  late final YogaNode _rootNode;
  late final YogaConfig _config;
  bool _enableMarginCollapsing = false;

  RenderYogaLayout() {
    _config = YogaConfig();
    _rootNode = YogaNode();
    _rootNode.setConfig(_config);
  }

  YogaNode get rootNode => _rootNode;

  set useWebDefaults(bool value) {
    _config.useWebDefaults = value;
    markNeedsLayout();
  }

  set enableMarginCollapsing(bool value) {
    if (_enableMarginCollapsing != value) {
      _enableMarginCollapsing = value;
      markNeedsLayout();
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! YogaLayoutParentData) {
      child.parentData = YogaLayoutParentData();
    }
  }

  @override
  void dispose() {
    _rootNode.dispose(recursive: false);
    _config.dispose();
    super.dispose();
  }

  @override
  void performLayout() {
    // 1. Sync Root Constraints
    if (constraints.hasBoundedWidth) {
      _rootNode.width = constraints.maxWidth;
    } else {
      _rootNode.setWidthAuto();
    }

    if (constraints.hasBoundedHeight) {
      _rootNode.height = constraints.maxHeight;
    } else {
      _rootNode.setHeightAuto();
    }

    // 2. Sync Children
    // We assume the children list in RenderYogaLayout matches the children in YogaNode.
    // However, since we are using a MultiChildRenderObjectWidget, the children are
    // inserted/removed via insert/remove/move methods.
    // We need to ensure the YogaNode tree is in sync.
    // The easiest way is to rebuild the children list of the root node here,
    // or maintain it incrementally.
    // Let's rebuild it for simplicity in this version, or check if we can trust the order.

    _rootNode.removeAllChildren();

    RenderBox? child = firstChild;
    while (child != null) {
      final childParentData = child.parentData as YogaLayoutParentData;

      // Ensure child has a YogaNode
      childParentData.yogaNode ??= YogaNode();

      final childNode = childParentData.yogaNode!;
      childNode.setConfig(_config);

      // Reset margins to what the user specified in YogaItem
      // This is crucial because we might have modified them in the previous layout pass
      _resetMargins(childNode, childParentData.margin);

      // If the child is a RenderYogaLayout (nested), we might want to let it handle its own layout?
      // But generally, we treat children as black boxes unless they are also Yoga nodes we want to merge?
      // For now, treat all children as leaf nodes or nested roots.

      // We need to measure the child.
      // Since we don't have a complex measure callback setup yet,
      // we will use a simplified approach:
      // If the child has intrinsic size (like Text), we need to measure it.
      // If the child is flexible, Yoga handles it.

      // CRITICAL: How to measure Flutter children from Yoga?
      // We will set a measure function on the childNode.
      // But passing the callback is hard.

      // ALTERNATIVE:
      // We can't easily pass a callback that calls `child.getDryLayout`.
      // So we will try to infer size.
      // If we don't set a measure function, Yoga assumes the node has no content size
      // unless we set width/height.

      // If the user didn't specify an explicit size, we try to measure the child's content size
      // and set it on the Yoga node. This is a simplified "Auto" sizing.
      // We use ceilToDouble() to avoid sub-pixel clipping issues when converting between
      // Flutter's double precision and Yoga's float precision.
      if (childParentData.width == null) {
        final Size childSize = child.getDryLayout(const BoxConstraints());
        childNode.width = childSize.width.ceilToDouble();
      }

      if (childParentData.height == null) {
        final Size childSize = child.getDryLayout(const BoxConstraints());
        childNode.height = childSize.height.ceilToDouble();
      }

      _rootNode.addChild(childNode);

      child = childParentData.nextSibling;
    }

    if (_enableMarginCollapsing) {
      _applyMarginCollapsing();
    }

    // 3. Calculate Layout
    _rootNode.calculateLayout(
      availableWidth: constraints.hasBoundedWidth
          ? constraints.maxWidth
          : double.nan,
      availableHeight: constraints.hasBoundedHeight
          ? constraints.maxHeight
          : double.nan,
    );

    // 4. Apply Layout to Children
    child = firstChild;
    while (child != null) {
      final childParentData = child.parentData as YogaLayoutParentData;
      final childNode = childParentData.yogaNode!;

      final double x = childNode.left;
      final double y = childNode.top;
      final double w = childNode.layoutWidth;
      final double h = childNode.layoutHeight;

      // Yoga might return NaN if something went wrong or if dimensions are undefined.
      // We must ensure we pass valid constraints to Flutter.
      final double safeW = w.isNaN ? 0.0 : w;
      final double safeH = h.isNaN ? 0.0 : h;

      // We must layout the child with exact constraints given by Yoga
      child.layout(
        BoxConstraints.tightFor(width: safeW, height: safeH),
        parentUsesSize: true,
      );
      childParentData.offset = Offset(x, y);

      child = childParentData.nextSibling;
    }

    final double rootW = _rootNode.layoutWidth;
    final double rootH = _rootNode.layoutHeight;

    size = constraints.constrain(
      Size(rootW.isNaN ? 0.0 : rootW, rootH.isNaN ? 0.0 : rootH),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  void _resetMargins(YogaNode node, EdgeInsets? margin) {
    if (margin != null) {
      node.setMargin(YGEdge.left, margin.left);
      node.setMargin(YGEdge.top, margin.top);
      node.setMargin(YGEdge.right, margin.right);
      node.setMargin(YGEdge.bottom, margin.bottom);
    } else {
      node.setMargin(YGEdge.all, 0);
    }
  }

  void _applyMarginCollapsing() {
    // Margin collapsing only applies to vertical flow (column/column-reverse)
    // and when flexWrap is noWrap (usually).
    // For simplicity, we only support column direction for now.
    final flexDirection = _rootNode.flexDirection;
    if (flexDirection != YGFlexDirection.column) {
      return;
    }

    RenderBox? child = firstChild;
    while (child != null) {
      final childParentData = child.parentData as YogaLayoutParentData;
      final nextChild = childParentData.nextSibling;

      if (nextChild != null) {
        final nextParentData = nextChild.parentData as YogaLayoutParentData;

        final childNode = childParentData.yogaNode!;
        final nextNode = nextParentData.yogaNode!;

        // Get margins from ParentData (source of truth)
        final marginBottom = childParentData.margin?.bottom ?? 0.0;
        final marginTop = nextParentData.margin?.top ?? 0.0;

        // Calculate collapsed margin
        final collapsedMargin = math.max(marginBottom, marginTop);

        // Apply to nodes:
        // We set the bottom margin of the current node to the collapsed value
        // and the top margin of the next node to 0.
        childNode.setMargin(YGEdge.bottom, collapsedMargin);
        nextNode.setMargin(YGEdge.top, 0);
      }

      child = nextChild;
    }
  }
}
