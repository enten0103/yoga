import 'dart:async';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_yoga/src/yoga_node.dart';
import 'package:flutter_yoga/src/yoga_value.dart';
import 'package:flutter_yoga/src/yoga_ffi.dart'; // For enums
import 'package:flutter_yoga/src/rendering/yoga_layout.dart';
import 'package:flutter_yoga/src/widgets/yoga_scroll_controller.dart';

class RenderSliverYogaLayout extends RenderSliverMultiBoxAdaptor {
  RenderSliverYogaLayout({
    required super.childManager,
    required YogaConfig config,
    bool useWebDefaults = false,
    bool enableMarginCollapsing = false,
    int flexDirection = YGFlexDirection.column,
    int alignItems = YGAlign.stretch,
    int justifyContent = YGJustify.flexStart,
    ScrollController? controller,
  }) : _useWebDefaults = useWebDefaults,
       _enableMarginCollapsing = enableMarginCollapsing,
       _flexDirection = flexDirection,
       _alignItems = alignItems,
       _justifyContent = justifyContent {
    this.controller = controller;
  }

  bool _useWebDefaults;
  bool _enableMarginCollapsing;
  int _flexDirection;
  int _alignItems;
  int _justifyContent;
  ScrollController? _controller;

  // For scrollToIndex
  int? _targetIndexToMeasure;
  Completer<double>? _measureCompleter;

  set controller(ScrollController? value) {
    if (_controller == value) return;
    if (_controller is YogaScrollController) {
      (_controller as YogaScrollController).detachRenderSliver();
    }
    _controller = value;
    if (_controller is YogaScrollController) {
      (_controller as YogaScrollController).attachRenderSliver(this);
    }
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    if (_controller is YogaScrollController) {
      (_controller as YogaScrollController).attachRenderSliver(this);
    }
  }

  @override
  void detach() {
    if (_controller is YogaScrollController) {
      (_controller as YogaScrollController).detachRenderSliver();
    }
    super.detach();
  }

  set useWebDefaults(bool value) {
    if (_useWebDefaults == value) return;
    _useWebDefaults = value;
    markNeedsLayout();
  }

  set enableMarginCollapsing(bool value) {
    if (_enableMarginCollapsing == value) return;
    _enableMarginCollapsing = value;
    markNeedsLayout();
  }

  set flexDirection(int value) {
    if (_flexDirection == value) return;
    _flexDirection = value;
    markNeedsLayout();
  }

  set alignItems(int value) {
    if (_alignItems == value) return;
    _alignItems = value;
    markNeedsLayout();
  }

  set justifyContent(int value) {
    if (_justifyContent == value) return;
    _justifyContent = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! YogaSliverLayoutParentData) {
      // print('Setting up parent data for ${child.runtimeType}');
      child.parentData = YogaSliverLayoutParentData();
    } else {
      // print('Parent data already set for ${child.runtimeType}');
    }
  }

  @override
  void performLayout() {
    final SliverConstraints constraints = this.constraints;
    childManager.didStartLayout();
    childManager.setDidUnderflow(false);

    final double scrollOffset =
        constraints.scrollOffset + constraints.cacheOrigin;
    final double remainingExtent = constraints.remainingCacheExtent;
    final double targetEndScrollOffset = scrollOffset + remainingExtent;

    final bool isVertical =
        _flexDirection == YGFlexDirection.column ||
        _flexDirection == YGFlexDirection.columnReverse;

    final double crossAxisExtent = constraints.crossAxisExtent;

    if (firstChild == null) {
      if (!addInitialChild()) {
        geometry = SliverGeometry.zero;
        childManager.didFinishLayout();
        return;
      }
    }

    RenderBox? child = firstChild;
    double currentOffset = 0.0;
    double previousMarginEnd = 0.0;
    int firstIndex = 0;
    int lastIndex = 0;

    if (child != null) {
      firstIndex = indexOf(child);
      lastIndex = firstIndex;

      // Initialize currentOffset from existing layoutOffset
      final YogaSliverLayoutParentData pd =
          child.parentData as YogaSliverLayoutParentData;
      if (pd.layoutOffset != null) {
        double marginStart = _getMarginStart(child, isVertical);
        currentOffset = pd.layoutOffset! - marginStart;
      }
    }

    // Prepend children if needed
    while (child != null && currentOffset > scrollOffset && firstIndex > 0) {
      BoxConstraints placeholderConstraints;
      if (isVertical) {
        placeholderConstraints = BoxConstraints(maxWidth: crossAxisExtent);
      } else {
        placeholderConstraints = BoxConstraints(maxHeight: crossAxisExtent);
      }
      RenderBox? prev = insertAndLayoutLeadingChild(placeholderConstraints);
      if (prev == null) break;

      _layoutChild(prev, constraints, isVertical, crossAxisExtent);

      double childLayoutOffset =
          (child.parentData as YogaSliverLayoutParentData).layoutOffset!;
      double childMarginStart = _getMarginStart(child, isVertical);

      double prevMarginEnd = _getMarginEnd(prev, isVertical);
      double prevMarginStart = _getMarginStart(prev, isVertical);
      double prevMainExtent = isVertical ? prev.size.height : prev.size.width;

      double prevLayoutOffset;
      if (_enableMarginCollapsing) {
        double collapsedMargin = (prevMarginEnd > childMarginStart)
            ? prevMarginEnd
            : childMarginStart;
        prevLayoutOffset = childLayoutOffset - prevMainExtent - collapsedMargin;
      } else {
        prevLayoutOffset =
            childLayoutOffset -
            childMarginStart -
            prevMarginEnd -
            prevMainExtent;
      }

      final YogaSliverLayoutParentData prevPd =
          prev.parentData as YogaSliverLayoutParentData;
      prevPd.layoutOffset = prevLayoutOffset;

      currentOffset = prevLayoutOffset - prevMarginStart;

      child = prev;
      firstIndex--;
    }

    // Collect leading garbage
    int leadingGarbage = 0;
    RenderBox? current = firstChild;
    while (current != null) {
      // We must layout the child before accessing its size to check if it's off-screen
      _layoutChild(current, constraints, isVertical, crossAxisExtent);

      final YogaSliverLayoutParentData pd =
          current.parentData as YogaSliverLayoutParentData;

      if (pd.layoutOffset == null) {
        break;
      }

      double itemEnd =
          pd.layoutOffset! +
          (isVertical ? current.size.height : current.size.width) +
          _getMarginEnd(current, isVertical);

      if (itemEnd <= scrollOffset) {
        leadingGarbage++;
        current = childAfter(current);
      } else {
        break;
      }
    }

    if (leadingGarbage > 0) {
      collectGarbage(leadingGarbage, 0);
      child = firstChild;
      if (child != null) {
        firstIndex = indexOf(child);
      }
    }

    while (child != null) {
      _layoutChild(child, constraints, isVertical, crossAxisExtent);
      lastIndex = indexOf(child);

      // If this is the first child after garbage collection, we trust its position
      if (leadingGarbage > 0 && child == firstChild) {
        final YogaSliverLayoutParentData pd =
            child.parentData as YogaSliverLayoutParentData;
        double childMainExtent = isVertical
            ? child.size.height
            : child.size.width;
        double marginEnd = _getMarginEnd(child, isVertical);
        currentOffset = pd.layoutOffset! + childMainExtent + marginEnd;
      } else {
        currentOffset = _calculateChildLayoutOffset(
          child,
          currentOffset,
          isVertical,
          crossAxisExtent,
          previousMarginEnd: previousMarginEnd,
        );
      }

      previousMarginEnd = _getMarginEnd(child, isVertical);

      // Check if we found the target index
      if (_targetIndexToMeasure != null &&
          indexOf(child) == _targetIndexToMeasure) {
        final YogaSliverLayoutParentData pd =
            child.parentData as YogaSliverLayoutParentData;
        final double offset = pd.layoutOffset!;
        if (_measureCompleter != null && !_measureCompleter!.isCompleted) {
          _measureCompleter!.complete(offset);
        }
        _targetIndexToMeasure = null;
        _measureCompleter = null;
      }

      // Break if we are past the visible area AND we are not measuring a specific index
      // OR if we are measuring but we passed the index (should be caught above, but for safety)
      if (currentOffset > targetEndScrollOffset &&
          _targetIndexToMeasure == null) {
        break;
      }

      RenderBox? nextChild = childAfter(child);
      if (nextChild == null) {
        BoxConstraints placeholderConstraints;
        if (isVertical) {
          placeholderConstraints = BoxConstraints(maxWidth: crossAxisExtent);
        } else {
          placeholderConstraints = BoxConstraints(maxHeight: crossAxisExtent);
        }
        nextChild = insertAndLayoutChild(placeholderConstraints, after: child);
        if (nextChild != null) {
          _layoutChild(nextChild, constraints, isVertical, crossAxisExtent);
        }
      }
      child = nextChild;
    }

    // Collect trailing garbage
    int trailingGarbage = 0;
    RenderBox? lastChild = child;
    if (lastChild != null) {
      // Check if there are children after the last one we laid out
      RenderBox? next =
          (lastChild.parentData as YogaSliverLayoutParentData).nextSibling;
      while (next != null) {
        trailingGarbage++;
        next = (next.parentData as YogaSliverLayoutParentData).nextSibling;
      }
    }

    collectGarbage(0, trailingGarbage);

    final double mainAxisExtent = currentOffset;

    // Check for underflow
    if (child == null && mainAxisExtent < targetEndScrollOffset) {
      childManager.setDidUnderflow(true);
    }

    final double paintExtent = calculatePaintOffset(
      constraints,
      from: 0.0,
      to: mainAxisExtent,
    );

    final double cacheExtent = calculateCacheOffset(
      constraints,
      from: 0.0,
      to: mainAxisExtent,
    );

    final double estimatedMaxScrollOffset = childManager
        .estimateMaxScrollOffset(
          constraints,
          firstIndex: firstIndex,
          lastIndex: lastIndex,
          leadingScrollOffset: (firstChild != null)
              ? (firstChild!.parentData as YogaSliverLayoutParentData)
                        .layoutOffset ??
                    0.0
              : 0.0,
          trailingScrollOffset: mainAxisExtent,
        );

    geometry = SliverGeometry(
      scrollExtent: estimatedMaxScrollOffset,
      paintExtent: paintExtent,
      cacheExtent: cacheExtent,
      maxPaintExtent: estimatedMaxScrollOffset,
      hasVisualOverflow:
          mainAxisExtent > constraints.remainingPaintExtent ||
          constraints.scrollOffset > 0.0,
    );

    childManager.didFinishLayout();
  }

  void _layoutChild(
    RenderBox child,
    SliverConstraints constraints,
    bool isVertical,
    double crossAxisExtent,
  ) {
    final YogaSliverLayoutParentData pd =
        child.parentData as YogaSliverLayoutParentData;

    double marginTop = 0;
    double marginBottom = 0;
    double marginLeft = 0;
    double marginRight = 0;

    YogaValue? childWidth = pd.width;
    YogaValue? childHeight = pd.height;

    if (child is RenderYogaLayout) {
      if (child.width != null) childWidth = child.width;
      if (child.height != null) childHeight = child.height;
    }

    if (pd.margin != null) {
      if (pd.margin!.top.unit == YogaUnit.point) {
        marginTop = pd.margin!.top.value;
      }
      if (pd.margin!.bottom.unit == YogaUnit.point) {
        marginBottom = pd.margin!.bottom.value;
      }
      if (pd.margin!.left.unit == YogaUnit.point) {
        marginLeft = pd.margin!.left.value;
      }
      if (pd.margin!.right.unit == YogaUnit.point) {
        marginRight = pd.margin!.right.value;
      }
    }

    double childCrossAxisAvailable =
        crossAxisExtent -
        (isVertical ? (marginLeft + marginRight) : (marginTop + marginBottom));
    if (childCrossAxisAvailable < 0) childCrossAxisAvailable = 0;

    double? explicitWidth;
    double? explicitHeight;

    if (childWidth != null) {
      if (childWidth.unit == YogaUnit.point) {
        explicitWidth = childWidth.value;
      } else if (childWidth.unit == YogaUnit.percent) {
        explicitWidth = (childWidth.value / 100.0) * crossAxisExtent;
      }
    }
    if (childHeight != null) {
      if (childHeight.unit == YogaUnit.point) {
        explicitHeight = childHeight.value;
      } else if (childHeight.unit == YogaUnit.percent) {
        // For height in vertical scroll, percent usually doesn't work unless container has height.
        // But for horizontal scroll (cross axis), it might work.
        if (!isVertical) {
          explicitHeight = (childHeight.value / 100.0) * crossAxisExtent;
        }
      }
    }

    if (pd.flexBasis != null && !pd.flexBasis!.isNaN) {
      if (isVertical) {
        explicitHeight = pd.flexBasis;
      } else {
        explicitWidth = pd.flexBasis;
      }
    }

    BoxConstraints childConstraints;
    if (isVertical) {
      double minW = _alignItems == YGAlign.stretch
          ? childCrossAxisAvailable
          : 0.0;
      double maxW = childCrossAxisAvailable;

      if (explicitWidth != null) {
        minW = explicitWidth;
        maxW = explicitWidth;
      }

      double minH = 0.0;
      double maxH = double.infinity;
      if (explicitHeight != null) {
        minH = explicitHeight;
        maxH = explicitHeight;
      }

      childConstraints = BoxConstraints(
        minWidth: minW,
        maxWidth: maxW,
        minHeight: minH,
        maxHeight: maxH,
      );
    } else {
      double minH = _alignItems == YGAlign.stretch
          ? childCrossAxisAvailable
          : 0.0;
      double maxH = childCrossAxisAvailable;

      if (explicitHeight != null) {
        minH = explicitHeight;
        maxH = explicitHeight;
      }

      double minW = 0.0;
      double maxW = double.infinity;
      if (explicitWidth != null) {
        minW = explicitWidth;
        maxW = explicitWidth;
      }

      childConstraints = BoxConstraints(
        minWidth: minW,
        maxWidth: maxW,
        minHeight: minH,
        maxHeight: maxH,
      );
    }

    child.layout(childConstraints, parentUsesSize: true);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (firstChild == null) return;

    final bool isVertical =
        _flexDirection == YGFlexDirection.column ||
        _flexDirection == YGFlexDirection.columnReverse;

    RenderBox? child = firstChild;
    while (child != null) {
      final YogaSliverLayoutParentData childParentData =
          child.parentData as YogaSliverLayoutParentData;

      if (childParentData.offset != null) {
        Offset childPaintOffset;
        if (isVertical) {
          childPaintOffset =
              childParentData.offset! - Offset(0, constraints.scrollOffset);
        } else {
          childPaintOffset =
              childParentData.offset! - Offset(constraints.scrollOffset, 0);
        }
        context.paintChild(child, offset + childPaintOffset);
      }

      child = childParentData.nextSibling;
    }
  }

  @override
  bool hitTestChildren(
    SliverHitTestResult result, {
    required double mainAxisPosition,
    required double crossAxisPosition,
  }) {
    RenderBox? child = lastChild;
    final BoxHitTestResult boxResult = BoxHitTestResult.wrap(result);
    while (child != null) {
      if (hitTestBoxChild(
        boxResult,
        child,
        mainAxisPosition: mainAxisPosition,
        crossAxisPosition: crossAxisPosition,
      )) {
        return true;
      }
      child = childBefore(child);
    }
    return false;
  }

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {
    final YogaSliverLayoutParentData pd =
        child.parentData as YogaSliverLayoutParentData;
    final double scrollOffset = constraints.scrollOffset;
    final bool isVertical =
        _flexDirection == YGFlexDirection.column ||
        _flexDirection == YGFlexDirection.columnReverse;

    if (isVertical) {
      if (pd.offset != null) {
        // ignore: deprecated_member_use
        transform.translate(pd.offset!.dx, pd.offset!.dy - scrollOffset, 0.0);
      }
    } else {
      if (pd.offset != null) {
        // ignore: deprecated_member_use
        transform.translate(pd.offset!.dx - scrollOffset, pd.offset!.dy, 0.0);
      }
    }
  }

  @override
  double childCrossAxisPosition(RenderBox child) {
    final YogaSliverLayoutParentData pd =
        child.parentData as YogaSliverLayoutParentData;
    final bool isVertical =
        _flexDirection == YGFlexDirection.column ||
        _flexDirection == YGFlexDirection.columnReverse;
    if (pd.offset != null) {
      return isVertical ? pd.offset!.dx : pd.offset!.dy;
    }
    return 0.0;
  }

  Future<double> measureOffsetForIndex(int index) {
    if (_measureCompleter != null) {
      // Cancel previous measurement? Or chain?
      // For simplicity, we just return the new one.
    }
    _measureCompleter = Completer<double>();
    _targetIndexToMeasure = index;
    markNeedsLayout();
    return _measureCompleter!.future;
  }

  double _getMarginEnd(RenderBox child, bool isVertical) {
    final YogaSliverLayoutParentData pd =
        child.parentData as YogaSliverLayoutParentData;
    if (pd.margin == null) return 0.0;
    if (isVertical) {
      return (pd.margin!.bottom.unit == YogaUnit.point)
          ? pd.margin!.bottom.value
          : 0.0;
    } else {
      return (pd.margin!.right.unit == YogaUnit.point)
          ? pd.margin!.right.value
          : 0.0;
    }
  }

  double _getMarginStart(RenderBox child, bool isVertical) {
    final YogaSliverLayoutParentData pd =
        child.parentData as YogaSliverLayoutParentData;
    if (pd.margin == null) return 0.0;
    if (isVertical) {
      return (pd.margin!.top.unit == YogaUnit.point)
          ? pd.margin!.top.value
          : 0.0;
    } else {
      return (pd.margin!.left.unit == YogaUnit.point)
          ? pd.margin!.left.value
          : 0.0;
    }
  }

  double _calculateChildLayoutOffset(
    RenderBox child,
    double currentOffset,
    bool isVertical,
    double crossAxisExtent, {
    double previousMarginEnd = 0.0,
  }) {
    final YogaSliverLayoutParentData pd =
        child.parentData as YogaSliverLayoutParentData;

    double marginTop = 0;
    double marginBottom = 0;
    double marginLeft = 0;
    double marginRight = 0;

    if (pd.margin != null) {
      if (pd.margin!.top.unit == YogaUnit.point) {
        marginTop = pd.margin!.top.value;
      }
      if (pd.margin!.bottom.unit == YogaUnit.point) {
        marginBottom = pd.margin!.bottom.value;
      }
      if (pd.margin!.left.unit == YogaUnit.point) {
        marginLeft = pd.margin!.left.value;
      }
      if (pd.margin!.right.unit == YogaUnit.point) {
        marginRight = pd.margin!.right.value;
      }
    }

    final double childMainExtent = isVertical
        ? child.size.height
        : child.size.width;
    final double childCrossExtent = isVertical
        ? child.size.width
        : child.size.height;

    double childCrossAxisAvailable =
        crossAxisExtent -
        (isVertical ? (marginLeft + marginRight) : (marginTop + marginBottom));
    if (childCrossAxisAvailable < 0) childCrossAxisAvailable = 0;

    double marginStart = isVertical ? marginTop : marginLeft;
    double marginEnd = isVertical ? marginBottom : marginRight;

    double childMainPosition;

    if (_enableMarginCollapsing) {
      // currentOffset is the end of previous margin box.
      // We want to position relative to previous border box.
      double prevBorderBoxEnd = currentOffset - previousMarginEnd;
      double collapsedMargin = (previousMarginEnd > marginStart)
          ? previousMarginEnd
          : marginStart;
      childMainPosition = prevBorderBoxEnd + collapsedMargin;
    } else {
      childMainPosition = currentOffset + marginStart;
    }

    double childCrossPosition = 0.0;
    if (_alignItems == YGAlign.center) {
      childCrossPosition = (childCrossAxisAvailable - childCrossExtent) / 2.0;
      childCrossPosition += isVertical ? marginLeft : marginTop;
    } else if (_alignItems == YGAlign.flexEnd) {
      childCrossPosition = childCrossAxisAvailable - childCrossExtent;
      childCrossPosition += isVertical ? marginLeft : marginTop;
    } else {
      childCrossPosition = isVertical ? marginLeft : marginTop;
    }

    if (isVertical) {
      pd.layoutOffset = childMainPosition;
      pd.offset = Offset(childCrossPosition, childMainPosition);
    } else {
      pd.layoutOffset = childMainPosition;
      pd.offset = Offset(childMainPosition, childCrossPosition);
    }

    return childMainPosition + childMainExtent + marginEnd;
  }
}
