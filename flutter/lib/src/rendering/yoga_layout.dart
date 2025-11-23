import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import '../yoga_ffi.dart';
import '../yoga_node.dart';
import '../yoga_value.dart';
import '../yoga_border.dart';
import '../yoga_background.dart';

class YogaLayoutParentData extends ContainerBoxParentData<RenderBox> {
  YogaNode? yogaNode;

  // Cache for diffing
  double? flexGrow;
  double? flexShrink;
  double? flexBasis;
  YogaDisplay? display;
  YogaValue? width;
  YogaValue? height;
  YogaValue? minWidth;
  YogaValue? maxWidth;
  YogaValue? minHeight;
  YogaValue? maxHeight;
  YogaEdgeInsets? margin;
  YogaBorder? border;
  YogaBoxSizing? boxSizing;
  int? alignSelf;
  List<YogaBoxShadow>? boxShadow;
  YogaOverflow? overflow;
  Matrix4? transform;
  AlignmentGeometry? transformOrigin;

  // Effective margin after collapsing (runtime only, not set by user)
  EdgeInsets? effectiveMargin;

  // Border Image Runtime Data
  ImageStream? _borderImageStream;
  ImageInfo? _borderImageInfo;
  ImageStreamListener? _borderImageListener;

  @override
  String toString() => '${super.toString()}; yogaNode=$yogaNode';

  @override
  void detach() {
    _borderImageStream?.removeListener(_borderImageListener!);
    _borderImageStream = null;
    _borderImageListener = null;
    _borderImageInfo = null;
    super.detach();
  }
}

class RenderYogaLayout extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, YogaLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, YogaLayoutParentData> {
  late final YogaNode _rootNode;
  late final YogaConfig _config;
  bool _useWebDefaults = false;
  bool _enableMarginCollapsing = false;
  YogaEdgeInsets? _padding;
  int? _justifyContent;
  int? _alignItems;
  TextAlign? _textAlign;
  EdgeInsets _borderWidth = EdgeInsets.zero;
  YogaBackground? _background;
  YogaValue? _width;

  // Background Image Runtime Data
  ImageStream? _backgroundImageStream;
  ImageInfo? _backgroundImageInfo;
  ImageStreamListener? _backgroundImageListener;

  YogaValue? _height;
  YogaValue? _minWidth;
  YogaValue? _maxWidth;
  YogaValue? _minHeight;
  YogaValue? _maxHeight;

  // YogaItem properties
  double? _flexGrow;
  double? _flexShrink;
  double? _flexBasis;
  YogaDisplay? _display;
  YogaEdgeInsets? _margin;
  YogaBorder? _border;
  int? _alignSelf;
  List<YogaBoxShadow>? _boxShadow;
  YogaBoxSizing? _boxSizing;
  YogaOverflow? _overflow;
  Matrix4? _transform;
  AlignmentGeometry? _transformOrigin;

  RenderYogaLayout() {
    _config = YogaConfig();
    _rootNode = YogaNode(_config);
  }

  YogaNode get rootNode => _rootNode;

  set background(YogaBackground? value) {
    if (_background == value) return;
    // debugPrint('YogaLayout: set background: $value');
    _background = value;
    if (value?.image != null) {
      _resolveBackgroundImage();
    } else {
      _disposeBackgroundImage();
    }
    markNeedsPaint();
  }

  void _resolveBackgroundImage() {
    final ImageProvider? imageProvider = _background?.image;
    if (imageProvider == null) {
      _disposeBackgroundImage();
      return;
    }

    // debugPrint('YogaLayout: Resolving background image: $imageProvider');

    // Note: size might be zero here if called before layout.
    // Ideally we should resolve in paint or layout if size is needed for configuration.
    // But ImageProvider usually needs configuration.
    // We can re-resolve in paint if size changes.
    final ImageConfiguration config = ImageConfiguration(
      size: hasSize ? size : Size.zero,
      textDirection: TextDirection.ltr,
    );
    final ImageStream newStream = imageProvider.resolve(config);

    if (newStream.key != _backgroundImageStream?.key) {
      // debugPrint('YogaLayout: New stream detected. Adding listener.');
      _disposeBackgroundImage();
      _backgroundImageStream = newStream;
      _backgroundImageListener = ImageStreamListener(
        (ImageInfo imageInfo, bool synchronousCall) {
          // debugPrint('YogaLayout: Image loaded: ${imageInfo.image.width}x${imageInfo.image.height} (sync: $synchronousCall)');
          _backgroundImageInfo = imageInfo;
          markNeedsPaint();
        },
        onError: (exception, stackTrace) {
          debugPrint('YogaLayout: Error loading background image: $exception');
        },
      );
      newStream.addListener(_backgroundImageListener!);
    } else {
      // debugPrint('YogaLayout: Stream key matches existing stream. Ignoring.');
    }
  }

  void _disposeBackgroundImage() {
    if (_backgroundImageStream != null) {
      _backgroundImageStream!.removeListener(_backgroundImageListener!);
      _backgroundImageStream = null;
      _backgroundImageListener = null;
      _backgroundImageInfo = null;
    }
  }

  set width(YogaValue? value) {
    if (_width != value) {
      _width = value;
      _updateParentData((pd) => pd.width = value);
      markNeedsLayout();
    }
  }

  set height(YogaValue? value) {
    if (_height != value) {
      _height = value;
      _updateParentData((pd) => pd.height = value);
      markNeedsLayout();
    }
  }

  set flexGrow(double? value) {
    if (_flexGrow != value) {
      _flexGrow = value;
      _updateParentData((pd) => pd.flexGrow = value);
    }
  }

  set flexShrink(double? value) {
    if (_flexShrink != value) {
      _flexShrink = value;
      _updateParentData((pd) => pd.flexShrink = value);
    }
  }

  set flexBasis(double? value) {
    if (_flexBasis != value) {
      _flexBasis = value;
      _updateParentData((pd) => pd.flexBasis = value);
    }
  }

  set display(YogaDisplay? value) {
    if (_display != value) {
      _display = value;
      _updateParentData((pd) => pd.display = value);
    }
  }

  set margin(YogaEdgeInsets? value) {
    if (_margin != value) {
      _margin = value;
      _updateParentData((pd) => pd.margin = value);
    }
  }

  set border(YogaBorder? value) {
    if (_border != value) {
      _border = value;
      _updateParentData((pd) => pd.border = value);

      // Apply border widths to root node so content is inset correctly
      if (value != null) {
        final resolved = value.resolve(TextDirection.ltr);
        final fb = resolved.toFlutterBorder();
        _rootNode.setBorder(YGEdge.top, fb.top.width);
        _rootNode.setBorder(YGEdge.right, fb.right.width);
        _rootNode.setBorder(YGEdge.bottom, fb.bottom.width);
        _rootNode.setBorder(YGEdge.left, fb.left.width);
      } else {
        // Fallback to borderWidth if border is null, or 0
        if (_borderWidth != EdgeInsets.zero) {
          _rootNode.setBorder(YGEdge.top, _borderWidth.top);
          _rootNode.setBorder(YGEdge.right, _borderWidth.right);
          _rootNode.setBorder(YGEdge.bottom, _borderWidth.bottom);
          _rootNode.setBorder(YGEdge.left, _borderWidth.left);
        } else {
          _rootNode.setBorder(YGEdge.all, 0);
        }
      }
      markNeedsLayout();
    }
  }

  set flexDirection(int value) {
    if (_rootNode.flexDirection != value) {
      _rootNode.flexDirection = value;
      _applyLayoutProperties();
      markNeedsLayout();
    }
  }

  set justifyContent(int? value) {
    if (_justifyContent != value) {
      _justifyContent = value;
      _applyLayoutProperties();
      markNeedsLayout();
    }
  }

  set alignItems(int? value) {
    if (_alignItems != value) {
      _alignItems = value;
      _applyLayoutProperties();
      markNeedsLayout();
    }
  }

  set textAlign(TextAlign? value) {
    if (_textAlign != value) {
      _textAlign = value;
      _applyLayoutProperties();
      markNeedsLayout();
    }
  }

  set alignSelf(int? value) {
    if (_alignSelf != value) {
      _alignSelf = value;
      _updateParentData((pd) => pd.alignSelf = value);
    }
  }

  set boxShadow(List<YogaBoxShadow>? value) {
    if (_boxShadow != value) {
      _boxShadow = value;
      _updateParentData((pd) => pd.boxShadow = value);
    }
  }

  set boxSizing(YogaBoxSizing? value) {
    if (_boxSizing != value) {
      _boxSizing = value;
      _updateParentData((pd) => pd.boxSizing = value);
    }
  }

  set overflow(YogaOverflow? value) {
    if (_overflow != value) {
      _overflow = value;
      _updateParentData((pd) => pd.overflow = value);
    }
  }

  set transform(Matrix4? value) {
    if (_transform != value) {
      _transform = value;
      _updateParentData((pd) => pd.transform = value);
    }
  }

  set transformOrigin(AlignmentGeometry? value) {
    if (_transformOrigin != value) {
      _transformOrigin = value;
      _updateParentData((pd) => pd.transformOrigin = value);
    }
  }

  set minWidth(YogaValue? value) {
    if (_minWidth != value) {
      _minWidth = value;
      _updateParentData((pd) => pd.minWidth = value);
      markNeedsLayout();
    }
  }

  set maxWidth(YogaValue? value) {
    if (_maxWidth != value) {
      _maxWidth = value;
      _updateParentData((pd) => pd.maxWidth = value);
      markNeedsLayout();
    }
  }

  set minHeight(YogaValue? value) {
    if (_minHeight != value) {
      _minHeight = value;
      _updateParentData((pd) => pd.minHeight = value);
      markNeedsLayout();
    }
  }

  set maxHeight(YogaValue? value) {
    if (_maxHeight != value) {
      _maxHeight = value;
      _updateParentData((pd) => pd.maxHeight = value);
      markNeedsLayout();
    }
  }

  void _updateParentData(void Function(YogaLayoutParentData) updater) {
    if (parentData is YogaLayoutParentData) {
      updater(parentData as YogaLayoutParentData);
      if (parent != null) {
        parent!.markNeedsLayout();
      }
    }
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    // Re-resolve background image if needed (e.g. after detach/attach)
    if (_background?.image != null && _backgroundImageInfo == null) {
      _resolveBackgroundImage();
    }

    if (parentData is YogaLayoutParentData) {
      final pd = parentData as YogaLayoutParentData;
      pd.width = _width;
      pd.height = _height;
      pd.minWidth = _minWidth;
      pd.maxWidth = _maxWidth;
      pd.minHeight = _minHeight;
      pd.maxHeight = _maxHeight;
      pd.flexGrow = _flexGrow;
      pd.flexShrink = _flexShrink;
      pd.flexBasis = _flexBasis;
      pd.display = _display;
      pd.margin = _margin;
      pd.border = _border;
      pd.alignSelf = _alignSelf;
      pd.boxShadow = _boxShadow;
      pd.boxSizing = _boxSizing;
      pd.overflow = _overflow;
      pd.transform = _transform;
      pd.transformOrigin = _transformOrigin;
    }
  }

  set useWebDefaults(bool value) {
    _useWebDefaults = value;
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
    // Only apply if _border is null. If _border is set, it takes precedence.
    if (_border == null) {
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

    if (child is RenderYogaLayout) {
      // Link the existing rootNode of the nested YogaLayout
      childParentData.yogaNode = child.rootNode;
    } else {
      // Always recreate the node to ensure it matches the current config (especially UseWebDefaults)
      if (childParentData.yogaNode != null) {
        childParentData.yogaNode!.dispose();
      }
      childParentData.yogaNode = YogaNode(_config);
    }

    final childNode = childParentData.yogaNode!;

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
  void detach() {
    _disposeBackgroundImage();
    _rootNode.dispose(recursive: false);
    _config.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    _syncRootConstraints(constraints);
    _syncChildren(dryRun: false);

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
    RenderBox? child = firstChild;
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
  Size computeDryLayout(BoxConstraints constraints) {
    _syncRootConstraints(constraints);
    _syncChildren(dryRun: true);

    // Note: Margin collapsing is stateful on the nodes (modifies margins).
    // We should probably run it for dry layout too to get accurate size,
    // but we must be careful not to leave the nodes in a bad state if performLayout expects clean state.
    // However, performLayout resets margins via _resetMarginsRecursive if collapsing is disabled,
    // or re-runs collapsing.
    // So it should be fine to run it here.
    if (_enableMarginCollapsing) {
      _collapseMarginsRecursive(this);
    } else {
      _resetMarginsRecursive(this);
    }

    _rootNode.calculateLayout(
      availableWidth: constraints.hasBoundedWidth
          ? constraints.maxWidth
          : double.nan,
      availableHeight: constraints.hasBoundedHeight
          ? constraints.maxHeight
          : double.nan,
    );

    final double rootW = _rootNode.layoutWidth;
    final double rootH = _rootNode.layoutHeight;

    return constraints.constrain(
      Size(rootW.isNaN ? 0.0 : rootW, rootH.isNaN ? 0.0 : rootH),
    );
  }

  void _syncRootConstraints(BoxConstraints constraints) {
    // If constraints are tight, we MUST be that size.
    // This overrides any user-specified width/height (especially percentages),
    // because the parent has already resolved those percentages to this tight constraint.
    // If we don't do this, calculateLayout might resolve the percentage again against the constraint,
    // leading to double-scaling (e.g. 50% of 50% = 25%).

    if (constraints.hasTightWidth) {
      _rootNode.width = constraints.maxWidth;
    } else if (_width != null) {
      _applyWidth(_rootNode, _width!);
    } else if (constraints.hasBoundedWidth) {
      _rootNode.width = constraints.maxWidth;
    } else {
      _rootNode.setWidthAuto();
    }

    if (constraints.hasTightHeight) {
      _rootNode.height = constraints.maxHeight;
    } else if (_height != null) {
      _applyHeight(_rootNode, _height!);
    } else if (constraints.hasBoundedHeight) {
      _rootNode.height = constraints.maxHeight;
    } else {
      _rootNode.setHeightAuto();
    }

    if (_minWidth != null) {
      _applyMinWidth(_rootNode, _minWidth!);
    } else {
      _rootNode.minWidth = double.nan;
    }

    if (_maxWidth != null) {
      _applyMaxWidth(_rootNode, _maxWidth!);
    } else {
      _rootNode.maxWidth = double.nan;
    }

    if (_minHeight != null) {
      _applyMinHeight(_rootNode, _minHeight!);
    } else {
      _rootNode.minHeight = double.nan;
    }

    if (_maxHeight != null) {
      _applyMaxHeight(_rootNode, _maxHeight!);
    } else {
      _rootNode.maxHeight = double.nan;
    }
  }

  void _syncChildren({required bool dryRun}) {
    RenderBox? child = firstChild;
    while (child != null) {
      final childParentData = child.parentData as YogaLayoutParentData;
      final childNode = childParentData.yogaNode!;

      // Resolve effective properties (ParentData > Child RenderObject properties)
      YogaValue? width = childParentData.width;
      YogaValue? height = childParentData.height;
      YogaValue? minWidth = childParentData.minWidth;
      YogaValue? maxWidth = childParentData.maxWidth;
      YogaValue? minHeight = childParentData.minHeight;
      YogaValue? maxHeight = childParentData.maxHeight;
      double? flexGrow = childParentData.flexGrow;
      double? flexShrink = childParentData.flexShrink;
      double? flexBasis = childParentData.flexBasis;
      YogaDisplay? display = childParentData.display;
      YogaEdgeInsets? margin = childParentData.margin;
      YogaBorder? border = childParentData.border;
      int? alignSelf = childParentData.alignSelf;
      YogaBoxSizing? boxSizing = childParentData.boxSizing;

      if (child is RenderYogaLayout) {
        width ??= child._width;
        height ??= child._height;
        minWidth ??= child._minWidth;
        maxWidth ??= child._maxWidth;
        minHeight ??= child._minHeight;
        maxHeight ??= child._maxHeight;
        flexGrow ??= child._flexGrow;
        flexShrink ??= child._flexShrink;
        flexBasis ??= child._flexBasis;
        display ??= child._display;
        margin ??= child._margin;
        border ??= child._border;
        alignSelf ??= child._alignSelf;
        boxSizing ??= child._boxSizing;
      }

      // 1. Sync Basic Layout Properties
      if (width != null) {
        _applyWidth(childNode, width);
      } else {
        // If width is null, we don't reset it here because it might be auto/undefined
        // But we should probably ensure it's auto if not set?
        // YogaItem sets it to auto if null.
        // Let's assume if it's null in parentData, it should be auto.
        // However, we need to be careful about display:block behavior (width: 100%).
        if (display == YogaDisplay.block) {
          childNode.setWidthPercent(100);
        } else {
          childNode.setWidthAuto();
        }
      }

      if (height != null) {
        _applyHeight(childNode, height);
      } else {
        childNode.setHeightAuto();
      }

      if (minWidth != null) {
        _applyMinWidth(childNode, minWidth);
      } else {
        childNode.minWidth = double.nan;
      }

      if (maxWidth != null) {
        _applyMaxWidth(childNode, maxWidth);
      } else {
        childNode.maxWidth = double.nan;
      }

      if (minHeight != null) {
        _applyMinHeight(childNode, minHeight);
      } else {
        childNode.minHeight = double.nan;
      }

      if (maxHeight != null) {
        _applyMaxHeight(childNode, maxHeight);
      } else {
        childNode.maxHeight = double.nan;
      }

      if (flexGrow != null) {
        childNode.flexGrow = flexGrow;
      } else {
        childNode.flexGrow = 0; // Default
      }

      if (flexShrink != null) {
        childNode.flexShrink = flexShrink;
      } else {
        // Default (Yoga default is 0, Web is 1)
        childNode.flexShrink = _useWebDefaults ? 1 : 0;
      }

      if (flexBasis != null) {
        childNode.flexBasis = flexBasis;
      } else {
        childNode.setFlexBasisAuto();
      }

      if (alignSelf != null) {
        childNode.alignSelf = alignSelf;

        // If user explicitly set stretch, but also set width: fit-content.
        // CSS says width wins. So we should change alignSelf to flexStart?
        bool preventStretchWidth =
            width?.unit == YogaUnit.fitContent ||
            width?.unit == YogaUnit.maxContent ||
            width?.unit == YogaUnit.minContent;
        bool preventStretchHeight =
            height?.unit == YogaUnit.fitContent ||
            height?.unit == YogaUnit.maxContent ||
            height?.unit == YogaUnit.minContent;

        int parentFlexDirection = _rootNode.flexDirection;
        bool isCrossAxisWidth =
            parentFlexDirection == YGFlexDirection.column ||
            parentFlexDirection == YGFlexDirection.columnReverse;

        if (isCrossAxisWidth &&
            preventStretchWidth &&
            alignSelf == YGAlign.stretch) {
          childNode.alignSelf = YGAlign.flexStart;
        }
        if (!isCrossAxisWidth &&
            preventStretchHeight &&
            alignSelf == YGAlign.stretch) {
          childNode.alignSelf = YGAlign.flexStart;
        }
      } else {
        // alignSelf is Auto.
        // If parent aligns to stretch, we need to override.
        bool preventStretchWidth =
            width?.unit == YogaUnit.fitContent ||
            width?.unit == YogaUnit.maxContent ||
            width?.unit == YogaUnit.minContent;
        bool preventStretchHeight =
            height?.unit == YogaUnit.fitContent ||
            height?.unit == YogaUnit.maxContent ||
            height?.unit == YogaUnit.minContent;

        int parentFlexDirection = _rootNode.flexDirection;
        bool isCrossAxisWidth =
            parentFlexDirection == YGFlexDirection.column ||
            parentFlexDirection == YGFlexDirection.columnReverse;

        int effectiveAlignItems = _alignItems ?? YGAlign.stretch;

        if (isCrossAxisWidth && preventStretchWidth) {
          if (effectiveAlignItems == YGAlign.stretch) {
            childNode.alignSelf = YGAlign.flexStart;
          } else {
            childNode.alignSelf = YGAlign.auto;
          }
        } else if (!isCrossAxisWidth && preventStretchHeight) {
          if (effectiveAlignItems == YGAlign.stretch) {
            childNode.alignSelf = YGAlign.flexStart;
          } else {
            childNode.alignSelf = YGAlign.auto;
          }
        } else {
          childNode.alignSelf = YGAlign.auto;
        }
      }

      if (display != null) {
        childNode.display = display == YogaDisplay.none
            ? YGDisplay.none
            : YGDisplay.flex;
      } else {
        childNode.display = YGDisplay.flex;
      }

      // 2. Sync Margins
      _setMarginEdge(childNode, YGEdge.left, margin?.left);
      _setMarginEdge(childNode, YGEdge.top, margin?.top);
      _setMarginEdge(childNode, YGEdge.right, margin?.right);
      _setMarginEdge(childNode, YGEdge.bottom, margin?.bottom);

      // 3. Apply Border Widths to YogaNode
      double borderTop = 0;
      double borderRight = 0;
      double borderBottom = 0;
      double borderLeft = 0;

      if (border != null) {
        final resolvedBorder = border.resolve(TextDirection.ltr);
        final flutterBorder = resolvedBorder.toFlutterBorder();

        borderTop = flutterBorder.top.width;
        borderRight = flutterBorder.right.width;
        borderBottom = flutterBorder.bottom.width;
        borderLeft = flutterBorder.left.width;

        childNode.setBorder(YGEdge.top, borderTop);
        childNode.setBorder(YGEdge.right, borderRight);
        childNode.setBorder(YGEdge.bottom, borderBottom);
        childNode.setBorder(YGEdge.left, borderLeft);
      } else {
        childNode.setBorder(YGEdge.all, 0);
      }

      // 4. Apply Box Sizing (Content-Box adjustment)
      if (boxSizing == YogaBoxSizing.contentBox) {
        if (width != null && width.unit == YogaUnit.point) {
          childNode.width = width.value + borderLeft + borderRight;
        }
        if (height != null && height.unit == YogaUnit.point) {
          childNode.height = height.value + borderTop + borderBottom;
        }
      } else {
        // Re-apply width/height to ensure it's not stale from previous content-box calculation
        if (width != null && width.unit == YogaUnit.point) {
          childNode.width = width.value;
        }
        if (height != null && height.unit == YogaUnit.point) {
          childNode.height = height.value;
        }
      }

      // 5. Measure child if needed
      bool widthIsSet =
          width != null &&
          width.unit != YogaUnit.auto &&
          width.unit != YogaUnit.undefined &&
          width.unit != YogaUnit.maxContent &&
          width.unit != YogaUnit.minContent &&
          width.unit != YogaUnit.fitContent;
      bool heightIsSet =
          height != null &&
          height.unit != YogaUnit.auto &&
          height.unit != YogaUnit.undefined &&
          height.unit != YogaUnit.maxContent &&
          height.unit != YogaUnit.minContent &&
          height.unit != YogaUnit.fitContent;

      // If child is RenderYogaLayout, we skip manual measurement because we linked its rootNode.
      // Yoga will handle the layout of the subtree automatically.
      if ((!widthIsSet || !heightIsSet) && child is! RenderYogaLayout) {
        // Check if we should skip measurement because of stretch alignment
        bool skipWidth = false;
        bool skipHeight = false;

        final int parentFlexDirection = _rootNode.flexDirection;
        final int parentAlignItems = _alignItems ?? YGAlign.stretch;

        // Determine effective alignment for the child
        int effectiveAlign = alignSelf ?? YGAlign.auto;
        if (effectiveAlign == YGAlign.auto) {
          effectiveAlign = parentAlignItems;
        }
        // If still auto (and parent was auto/initial), default depends on config but usually stretch for alignItems
        // However, YGAlign.auto is 0. YGAlign.stretch is 4.
        // If parentAlignItems returned 0 (auto), it might mean "not set", which defaults to stretch in Yoga.
        // Let's assume if effectiveAlign is auto or stretch, it stretches.
        // Note: alignSelf: auto inherits parent alignItems.

        bool isStretch = effectiveAlign == YGAlign.stretch;
        // If useWebDefaults is true, default alignItems is stretch.
        // But _rootNode.alignItems might return auto (0) if not explicitly set?
        // If we set useWebDefaults, Yoga config handles the default.
        // But here we are checking the property value.
        // If property is auto, and useWebDefaults is true, it acts as stretch.
        if (effectiveAlign == YGAlign.auto && _useWebDefaults) {
          isStretch = true;
        }

        if (isStretch) {
          if (parentFlexDirection == YGFlexDirection.column ||
              parentFlexDirection == YGFlexDirection.columnReverse) {
            // Cross axis is Width
            skipWidth = true;
          } else {
            // Cross axis is Height
            skipHeight = true;
          }
        }

        Size childSize = Size.zero;
        // Only call getDryLayout if we need it (for auto/undefined/maxContent/fitContent default)
        // For minContent we use getMinIntrinsicWidth/Height
        bool needDryLayout = false;

        if (!widthIsSet && !skipWidth) {
          if (width?.unit == YogaUnit.minContent) {
            childNode.width = child.getMinIntrinsicWidth(double.infinity);
          } else if (width?.unit == YogaUnit.maxContent) {
            childNode.width = child.getMaxIntrinsicWidth(double.infinity);
          } else if (width?.unit == YogaUnit.fitContent) {
            // fit-content: use max-content (will shrink if flexShrink is set)
            childNode.width = child.getMaxIntrinsicWidth(double.infinity);
          } else {
            // Auto / Undefined
            needDryLayout = true;
          }
        }

        if (!heightIsSet && !skipHeight) {
          if (height?.unit == YogaUnit.minContent) {
            childNode.height = child.getMinIntrinsicHeight(double.infinity);
          } else if (height?.unit == YogaUnit.maxContent) {
            childNode.height = child.getMaxIntrinsicHeight(double.infinity);
          } else if (height?.unit == YogaUnit.fitContent) {
            childNode.height = child.getMaxIntrinsicHeight(double.infinity);
          } else {
            needDryLayout = true;
          }
        }

        if (needDryLayout) {
          try {
            childSize = child.getDryLayout(const BoxConstraints());
          } catch (e) {
            // Fallback to intrinsic size if dry layout fails (e.g. RenderFlex assertion)
            childSize = Size(
              child.getMaxIntrinsicWidth(double.infinity),
              child.getMaxIntrinsicHeight(double.infinity),
            );
          }
        }

        if (!widthIsSet && !skipWidth) {
          if (width?.unit == YogaUnit.auto ||
              width?.unit == YogaUnit.undefined ||
              width == null) {
            childNode.width = childSize.width.ceilToDouble();
          }
        }
        if (!heightIsSet && !skipHeight) {
          if (height?.unit == YogaUnit.auto ||
              height?.unit == YogaUnit.undefined ||
              height == null) {
            childNode.height = childSize.height.ceilToDouble();
          }
        }
      }

      child = childParentData.nextSibling;
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
      case YogaUnit.undefined:
      case YogaUnit.maxContent:
      case YogaUnit.minContent:
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
      case YogaUnit.undefined:
      case YogaUnit.maxContent:
      case YogaUnit.minContent:
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

  @override
  void paint(PaintingContext context, Offset offset) {
    // Check if we need to paint our own decoration
    // If parent is RenderYogaLayout, it paints our decoration (border, shadow, transform)
    // based on our parentData.
    bool parentHandlesDecoration = parent is RenderYogaLayout;

    if (parentHandlesDecoration) {
      // Even if parent handles decoration (border, shadow, transform),
      // we are still responsible for painting our own background.
      // The parent paints shadow BEFORE calling us, and border AFTER calling us.
      // So we just need to paint background and then children.
      if (_background != null) {
        _paintBackground(context, offset, size, _background!);
      }
      _paintChildren(context, offset);
    } else {
      // We are root (or not inside YogaLayout), so we paint our own decoration
      if (_transform != null) {
        final Matrix4 transform = _transform!;
        final AlignmentGeometry originAlignment =
            _transformOrigin ?? Alignment.center;
        final Offset originOffset = originAlignment
            .resolve(TextDirection.ltr)
            .alongSize(size);
        final Matrix4 effectiveTransform =
            Matrix4.translationValues(originOffset.dx, originOffset.dy, 0.0)
              ..multiply(transform)
              ..multiply(
                Matrix4.translationValues(
                  -originOffset.dx,
                  -originOffset.dy,
                  0.0,
                ),
              );

        context.pushTransform(needsCompositing, offset, effectiveTransform, (
          context,
          offset,
        ) {
          _paintSelfWithDecoration(context, offset);
        });
      } else {
        _paintSelfWithDecoration(context, offset);
      }
    }
  }

  void _paintSelfWithDecoration(PaintingContext context, Offset offset) {
    // 0. Background
    if (_background != null) {
      _paintBackground(context, offset, size, _background!);
    }

    // 1. Shadow
    if (_boxShadow != null) {
      _paintShadows(context, offset, size, _boxShadow!);
    }

    // 2. Clip (Overflow) & Children
    if (_overflow == YogaOverflow.hidden) {
      ResolvedYogaBorder? resolvedBorder;
      if (_border != null) {
        resolvedBorder = _border!.resolve(TextDirection.ltr);
      }

      final Rect rect = offset & size;
      if (resolvedBorder != null &&
          resolvedBorder.borderRadius != YogaBorderRadius.zero) {
        final RRect rrect = resolvedBorder.borderRadius
            .toFlutterBorderRadius(size)
            .toRRect(rect);
        context.pushClipRRect(needsCompositing, offset, rect, rrect, (
          context,
          offset,
        ) {
          _paintChildren(context, offset);
        });
      } else {
        context.pushClipRect(needsCompositing, offset, rect, (context, offset) {
          _paintChildren(context, offset);
        });
      }
    } else {
      _paintChildren(context, offset);
    }

    // 3. Border
    if (_border != null) {
      // We don't support border image on root for now (no ImageInfo stored in RenderObject)
      _paintBorder(context, offset, size, _border!, null);
    }
  }

  void _paintChildren(PaintingContext context, Offset offset) {
    RenderBox? child = firstChild;
    while (child != null) {
      final childParentData = child.parentData as YogaLayoutParentData;
      final Offset childOffset = childParentData.offset + offset;

      if (childParentData.transform != null) {
        _paintWithTransform(context, child, childParentData, childOffset);
      } else {
        _paintChildContent(context, child, childParentData, childOffset);
      }

      child = childParentData.nextSibling;
    }
  }

  void _paintWithTransform(
    PaintingContext context,
    RenderBox child,
    YogaLayoutParentData childParentData,
    Offset childOffset,
  ) {
    final Matrix4 transform = childParentData.transform!;
    final AlignmentGeometry originAlignment =
        childParentData.transformOrigin ?? Alignment.center;
    final Offset originOffset = originAlignment
        .resolve(TextDirection.ltr)
        .alongSize(child.size);

    // Create the effective transform matrix
    // We want to transform around the origin.
    // The matrix passed in `transform` is usually just the rotation/scale.
    // We need to: Translate(origin) -> Transform -> Translate(-origin)

    final Matrix4 effectiveTransform =
        Matrix4.translationValues(originOffset.dx, originOffset.dy, 0.0)
          ..multiply(transform)
          ..multiply(
            Matrix4.translationValues(-originOffset.dx, -originOffset.dy, 0.0),
          );

    context.pushTransform(needsCompositing, childOffset, effectiveTransform, (
      PaintingContext context,
      Offset offset,
    ) {
      _paintChildContent(context, child, childParentData, offset);
    });
  }

  void _paintChildContent(
    PaintingContext context,
    RenderBox child,
    YogaLayoutParentData childParentData,
    Offset paintOffset,
  ) {
    // Paint shadow
    if (childParentData.boxShadow != null) {
      _paintShadows(
        context,
        paintOffset,
        child.size,
        childParentData.boxShadow!,
      );
    }

    // Paint child
    ResolvedYogaBorder? resolvedBorder;
    if (childParentData.border != null) {
      resolvedBorder = childParentData.border!.resolve(TextDirection.ltr);
    }

    final Rect childRect = paintOffset & child.size;
    final RenderBox childRenderBox = child;

    if (childParentData.overflow == YogaOverflow.hidden) {
      if (resolvedBorder != null &&
          resolvedBorder.borderRadius != YogaBorderRadius.zero) {
        final RRect rrect = resolvedBorder.borderRadius
            .toFlutterBorderRadius(child.size)
            .toRRect(childRect);
        context.pushClipRRect(needsCompositing, paintOffset, childRect, rrect, (
          context,
          offset,
        ) {
          context.paintChild(childRenderBox, offset);
        });
      } else {
        context.pushClipRect(needsCompositing, paintOffset, childRect, (
          context,
          offset,
        ) {
          context.paintChild(childRenderBox, offset);
        });
      }
    } else {
      context.paintChild(child, paintOffset);
    }

    // Paint border
    if (childParentData.border != null) {
      // Resolve border image if present (now that child has been laid out)
      if (childParentData.border!.image != null) {
        _resolveBorderImage(child, childParentData);
      }

      _paintBorder(
        context,
        paintOffset,
        child.size,
        childParentData.border!,
        childParentData._borderImageInfo,
      );
    }
  }

  void _paintBorder(
    PaintingContext context,
    Offset offset,
    Size size,
    YogaBorder border,
    ImageInfo? borderImageInfo,
  ) {
    // Resolve border (assuming LTR for now, ideally pass TextDirection)
    final resolvedBorder = border.resolve(TextDirection.ltr);

    // Paint border image if available
    if (border.image != null && borderImageInfo != null) {
      _paintBorderImage(context, offset, size, border.image!, borderImageInfo);
      return; // If border image is painted, do we paint standard border? CSS says border-image replaces border-style.
    }

    // Check if we need custom painting (dotted/dashed)
    bool hasCustomStyle =
        resolvedBorder.top.style == YogaBorderStyle.dotted ||
        resolvedBorder.top.style == YogaBorderStyle.dashed ||
        resolvedBorder.right.style == YogaBorderStyle.dotted ||
        resolvedBorder.right.style == YogaBorderStyle.dashed ||
        resolvedBorder.bottom.style == YogaBorderStyle.dotted ||
        resolvedBorder.bottom.style == YogaBorderStyle.dashed ||
        resolvedBorder.left.style == YogaBorderStyle.dotted ||
        resolvedBorder.left.style == YogaBorderStyle.dashed;

    if (hasCustomStyle) {
      if (resolvedBorder.isUniform &&
          resolvedBorder.borderRadius != YogaBorderRadius.zero) {
        _paintUniformRoundedBorder(context, offset, size, resolvedBorder);
      } else {
        _paintCustomBorder(context, offset, size, resolvedBorder);
      }
    } else {
      // Use Flutter's optimized border painting for solid/none
      final flutterBorder = resolvedBorder.toFlutterBorder();
      final borderRadius = resolvedBorder.borderRadius.toFlutterBorderRadius(
        size,
      );

      if (borderRadius != BorderRadius.zero) {
        flutterBorder.paint(
          context.canvas,
          offset & size,
          borderRadius: borderRadius,
        );
      } else {
        flutterBorder.paint(context.canvas, offset & size);
      }
    }
  }

  void _paintCustomBorder(
    PaintingContext context,
    Offset offset,
    Size size,
    ResolvedYogaBorder border,
  ) {
    final Canvas canvas = context.canvas;
    final Rect rect = offset & size;

    // Helper to paint a single side
    void paintSide(
      YogaBorderSide side,
      Offset p1,
      Offset p2,
      bool isHorizontal,
    ) {
      if (side.style == YogaBorderStyle.none ||
          side.style == YogaBorderStyle.hidden ||
          (side.width ?? 0) <= 0) {
        return;
      }

      final double width = side.width ?? 1.0;
      final Paint paint = Paint()
        ..color = side.color ?? const Color(0xFF000000)
        ..strokeWidth = width
        ..style = PaintingStyle.stroke;

      if (side.style == YogaBorderStyle.solid) {
        canvas.drawLine(p1, p2, paint);
      } else if (side.style == YogaBorderStyle.dashed) {
        _drawDashedLine(canvas, p1, p2, width, paint);
      } else if (side.style == YogaBorderStyle.dotted) {
        _drawDottedLine(canvas, p1, p2, width, paint);
      }
    }

    // We paint sides as lines.
    // To avoid overlap issues at corners for translucent colors, we might need more complex logic.
    // But for dashed/dotted, simple lines are usually acceptable approximation for "CSS-like" behavior in Flutter
    // without implementing full trapezoid path clipping for every dash.

    // Top
    if (border.top.width != null && border.top.width! > 0) {
      paintSide(
        border.top,
        rect.topLeft.translate(0, border.top.width! / 2),
        rect.topRight.translate(0, border.top.width! / 2),
        true,
      );
    }

    // Right
    if (border.right.width != null && border.right.width! > 0) {
      paintSide(
        border.right,
        rect.topRight.translate(-border.right.width! / 2, 0),
        rect.bottomRight.translate(-border.right.width! / 2, 0),
        false,
      );
    }

    // Bottom
    if (border.bottom.width != null && border.bottom.width! > 0) {
      paintSide(
        border.bottom,
        rect.bottomLeft.translate(0, -border.bottom.width! / 2),
        rect.bottomRight.translate(0, -border.bottom.width! / 2),
        true,
      );
    }

    // Left
    if (border.left.width != null && border.left.width! > 0) {
      paintSide(
        border.left,
        rect.topLeft.translate(border.left.width! / 2, 0),
        rect.bottomLeft.translate(border.left.width! / 2, 0),
        false,
      );
    }
  }

  void _paintUniformRoundedBorder(
    PaintingContext context,
    Offset offset,
    Size size,
    ResolvedYogaBorder border,
  ) {
    final Canvas canvas = context.canvas;
    final Rect rect = offset & size;
    final RRect rrect = border.borderRadius
        .toFlutterBorderRadius(size)
        .toRRect(rect);

    // Since it's uniform, we take top side properties
    final double width = border.top.width ?? 1.0;
    final Color color = border.top.color ?? const Color(0xFF000000);
    final YogaBorderStyle style = border.top.style ?? YogaBorderStyle.solid;

    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..style = PaintingStyle.stroke;

    // Deflate by half width to stroke inside the border area (centered on the inset line)
    final RRect innerRRect = rrect.deflate(width / 2);
    final Path path = Path()..addRRect(innerRRect);

    if (style == YogaBorderStyle.dashed) {
      _drawDashedPath(canvas, path, width, paint);
    } else if (style == YogaBorderStyle.dotted) {
      _drawDottedPath(canvas, path, width, paint);
    } else {
      canvas.drawPath(path, paint);
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, double width, Paint paint) {
    final double dashWidth = 3 * width;
    final double dashSpace = 3 * width;

    for (final ui.PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double len = (distance + dashWidth > metric.length)
            ? metric.length - distance
            : dashWidth;
        final Path extract = metric.extractPath(distance, distance + len);
        canvas.drawPath(extract, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  void _drawDottedPath(Canvas canvas, Path path, double width, Paint paint) {
    final Paint dotPaint = Paint()
      ..color = paint.color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final double step = 2 * width;

    for (final ui.PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final ui.Tangent? tangent = metric.getTangentForOffset(distance);
        if (tangent != null) {
          canvas.drawPoints(ui.PointMode.points, [tangent.position], dotPaint);
        }
        distance += step;
      }
    }
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset p1,
    Offset p2,
    double width,
    Paint paint,
  ) {
    // CSS dashed: usually 3*width dash, 3*width gap (or similar)
    final double dashWidth = 3 * width;
    final double dashSpace = 3 * width;
    final double distance = (p2 - p1).distance;
    final double dx = (p2.dx - p1.dx) / distance;
    final double dy = (p2.dy - p1.dy) / distance;

    double currentDistance = 0;
    while (currentDistance < distance) {
      final double len = (currentDistance + dashWidth > distance)
          ? distance - currentDistance
          : dashWidth;
      canvas.drawLine(
        p1 + Offset(dx * currentDistance, dy * currentDistance),
        p1 + Offset(dx * (currentDistance + len), dy * (currentDistance + len)),
        paint,
      );
      currentDistance += dashWidth + dashSpace;
    }
  }

  void _drawDottedLine(
    Canvas canvas,
    Offset p1,
    Offset p2,
    double width,
    Paint paint,
  ) {
    // CSS dotted: circles with diameter = width, spaced by width (or less)
    // We use round cap for dots
    final Paint dotPaint = Paint()
      ..color = paint.color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final double distance = (p2 - p1).distance;
    final double dx = (p2.dx - p1.dx) / distance;
    final double dy = (p2.dy - p1.dy) / distance;

    // Spacing: diameter (width) + gap (width) = 2*width
    final double step = 2 * width;
    double currentDistance = 0;

    while (currentDistance <= distance) {
      canvas.drawPoints(ui.PointMode.points, [
        p1 + Offset(dx * currentDistance, dy * currentDistance),
      ], dotPaint);
      currentDistance += step;
    }
  }

  void _paintBorderImage(
    PaintingContext context,
    Offset offset,
    Size size,
    YogaBorderImage borderImage,
    ImageInfo imageInfo,
  ) {
    final Rect rect = offset & size;
    final double imgW = imageInfo.image.width.toDouble();
    final double imgH = imageInfo.image.height.toDouble();

    // 1. Resolve Slices (Source)
    final double sliceL = _resolveValue(borderImage.slice.left, imgW);
    final double sliceT = _resolveValue(borderImage.slice.top, imgH);
    final double sliceR = _resolveValue(borderImage.slice.right, imgW);
    final double sliceB = _resolveValue(borderImage.slice.bottom, imgH);

    // 2. Resolve Outsets
    final double outsetL = _resolveValue(borderImage.outset.left, size.width);
    final double outsetT = _resolveValue(borderImage.outset.top, size.height);
    final double outsetR = _resolveValue(borderImage.outset.right, size.width);
    final double outsetB = _resolveValue(
      borderImage.outset.bottom,
      size.height,
    );

    final Rect destRect = Rect.fromLTRB(
      rect.left - outsetL,
      rect.top - outsetT,
      rect.right + outsetR,
      rect.bottom + outsetB,
    );

    // 3. Resolve Border Widths (Destination)
    // Use borderImage.width if available, otherwise fallback to slice size (common behavior if width not set)
    // or 0 if we want to be strict. For this implementation, we use the provided width or slice.
    double borderL = _resolveValue(
      borderImage.width?.left ?? YogaValue.point(sliceL),
      destRect.width,
    );
    double borderT = _resolveValue(
      borderImage.width?.top ?? YogaValue.point(sliceT),
      destRect.height,
    );
    double borderR = _resolveValue(
      borderImage.width?.right ?? YogaValue.point(sliceR),
      destRect.width,
    );
    double borderB = _resolveValue(
      borderImage.width?.bottom ?? YogaValue.point(sliceB),
      destRect.height,
    );

    // Source Rects
    final Rect srcTL = Rect.fromLTWH(0, 0, sliceL, sliceT);
    final Rect srcTR = Rect.fromLTWH(imgW - sliceR, 0, sliceR, sliceT);
    final Rect srcBL = Rect.fromLTWH(0, imgH - sliceB, sliceL, sliceB);
    final Rect srcBR = Rect.fromLTWH(
      imgW - sliceR,
      imgH - sliceB,
      sliceR,
      sliceB,
    );

    final Rect srcTop = Rect.fromLTWH(
      sliceL,
      0,
      imgW - sliceL - sliceR,
      sliceT,
    );
    final Rect srcBottom = Rect.fromLTWH(
      sliceL,
      imgH - sliceB,
      imgW - sliceL - sliceR,
      sliceB,
    );
    final Rect srcLeft = Rect.fromLTWH(
      0,
      sliceT,
      sliceL,
      imgH - sliceT - sliceB,
    );
    final Rect srcRight = Rect.fromLTWH(
      imgW - sliceR,
      sliceT,
      sliceR,
      imgH - sliceT - sliceB,
    );

    final Rect srcCenter = Rect.fromLTWH(
      sliceL,
      sliceT,
      imgW - sliceL - sliceR,
      imgH - sliceT - sliceB,
    );

    // Destination Rects
    final Rect dstTL = Rect.fromLTWH(
      destRect.left,
      destRect.top,
      borderL,
      borderT,
    );
    final Rect dstTR = Rect.fromLTWH(
      destRect.right - borderR,
      destRect.top,
      borderR,
      borderT,
    );
    final Rect dstBL = Rect.fromLTWH(
      destRect.left,
      destRect.bottom - borderB,
      borderL,
      borderB,
    );
    final Rect dstBR = Rect.fromLTWH(
      destRect.right - borderR,
      destRect.bottom - borderB,
      borderR,
      borderB,
    );

    final Rect dstTop = Rect.fromLTWH(
      destRect.left + borderL,
      destRect.top,
      math.max(0, destRect.width - borderL - borderR),
      borderT,
    );
    final Rect dstBottom = Rect.fromLTWH(
      destRect.left + borderL,
      destRect.bottom - borderB,
      math.max(0, destRect.width - borderL - borderR),
      borderB,
    );
    final Rect dstLeft = Rect.fromLTWH(
      destRect.left,
      destRect.top + borderT,
      borderL,
      math.max(0, destRect.height - borderT - borderB),
    );
    final Rect dstRight = Rect.fromLTWH(
      destRect.right - borderR,
      destRect.top + borderT,
      borderR,
      math.max(0, destRect.height - borderT - borderB),
    );

    final Rect dstCenter = Rect.fromLTWH(
      destRect.left + borderL,
      destRect.top + borderT,
      math.max(0, destRect.width - borderL - borderR),
      math.max(0, destRect.height - borderT - borderB),
    );

    final Paint paint = Paint();
    final Canvas canvas = context.canvas;

    // Draw Corners (Always stretch/scale to fit corner box)
    if (!dstTL.isEmpty && !srcTL.isEmpty) {
      canvas.drawImageRect(imageInfo.image, srcTL, dstTL, paint);
    }
    if (!dstTR.isEmpty && !srcTR.isEmpty) {
      canvas.drawImageRect(imageInfo.image, srcTR, dstTR, paint);
    }
    if (!dstBL.isEmpty && !srcBL.isEmpty) {
      canvas.drawImageRect(imageInfo.image, srcBL, dstBL, paint);
    }
    if (!dstBR.isEmpty && !srcBR.isEmpty) {
      canvas.drawImageRect(imageInfo.image, srcBR, dstBR, paint);
    }

    // Draw Edges
    _drawTile(
      canvas,
      imageInfo.image,
      srcTop,
      dstTop,
      borderImage.repeat,
      isHorizontal: true,
    );
    _drawTile(
      canvas,
      imageInfo.image,
      srcBottom,
      dstBottom,
      borderImage.repeat,
      isHorizontal: true,
    );
    _drawTile(
      canvas,
      imageInfo.image,
      srcLeft,
      dstLeft,
      borderImage.repeat,
      isHorizontal: false,
    );
    _drawTile(
      canvas,
      imageInfo.image,
      srcRight,
      dstRight,
      borderImage.repeat,
      isHorizontal: false,
    );

    // Draw Center
    if (borderImage.fill) {
      // For center, we should ideally tile in both directions.
      // For now, let's just stretch or simple tile.
      // Implementing full 2D tiling for center is complex and rarely used with complex repeats.
      // Let's use stretch for center for now as a simplification, or use paintImage.
      if (!dstCenter.isEmpty && !srcCenter.isEmpty) {
        canvas.drawImageRect(imageInfo.image, srcCenter, dstCenter, paint);
      }
    }
  }

  void _drawTile(
    Canvas canvas,
    ui.Image image,
    Rect src,
    Rect dst,
    YogaBorderImageRepeat repeat, {
    required bool isHorizontal,
  }) {
    if (dst.isEmpty || src.isEmpty) return;

    if (repeat == YogaBorderImageRepeat.stretch) {
      canvas.drawImageRect(image, src, dst, Paint());
      return;
    }

    canvas.save();
    canvas.clipRect(dst);

    final double srcW = src.width;
    final double srcH = src.height;
    final double dstW = dst.width;
    final double dstH = dst.height;

    if (repeat == YogaBorderImageRepeat.round) {
      if (isHorizontal) {
        double count = (dstW / srcW).roundToDouble();
        if (count < 1) count = 1;
        double tileW = dstW / count;
        for (int i = 0; i < count; i++) {
          canvas.drawImageRect(
            image,
            src,
            Rect.fromLTWH(dst.left + i * tileW, dst.top, tileW, dstH),
            Paint(),
          );
        }
      } else {
        double count = (dstH / srcH).roundToDouble();
        if (count < 1) count = 1;
        double tileH = dstH / count;
        for (int i = 0; i < count; i++) {
          canvas.drawImageRect(
            image,
            src,
            Rect.fromLTWH(dst.left, dst.top + i * tileH, dstW, tileH),
            Paint(),
          );
        }
      }
    } else if (repeat == YogaBorderImageRepeat.repeat) {
      // Centered tiling
      if (isHorizontal) {
        double x = dst.center.dx - srcW / 2;
        // Draw center one
        canvas.drawImageRect(
          image,
          src,
          Rect.fromLTWH(x, dst.top, srcW, dstH),
          Paint(),
        );

        // Draw left
        double currX = x - srcW;
        while (currX + srcW > dst.left) {
          canvas.drawImageRect(
            image,
            src,
            Rect.fromLTWH(currX, dst.top, srcW, dstH),
            Paint(),
          );
          currX -= srcW;
        }

        // Draw right
        currX = x + srcW;
        while (currX < dst.right) {
          canvas.drawImageRect(
            image,
            src,
            Rect.fromLTWH(currX, dst.top, srcW, dstH),
            Paint(),
          );
          currX += srcW;
        }
      } else {
        // Vertical centered tiling
        double y = dst.center.dy - srcH / 2;
        canvas.drawImageRect(
          image,
          src,
          Rect.fromLTWH(dst.left, y, dstW, srcH),
          Paint(),
        );

        // Draw up
        double currY = y - srcH;
        while (currY + srcH > dst.top) {
          canvas.drawImageRect(
            image,
            src,
            Rect.fromLTWH(dst.left, currY, dstW, srcH),
            Paint(),
          );
          currY -= srcH;
        }

        // Draw down
        currY = y + srcH;
        while (currY < dst.bottom) {
          canvas.drawImageRect(
            image,
            src,
            Rect.fromLTWH(dst.left, currY, dstW, srcH),
            Paint(),
          );
          currY += srcH;
        }
      }
    } else {
      // Space or others, fallback to stretch
      canvas.drawImageRect(image, src, dst, Paint());
    }

    canvas.restore();
  }

  void _resolveBorderImage(
    RenderBox child,
    YogaLayoutParentData childParentData,
  ) {
    final borderImage = childParentData.border?.image;
    if (borderImage == null) {
      _disposeBorderImage(childParentData);
      return;
    }

    final ImageConfiguration config = ImageConfiguration(
      textDirection: TextDirection.ltr,
    );
    final ImageStream newStream = borderImage.source.resolve(config);

    if (newStream.key != childParentData._borderImageStream?.key) {
      _disposeBorderImage(childParentData);
      childParentData._borderImageStream = newStream;
      childParentData._borderImageListener = ImageStreamListener((
        ImageInfo imageInfo,
        bool synchronousCall,
      ) {
        childParentData._borderImageInfo = imageInfo;
        markNeedsPaint();
      });
      newStream.addListener(childParentData._borderImageListener!);
    }
  }

  void _disposeBorderImage(YogaLayoutParentData childParentData) {
    if (childParentData._borderImageStream != null) {
      childParentData._borderImageStream!.removeListener(
        childParentData._borderImageListener!,
      );
      childParentData._borderImageStream = null;
      childParentData._borderImageListener = null;
      childParentData._borderImageInfo = null;
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
      case YogaUnit.maxContent:
      case YogaUnit.minContent:
      case YogaUnit.fitContent:
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
      case YogaUnit.maxContent:
      case YogaUnit.minContent:
      case YogaUnit.fitContent:
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
    bool isHeightBounded;
    if (parent is RenderYogaLayout) {
      isHeightBounded =
          _height != null &&
          _height!.unit != YogaUnit.auto &&
          _height!.unit != YogaUnit.undefined;
    } else {
      isHeightBounded = constraints.hasBoundedHeight;
    }

    if (!isHeightBounded &&
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
        //
        // Yoga doesn't have setPaddingAuto.
        node.setPadding(edge, 0);
        break;
      case YogaUnit.undefined:
      case YogaUnit.maxContent:
      case YogaUnit.minContent:
      case YogaUnit.fitContent:
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

  void _applyLayoutProperties() {
    int effectiveJustifyContent = _justifyContent ?? YGJustify.flexStart;
    int effectiveAlignItems = _alignItems ?? YGAlign.stretch;

    if (_textAlign != null) {
      final isRow =
          _rootNode.flexDirection == YGFlexDirection.row ||
          _rootNode.flexDirection == YGFlexDirection.rowReverse;

      if (isRow) {
        // In Row, textAlign maps to justifyContent
        if (_justifyContent == null) {
          switch (_textAlign!) {
            case TextAlign.left:
            case TextAlign.start:
              effectiveJustifyContent = YGJustify.flexStart;
              break;
            case TextAlign.right:
            case TextAlign.end:
              effectiveJustifyContent = YGJustify.flexEnd;
              break;
            case TextAlign.center:
              effectiveJustifyContent = YGJustify.center;
              break;
            case TextAlign.justify:
              effectiveJustifyContent = YGJustify.spaceBetween;
              break;
          }
        }
      } else {
        // In Column, textAlign maps to alignItems
        if (_alignItems == null) {
          switch (_textAlign!) {
            case TextAlign.left:
            case TextAlign.start:
              effectiveAlignItems = YGAlign.flexStart;
              break;
            case TextAlign.right:
            case TextAlign.end:
              effectiveAlignItems = YGAlign.flexEnd;
              break;
            case TextAlign.center:
              effectiveAlignItems = YGAlign.center;
              break;
            case TextAlign.justify:
              effectiveAlignItems = YGAlign.stretch;
              break;
          }
        }
      }
    }

    _rootNode.justifyContent = effectiveJustifyContent;
    _rootNode.alignItems = effectiveAlignItems;
  }

  void _paintBackground(
    PaintingContext context,
    Offset offset,
    Size size,
    YogaBackground background,
  ) {
    final Canvas canvas = context.canvas;
    final Rect rect = offset & size;

    // 1. Background Color
    if (background.color != null) {
      RRect? rrect;
      if (_border != null) {
        final resolvedBorder = _border!.resolve(TextDirection.ltr);
        if (resolvedBorder.borderRadius != YogaBorderRadius.zero) {
          rrect = resolvedBorder.borderRadius
              .toFlutterBorderRadius(size)
              .toRRect(rect);
        }
      }

      final Paint paint = Paint()..color = background.color!;
      if (rrect != null) {
        canvas.drawRRect(rrect, paint);
      } else {
        canvas.drawRect(rect, paint);
      }
    }

    // 2. Background Image
    if (background.image != null && _backgroundImageInfo != null) {
      _paintBackgroundImage(
        context,
        offset,
        size,
        background,
        _backgroundImageInfo!,
      );
    }
  }

  void _paintBackgroundImage(
    PaintingContext context,
    Offset offset,
    Size size,
    YogaBackground background,
    ImageInfo imageInfo,
  ) {
    Rect positioningArea = offset & size;

    // Adjust for origin
    EdgeInsets border = EdgeInsets.zero;
    if (_border != null) {
      final resolved = _border!.resolve(TextDirection.ltr);
      final fb = resolved.toFlutterBorder();
      border = fb.dimensions as EdgeInsets;
    } else {
      border = _borderWidth;
    }

    EdgeInsets padding = EdgeInsets.zero;
    if (_padding != null) {
      padding = EdgeInsets.only(
        left: _resolveValue(_padding!.left, size.width),
        top: _resolveValue(_padding!.top, size.height),
        right: _resolveValue(_padding!.right, size.width),
        bottom: _resolveValue(_padding!.bottom, size.height),
      );
    }

    if (background.origin == YogaBackgroundOrigin.contentBox) {
      positioningArea = padding.deflateRect(
        border.deflateRect(positioningArea),
      );
    } else if (background.origin == YogaBackgroundOrigin.paddingBox) {
      positioningArea = border.deflateRect(positioningArea);
    }

    // Clip to border radius
    RRect? clipRRect;
    if (_border != null) {
      final resolvedBorder = _border!.resolve(TextDirection.ltr);
      if (resolvedBorder.borderRadius != YogaBorderRadius.zero) {
        clipRRect = resolvedBorder.borderRadius
            .toFlutterBorderRadius(size)
            .toRRect(offset & size);
      }
    }

    context.canvas.save();
    if (clipRRect != null) {
      context.canvas.clipRRect(clipRRect);
    } else {
      context.canvas.clipRect(offset & size);
    }

    Rect drawingRect = positioningArea;
    BoxFit fit = BoxFit.none;
    Alignment alignment = _mapBackgroundPositionToAlignment(
      background.position,
    );

    if (background.size.mode == YogaBackgroundSizeMode.explicit) {
      // If explicit size, we calculate the target rect size
      double w = _resolveValue(background.size.width, positioningArea.width);
      double h = _resolveValue(background.size.height, positioningArea.height);

      // If auto, use image size
      if (background.size.width.unit == YogaUnit.auto) {
        w = imageInfo.image.width.toDouble();
      }
      if (background.size.height.unit == YogaUnit.auto) {
        h = imageInfo.image.height.toDouble();
      }

      // If no-repeat, we can simulate explicit size by adjusting drawingRect
      if (background.repeat == ImageRepeat.noRepeat) {
        // Align the smaller rect within positioningArea
        drawingRect = alignment.inscribe(Size(w, h), positioningArea);
        fit = BoxFit.fill;
        alignment = Alignment.center; // Already aligned by inscribe
      } else {
        // If repeat, paintImage ignores fit/size.
        // We can't easily support explicit size with repeat using paintImage.
        // Fallback to auto/none.
        fit = BoxFit.none;
      }
    } else {
      switch (background.size.mode) {
        case YogaBackgroundSizeMode.cover:
          fit = BoxFit.cover;
          break;
        case YogaBackgroundSizeMode.contain:
          fit = BoxFit.contain;
          break;
        case YogaBackgroundSizeMode.auto:
        default:
          // Use scaleDown to ensure image is visible even if larger than container,
          // and behaves like none (original size) if smaller.
          fit = BoxFit.scaleDown;
          break;
      }
    }

    // Debug print
    // debugPrint(
    //   'Painting background: mode=${background.size.mode}, fit=$fit, repeat=${background.repeat}, rect=$drawingRect, image=${imageInfo.image.width}x${imageInfo.image.height}',
    // );

    paintImage(
      canvas: context.canvas,
      rect: drawingRect,
      image: imageInfo.image,
      fit: fit,
      alignment: alignment,
      repeat: background.repeat,
      scale: imageInfo.scale,
    );
    context.canvas.restore();
  }

  Alignment _mapBackgroundPositionToAlignment(YogaBackgroundPosition pos) {
    double x = 0;
    double y = 0;

    if (pos.x.unit == YogaUnit.percent) {
      x = (pos.x.value * 2 / 100) - 1.0;
    } else if (pos.x.unit == YogaUnit.point) {
      // Alignment doesn't support points easily without knowing size.
      // But paintImage uses Alignment to position within rect.
      // If we have points, we can't map to -1..1 without size.
      // But we can approximate or default to center/start.
      // Let's assume 0 if point.
      x = -1.0;
    }

    if (pos.y.unit == YogaUnit.percent) {
      y = (pos.y.value * 2 / 100) - 1.0;
    } else if (pos.y.unit == YogaUnit.point) {
      y = -1.0;
    }

    return Alignment(x, y);
  }
}
