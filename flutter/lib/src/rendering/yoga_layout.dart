import 'dart:math' as math;
import 'package:flutter/rendering.dart';
import '../yoga_ffi.dart';
import '../yoga_node.dart';
import '../yoga_value.dart';

class YogaLayoutParentData extends ContainerBoxParentData<RenderBox> {
  YogaNode? yogaNode;

  // Cache for diffing
  double? flexGrow;
  double? flexShrink;
  double? flexBasis;
  YogaDisplay? display;
  YogaValue? width;
  YogaValue? height;
  YogaEdgeInsets? margin;
  EdgeInsets? borderWidth;
  int? alignSelf;
  List<YogaBoxShadow>? boxShadow;

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
  YogaEdgeInsets? _padding;
  EdgeInsets _borderWidth = EdgeInsets.zero;
  YogaValue? _width;
  YogaValue? _height;

  RenderYogaLayout() {
    _config = YogaConfig();
    _rootNode = YogaNode();
    _rootNode.setConfig(_config);
  }

  YogaNode get rootNode => _rootNode;

  set width(YogaValue? value) {
    if (_width != value) {
      _width = value;
      markNeedsLayout();
    }
  }

  set height(YogaValue? value) {
    if (_height != value) {
      _height = value;
      markNeedsLayout();
    }
  }

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

  set padding(YogaEdgeInsets? value) {
    _padding = value;
    _applyPadding(_rootNode, value);
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
    if (_width != null) {
      _applyWidth(_rootNode, _width!);
    } else if (constraints.hasBoundedWidth) {
      _rootNode.width = constraints.maxWidth;
    } else {
      _rootNode.setWidthAuto();
    }

    if (_height != null) {
      _applyHeight(_rootNode, _height!);
    } else if (constraints.hasBoundedHeight) {
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
      // Note: We must NOT overwrite width/height if width/height is set (unless it's auto).

      bool widthIsSet =
          childParentData.width != null &&
          childParentData.width!.unit != YogaUnit.auto &&
          childParentData.width!.unit != YogaUnit.undefined;
      bool heightIsSet =
          childParentData.height != null &&
          childParentData.height!.unit != YogaUnit.auto &&
          childParentData.height!.unit != YogaUnit.undefined;

      if (!widthIsSet || !heightIsSet) {
        final Size childSize = child.getDryLayout(const BoxConstraints());
        if (!widthIsSet) {
          childNode.width = childSize.width.ceilToDouble();
        }
        if (!heightIsSet) {
          childNode.height = childSize.height.ceilToDouble();
        }
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
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    RenderBox? child = firstChild;
    while (child != null) {
      final childParentData = child.parentData as YogaLayoutParentData;

      // Paint shadow
      if (childParentData.boxShadow != null) {
        _paintShadows(
          context,
          offset + childParentData.offset,
          child.size,
          childParentData.boxShadow!,
        );
      }

      // Paint child
      context.paintChild(child, childParentData.offset + offset);

      child = childParentData.nextSibling;
    }
  }

  void _paintShadows(
    PaintingContext context,
    Offset offset,
    Size size,
    List<YogaBoxShadow> shadows,
  ) {
    for (int i = shadows.length - 1; i >= 0; i--) {
      final shadow = shadows[i];
      final Paint paint = Paint()
        ..color = shadow.color
        ..maskFilter = MaskFilter.blur(
          shadow.blurStyle,
          _resolveValue(shadow.blurRadius, size.width),
        );

      final double dx = _resolveValue(shadow.offsetDX, size.width);
      final double dy = _resolveValue(shadow.offsetDY, size.height);
      final double spread = _resolveValue(shadow.spreadRadius, size.width);

      final Rect rect = (offset & size).inflate(spread).shift(Offset(dx, dy));

      // We assume rectangular shadow for now as YogaItem doesn't know about borderRadius.
      // If we want rounded shadows, we need to add borderRadius to YogaItem.
      context.canvas.drawRect(rect, paint);
    }
  }

  double _resolveValue(YogaValue value, double base) {
    switch (value.unit) {
      case YogaUnit.point:
        return value.value;
      case YogaUnit.percent:
        return value.value * base / 100.0;
      case YogaUnit.auto:
      case YogaUnit.undefined:
        return 0;
    }
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

  void _resetMargins(YogaNode node, YogaEdgeInsets? margin) {
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
    // Convert YogaEdgeInsets to EdgeInsets for calculation if possible
    // Note: We can only collapse point values in Dart.
    // If margin is percent, we can't easily collapse it here without knowing parent width.
    // So we fallback to 0 or whatever is safe.

    // If effectiveMargin is set, use it.
    if (pd.effectiveMargin != null) return pd.effectiveMargin!;

    // Otherwise convert pd.margin
    final margin = pd.margin;
    if (margin == null) return EdgeInsets.zero;

    return EdgeInsets.only(
      left: margin.left.unit == YogaUnit.point ? margin.left.value : 0,
      top: margin.top.unit == YogaUnit.point ? margin.top.value : 0,
      right: margin.right.unit == YogaUnit.point ? margin.right.value : 0,
      bottom: margin.bottom.unit == YogaUnit.point ? margin.bottom.value : 0,
    );
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

        // Skip collapsing if either margin is percentage-based
        if ((childParentData.margin?.bottom.unit == YogaUnit.percent) ||
            (nextParentData.margin?.top.unit == YogaUnit.percent)) {
          child = nextChild;
          continue;
        }

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
    if (_isZero(_padding?.top) && _borderWidth.top == 0) {
      final firstChild = this.firstChild;
      if (firstChild != null) {
        final childParentData = firstChild.parentData as YogaLayoutParentData;
        final childNode = childParentData.yogaNode!;

        // Skip if child has percentage top margin
        if (childParentData.margin?.top.unit == YogaUnit.percent) {
          // Do nothing
        } else {
          // My top margin
          double myMarginTop = 0.0;
          bool myMarginIsPercent = false;
          if (parentData is YogaLayoutParentData) {
            final pd = parentData as YogaLayoutParentData;
            myMarginTop = _getEffectiveMargin(pd).top;
            if (pd.margin?.top.unit == YogaUnit.percent) {
              myMarginIsPercent = true;
            }
          }

          if (!myMarginIsPercent) {
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
      }
    }

    // Bottom Collapsing
    if (!constraints.hasBoundedHeight &&
        _isZero(_padding?.bottom) &&
        _borderWidth.bottom == 0) {
      final lastChild = this.lastChild;
      if (lastChild != null) {
        final childParentData = lastChild.parentData as YogaLayoutParentData;
        final childNode = childParentData.yogaNode!;

        // Skip if child has percentage bottom margin
        if (childParentData.margin?.bottom.unit == YogaUnit.percent) {
          // Do nothing
        } else {
          double myMarginBottom = 0.0;
          bool myMarginIsPercent = false;
          if (parentData is YogaLayoutParentData) {
            final pd = parentData as YogaLayoutParentData;
            myMarginBottom = _getEffectiveMargin(pd).bottom;
            if (pd.margin?.bottom.unit == YogaUnit.percent) {
              myMarginIsPercent = true;
            }
          }

          if (!myMarginIsPercent) {
            final childMarginBottom = _getEffectiveMargin(
              childParentData,
            ).bottom;

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
    }
  }

  void _applyPadding(YogaNode node, YogaEdgeInsets? padding) {
    _setPaddingEdge(node, YGEdge.left, padding?.left);
    _setPaddingEdge(node, YGEdge.top, padding?.top);
    _setPaddingEdge(node, YGEdge.right, padding?.right);
    _setPaddingEdge(node, YGEdge.bottom, padding?.bottom);
  }

  void _setPaddingEdge(YogaNode node, int edge, YogaValue? value) {
    if (value == null) {
      node.setPadding(edge, 0);
      return;
    }
    switch (value.unit) {
      case YogaUnit.point:
        node.setPadding(edge, value.value);
        break;
      case YogaUnit.percent:
        node.setPaddingPercent(edge, value.value);
        break;
      case YogaUnit.auto:
        // Padding auto is not really a thing in CSS/Yoga usually, treats as 0?
        // Yoga doesn't have setPaddingAuto.
        node.setPadding(edge, 0);
        break;
      case YogaUnit.undefined:
        node.setPadding(edge, 0);
        break;
    }
  }

  bool _isZero(YogaValue? value) {
    if (value == null) return true;
    if (value.unit == YogaUnit.point && value.value == 0) return true;
    if (value.unit == YogaUnit.percent && value.value == 0) return true;
    return false;
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
