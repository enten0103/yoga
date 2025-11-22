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
  YogaDisplay? display;
  double? width;
  double? widthPercent;
  double? height;
  double? heightPercent;
  EdgeInsets? margin;
  EdgeInsets? borderWidth;
  int? alignSelf;

  // Effective margin after collapsing (runtime only, not set by user)
  EdgeInsets? effectiveMargin;

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
  EdgeInsets _padding = EdgeInsets.zero;
  EdgeInsets _borderWidth = EdgeInsets.zero;

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

  set padding(EdgeInsets? value) {
    _padding = value ?? EdgeInsets.zero;
    if (value != null) {
      _rootNode.setPadding(YGEdge.left, value.left);
      _rootNode.setPadding(YGEdge.top, value.top);
      _rootNode.setPadding(YGEdge.right, value.right);
      _rootNode.setPadding(YGEdge.bottom, value.bottom);
    } else {
      _rootNode.setPadding(YGEdge.all, 0);
    }
    markNeedsLayout();
  }

  set borderWidth(EdgeInsets? value) {
    _borderWidth = value ?? EdgeInsets.zero;
    if (value != null) {
      _rootNode.setBorder(YGEdge.left, value.left);
      _rootNode.setBorder(YGEdge.top, value.top);
      _rootNode.setBorder(YGEdge.right, value.right);
      _rootNode.setBorder(YGEdge.bottom, value.bottom);
    } else {
      _rootNode.setBorder(YGEdge.all, 0);
    }
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! YogaLayoutParentData) {
      child.parentData = YogaLayoutParentData();
    }
  }

  @override
  void insert(RenderBox child, {RenderBox? after}) {
    super.insert(child, after: after);
    final childParentData = child.parentData as YogaLayoutParentData;
    childParentData.yogaNode ??= YogaNode();
    final childNode = childParentData.yogaNode!;
    childNode.setConfig(_config);

    int index = 0;
    RenderBox? current = firstChild;
    while (current != null && current != child) {
      index++;
      current = (current.parentData as YogaLayoutParentData).nextSibling;
    }
    _rootNode.insertChild(childNode, index);
  }

  @override
  void remove(RenderBox child) {
    final childParentData = child.parentData as YogaLayoutParentData;
    if (childParentData.yogaNode != null) {
      _rootNode.removeChild(childParentData.yogaNode!);
    }
    super.remove(child);
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

    // 2. Sync Children Size
    RenderBox? child = firstChild;
    while (child != null) {
      final childParentData = child.parentData as YogaLayoutParentData;
      final childNode = childParentData.yogaNode!;

      // If the user didn't specify an explicit size, we try to measure the child's content size
      // and set it on the Yoga node. This is a simplified "Auto" sizing.
      // Note: We must NOT overwrite width/height if widthPercent/heightPercent is set.
      if (childParentData.width == null && childParentData.widthPercent == null) {
        final Size childSize = child.getDryLayout(const BoxConstraints());
        childNode.width = childSize.width.ceilToDouble();
      }

      if (childParentData.height == null &&
          childParentData.heightPercent == null) {
        final Size childSize = child.getDryLayout(const BoxConstraints());
        childNode.height = childSize.height.ceilToDouble();
      }

      child = childParentData.nextSibling;
    }

    if (_enableMarginCollapsing) {
      _collapseMarginsRecursive(this);
    } else {
      // Ensure margins are reset if collapsing is disabled
      _resetMarginsRecursive(this);
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

  void _resetMarginsRecursive(RenderYogaLayout renderLayout) {
    RenderBox? child = renderLayout.firstChild;
    while (child != null) {
      final childParentData = child.parentData as YogaLayoutParentData;
      // Reset effective margin
      childParentData.effectiveMargin = null;

      if (childParentData.yogaNode != null) {
        _resetMargins(childParentData.yogaNode!, childParentData.margin);
      }

      if (child is RenderYogaLayout) {
        _resetMarginsRecursive(child);
      }
      child = childParentData.nextSibling;
    }
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

  void _collapseMarginsRecursive(RenderYogaLayout renderLayout) {
    // 1. Recurse first (Post-order traversal)
    RenderBox? child = renderLayout.firstChild;
    while (child != null) {
      final childParentData = child.parentData as YogaLayoutParentData;

      // Reset margins for this child
      childParentData.effectiveMargin = null;
      if (childParentData.yogaNode != null) {
        _resetMargins(childParentData.yogaNode!, childParentData.margin);
      }

      if (child is RenderYogaLayout) {
        _collapseMarginsRecursive(child);
      }
      child = childParentData.nextSibling;
    }

    // 2. Apply Sibling Collapsing (My children)
    renderLayout._applySiblingCollapsing();

    // 3. Apply Parent-Child Collapsing (Me and my children)
    renderLayout._applyParentChildCollapsing();
  }

  EdgeInsets _getEffectiveMargin(YogaLayoutParentData pd) {
    return pd.effectiveMargin ?? pd.margin ?? EdgeInsets.zero;
  }

  void _updateEffectiveMargin(YogaLayoutParentData pd, int edge, double value) {
    EdgeInsets current = _getEffectiveMargin(pd);
    if (edge == YGEdge.top) {
      pd.effectiveMargin = current.copyWith(top: value);
    } else if (edge == YGEdge.bottom) {
      pd.effectiveMargin = current.copyWith(bottom: value);
    }
  }

  void _applySiblingCollapsing() {
    // Margin collapsing only applies to vertical flow (column/column-reverse)
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

        // Get effective margins
        final marginBottom = _getEffectiveMargin(childParentData).bottom;
        final marginTop = _getEffectiveMargin(nextParentData).top;

        // Calculate collapsed margin
        final collapsedMargin = _collapse(marginBottom, marginTop);

        // Apply to nodes and update effective margins
        childNode.setMargin(YGEdge.bottom, collapsedMargin);
        _updateEffectiveMargin(childParentData, YGEdge.bottom, collapsedMargin);

        nextNode.setMargin(YGEdge.top, 0);
        _updateEffectiveMargin(nextParentData, YGEdge.top, 0);
      }

      child = nextChild;
    }
  }

  void _applyParentChildCollapsing() {
    final flexDirection = _rootNode.flexDirection;
    if (flexDirection != YGFlexDirection.column) {
      return;
    }

    // Top Collapsing
    if (_padding.top == 0 && _borderWidth.top == 0) {
      final firstChild = this.firstChild;
      if (firstChild != null) {
        final childParentData = firstChild.parentData as YogaLayoutParentData;
        final childNode = childParentData.yogaNode!;

        // My top margin
        double myMarginTop = 0.0;
        if (parentData is YogaLayoutParentData) {
          myMarginTop = _getEffectiveMargin(
            parentData as YogaLayoutParentData,
          ).top;
        }

        final childMarginTop = _getEffectiveMargin(childParentData).top;

        final collapsed = _collapse(myMarginTop, childMarginTop);

        _rootNode.setMargin(YGEdge.top, collapsed);
        if (parentData is YogaLayoutParentData) {
          _updateEffectiveMargin(
            parentData as YogaLayoutParentData,
            YGEdge.top,
            collapsed,
          );
        }

        childNode.setMargin(YGEdge.top, 0);
        _updateEffectiveMargin(childParentData, YGEdge.top, 0);
      }
    }

    // Bottom Collapsing
    if (!constraints.hasBoundedHeight &&
        _padding.bottom == 0 &&
        _borderWidth.bottom == 0) {
      final lastChild = this.lastChild;
      if (lastChild != null) {
        final childParentData = lastChild.parentData as YogaLayoutParentData;
        final childNode = childParentData.yogaNode!;

        double myMarginBottom = 0.0;
        if (parentData is YogaLayoutParentData) {
          myMarginBottom = _getEffectiveMargin(
            parentData as YogaLayoutParentData,
          ).bottom;
        }

        final childMarginBottom = _getEffectiveMargin(childParentData).bottom;

        final collapsed = _collapse(myMarginBottom, childMarginBottom);

        _rootNode.setMargin(YGEdge.bottom, collapsed);
        if (parentData is YogaLayoutParentData) {
          _updateEffectiveMargin(
            parentData as YogaLayoutParentData,
            YGEdge.bottom,
            collapsed,
          );
        }

        childNode.setMargin(YGEdge.bottom, 0);
        _updateEffectiveMargin(childParentData, YGEdge.bottom, 0);
      }
    }
  }

  double _collapse(double m1, double m2) {
    if (m1 >= 0 && m2 >= 0) {
      // Both positive: max
      return math.max(m1, m2);
    } else if (m1 < 0 && m2 < 0) {
      // Both negative: min (most negative)
      return math.min(m1, m2);
    } else {
      // One positive, one negative: sum
      return m1 + m2;
    }
  }
}
