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

  // 用于差异比较的缓存
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
  TextAlign? textAlign;
  List<YogaBoxShadow>? boxShadow;
  YogaOverflow? overflow;
  Matrix4? transform;
  AlignmentGeometry? transformOrigin;

  // 合并后的有效外边距（仅运行时，非用户设置）
  EdgeInsets? effectiveMargin;

  // 边框图片运行时数据
  ImageStream? _borderImageStream;
  ImageInfo? _borderImageInfo;
  ImageStreamListener? _borderImageListener;

  @override
  String toString() =>
      '${super.toString()}; yogaNode=$yogaNode; textAlign=$textAlign';

  @override
  void detach() {
    _borderImageStream?.removeListener(_borderImageListener!);
    _borderImageStream = null;
    _borderImageListener = null;
    _borderImageInfo = null;
    super.detach();
  }
}

class YogaLayoutResult {
  final Size size;
  final double? baseline;
  YogaLayoutResult(this.size, this.baseline);
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

  // 背景图片运行时数据
  ImageStream? _backgroundImageStream;
  ImageInfo? _backgroundImageInfo;
  ImageStreamListener? _backgroundImageListener;

  YogaValue? _height;
  YogaValue? _minWidth;
  YogaValue? _maxWidth;
  YogaValue? _minHeight;
  YogaValue? _maxHeight;

  // YogaItem 属性
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

  // 缓存属性以避免在 debugFillProperties 中调用 FFI
  int _flexDirection = YGFlexDirection.row; // 默认为 row 以匹配 CSS

  RenderYogaLayout() {
    _config = YogaConfig();
    _rootNode = YogaNode(_config);
    _rootNode.flexDirection = YGFlexDirection.row;
    _display = YogaDisplay.block; // 默认为 block
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

    // 注意：如果在布局之前调用，此处尺寸可能为零。
    // 如果配置需要尺寸，理想情况下我们应该在绘制或布局中解析。
    // 但是 ImageProvider 通常需要配置。
    // 如果尺寸发生变化，我们可以在绘制中重新解析。
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
      // 同时更新 Yoga 的根节点 display 属性
      if (value != null) {
        _rootNode.display = value == YogaDisplay.none
            ? YGDisplay.none
            : YGDisplay.flex;
      } else {
        _rootNode.display = YGDisplay.flex;
      }
      markNeedsLayout();
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

      // 将边框宽度应用于根节点，以便正确缩进内容
      if (value != null) {
        final resolved = value.resolve(TextDirection.ltr);
        final fb = resolved.toFlutterBorder();
        _rootNode.setBorder(YGEdge.top, fb.top.width);
        _rootNode.setBorder(YGEdge.right, fb.right.width);
        _rootNode.setBorder(YGEdge.bottom, fb.bottom.width);
        _rootNode.setBorder(YGEdge.left, fb.left.width);
      } else {
        // 如果 border 为 null 或 0，则回退到 borderWidth
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
    if (_flexDirection != value) {
      _flexDirection = value;
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
    // 如果需要（例如在 detach/attach 之后），重新解析背景图片
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
    // 仅当 _border 为 null 时应用。如果设置了 _border，则以其为准。
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

    // 始终在此布局上下文中为子级创建一个新节点。
    // 即使子级是 RenderYogaLayout，我们也将其视为黑盒（叶节点）
    // 在此布局树中，并通过回调对其进行测量。
    if (childParentData.yogaNode != null) {
      childParentData.yogaNode!.dispose();
    }
    childParentData.yogaNode = YogaNode(_config);

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
    // 我们不应该在这里销毁 _rootNode，因为 RenderObject 可能会被重新附加。
    // _rootNode 由 Finalizer 管理，因此当此对象被 GC 时，它将被释放。
    // 此外，_config 是静态且共享的，因此我们绝不能在这里销毁它。
    super.detach();
  }

  @override
  void performLayout() {
    if (_display == YogaDisplay.block) {
      size = _performCSSBlockLayout(constraints).size;
      return;
    }

    _syncRootConstraints(constraints);
    _syncChildren(dryRun: false);

    if (_enableMarginCollapsing) {
      _collapseMarginsRecursive(this);
    } else {
      // 如果禁用了合并，请确保重置外边距
      _resetMarginsRecursive(this);
    }

    // 3. 计算布局
    double availableWidth = double.nan;
    if (constraints.hasBoundedWidth) {
      availableWidth = constraints.maxWidth;
    }

    double availableHeight = double.nan;
    if (constraints.hasBoundedHeight) {
      final bool heightIsAuto =
          _height == null || _height!.unit == YogaUnit.auto;
      if (constraints.hasTightHeight || !heightIsAuto) {
        availableHeight = constraints.maxHeight;
      }
    }

    bool isFitContent =
        _width?.unit == YogaUnit.fitContent ||
        _width?.unit == YogaUnit.maxContent ||
        _width?.unit == YogaUnit.minContent ||
        _width == null ||
        _width?.unit == YogaUnit.auto;

    if ((_display == YogaDisplay.inline || isFitContent) &&
        constraints.hasBoundedWidth &&
        !constraints.hasTightWidth) {
      // 对于具有宽松约束的 inline display 或 fit-content（包括 auto），我们需要“收缩以适应”的行为。
      // 首先，尝试使用未定义的宽度进行测量以获取内容宽度。
      _rootNode.calculateLayout(
        availableWidth: double.nan,
        availableHeight: availableHeight,
      );

      // 如果内容宽度超过可用宽度，我们需要重新布局
      // 使用强制换行的约束。
      if (_rootNode.layoutWidth > availableWidth) {
        _rootNode.calculateLayout(
          availableWidth: availableWidth,
          availableHeight: availableHeight,
        );
      }
    } else {
      _rootNode.calculateLayout(
        availableWidth: availableWidth,
        availableHeight: availableHeight,
      );
    }

    // 4. 将布局应用于子级
    RenderBox? child = firstChild;
    while (child != null) {
      final childParentData = child.parentData as YogaLayoutParentData;
      final childNode = childParentData.yogaNode!;

      final double x = childNode.left;
      final double y = childNode.top;
      final double w = childNode.layoutWidth;
      final double h = childNode.layoutHeight;

      // 如果出现问题或尺寸未定义，Yoga 可能会返回 NaN。
      // 我们必须确保向 Flutter 传递有效的约束。
      final double safeW = w.isNaN ? 0.0 : w;
      final double safeH = h.isNaN ? 0.0 : h;

      // 我们必须使用 Yoga 给出的精确约束对子级进行布局
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

    // 注意：外边距合并在节点上是有状态的（修改外边距）。
    // 我们可能也应该为 dry layout 运行它以获得准确的尺寸，
    // 但如果 performLayout 期望干净的状态，我们必须小心不要让节点处于不良状态。
    // 但是，如果禁用了合并，performLayout 会通过 _resetMarginsRecursive 重置外边距，
    // 或者重新运行合并。
    // 所以在这里运行它应该是没问题的。
    if (_enableMarginCollapsing) {
      _collapseMarginsRecursive(this);
    } else {
      _resetMarginsRecursive(this);
    }

    if (_display == YogaDisplay.block) {
      return _performCSSBlockLayout(constraints, dryRun: true).size;
    }

    double availableWidth = double.nan;
    if (constraints.hasBoundedWidth) {
      availableWidth = constraints.maxWidth;
    }

    double availableHeight = double.nan;
    if (constraints.hasBoundedHeight) {
      final bool heightIsAuto =
          _height == null || _height!.unit == YogaUnit.auto;
      if (constraints.hasTightHeight || !heightIsAuto) {
        availableHeight = constraints.maxHeight;
      }
    }

    bool isFitContent =
        _width?.unit == YogaUnit.fitContent ||
        _width?.unit == YogaUnit.maxContent ||
        _width?.unit == YogaUnit.minContent ||
        _width == null ||
        _width?.unit == YogaUnit.auto;

    if ((_display == YogaDisplay.inline || isFitContent) &&
        constraints.hasBoundedWidth &&
        !constraints.hasTightWidth) {
      _rootNode.calculateLayout(
        availableWidth: double.nan,
        availableHeight: availableHeight,
      );

      if (_rootNode.layoutWidth > availableWidth) {
        _rootNode.calculateLayout(
          availableWidth: availableWidth,
          availableHeight: availableHeight,
        );
      }
    } else {
      _rootNode.calculateLayout(
        availableWidth: availableWidth,
        availableHeight: availableHeight,
      );
    }

    final double rootW = _rootNode.layoutWidth;
    final double rootH = _rootNode.layoutHeight;

    return constraints.constrain(
      Size(rootW.isNaN ? 0.0 : rootW, rootH.isNaN ? 0.0 : rootH),
    );
  }

  void _syncRootConstraints(BoxConstraints constraints) {
    // 如果约束是紧密的，我们必须是那个尺寸。
    // 这会覆盖任何用户指定的宽度/高度（尤其是百分比），
    // 因为父级已经将这些百分比解析为此紧密约束。
    // 如果我们不这样做，calculateLayout 可能会再次针对约束解析百分比，
    // 导致双重缩放（例如 50% 的 50% = 25%）。

    if (constraints.hasTightWidth) {
      _rootNode.width = constraints.maxWidth;
    } else if (_width != null) {
      _applyWidth(_rootNode, _width!);
    } else {
      // 对于 inline 和 block，当约束宽松时，我们默认为 Auto（内容宽度）。
      // 这确保了当作为 flex 项目进行测量时，我们报告内容大小而不是扩展以填充可用空间。
      // 要获得“填充宽度”行为（类似 Block），请使用 width: 100% 或 align-self: stretch。
      _rootNode.setWidthAuto();
    }

    if (constraints.hasTightHeight) {
      _rootNode.height = constraints.maxHeight;
    } else if (_height != null) {
      _applyHeight(_rootNode, _height!);
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

      // 解析有效属性（ParentData > 子 RenderObject 属性）
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

      // 1. 同步基本布局属性
      if (width != null) {
        _applyWidth(childNode, width);
      } else {
        // 如果 width 为 null，我们不会在这里重置它，因为它可能是 auto/undefined
        // 但是如果未设置，我们可能应该确保它是 auto？
        // 如果为 null，YogaItem 会将其设置为 auto。
        // 让我们假设如果 parentData 中为 null，它应该是 auto。
        // 在 Flex 布局 (Yoga) 中，子级是 flex 项目。
        // Flex 项目默认为 auto 宽度（内容大小），而不是 100% 宽度，
        // 即使它们是块级元素。
        childNode.setWidthAuto();
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
        childNode.flexGrow = 0; // 默认
      }

      if (flexShrink != null) {
        childNode.flexShrink = flexShrink;
      } else {
        // 默认（Yoga 默认为 0，Web 为 1）
        childNode.flexShrink = _useWebDefaults ? 1 : 0;
      }

      if (flexBasis != null) {
        childNode.flexBasis = flexBasis;
      } else {
        childNode.setFlexBasisAuto();
      }

      if (alignSelf != null) {
        childNode.alignSelf = alignSelf;
      } else {
        childNode.alignSelf = YGAlign.auto;
      }

      if (display != null) {
        childNode.display = display == YogaDisplay.none
            ? YGDisplay.none
            : YGDisplay.flex;
      } else {
        childNode.display = YGDisplay.flex;
      }

      // 2. 同步外边距
      _setMarginEdge(childNode, YGEdge.left, margin?.left);
      _setMarginEdge(childNode, YGEdge.top, margin?.top);
      _setMarginEdge(childNode, YGEdge.right, margin?.right);
      _setMarginEdge(childNode, YGEdge.bottom, margin?.bottom);

      // 3. 将边框宽度应用于 YogaNode
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

      // 4. 应用盒模型（Content-Box 调整）
      if (boxSizing == YogaBoxSizing.contentBox) {
        if (width != null && width.unit == YogaUnit.point) {
          childNode.width = width.value + borderLeft + borderRight;
        }
        if (height != null && height.unit == YogaUnit.point) {
          childNode.height = height.value + borderTop + borderBottom;
        }
      } else {
        // 重新应用宽度/高度以确保它不是来自先前 content-box 计算的陈旧值
        if (width != null && width.unit == YogaUnit.point) {
          childNode.width = width.value;
        }
        if (height != null && height.unit == YogaUnit.point) {
          childNode.height = height.value;
        }
      }

      // 5. 如果需要，测量子级
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

      if (true) {
        final RenderBox currentChild = child;

        if (!widthIsSet || !heightIsSet) {
          childNode.setMeasureFunc((
            YogaNode node,
            double width,
            int widthMode,
            double height,
            int heightMode,
          ) {
            try {
              double minWidth = 0.0;
              double maxWidth = double.infinity;

              if (widthMode == YGMeasureMode.exactly) {
                minWidth = width.isNaN ? 0.0 : width;
                maxWidth = width.isNaN ? 0.0 : width;
              } else if (widthMode == YGMeasureMode.atMost) {
                // 如果子级是 auto 宽度（flex 项目），我们将 AtMost 视为 Undefined (Infinite)
                // 以允许它报告其 max-content 大小。
                // 这可以防止 Yoga 尝试使用可用空间进行测量时过早换行。
                bool isAutoWidth = false;
                if (currentChild.parentData is YogaLayoutParentData) {
                  final pd = currentChild.parentData as YogaLayoutParentData;
                  isAutoWidth =
                      pd.width == null || pd.width!.unit == YogaUnit.auto;
                }

                if (isAutoWidth) {
                  maxWidth = double.infinity;
                } else {
                  maxWidth = width.isNaN ? double.infinity : width;
                }
              }

              double minHeight = 0.0;
              double maxHeight = double.infinity;

              if (heightMode == YGMeasureMode.exactly) {
                minHeight = height.isNaN ? 0.0 : height;
                maxHeight = height.isNaN ? 0.0 : height;
              } else if (heightMode == YGMeasureMode.atMost) {
                maxHeight = height.isNaN ? double.infinity : height;
              }

              final constraints = BoxConstraints(
                minWidth: minWidth,
                maxWidth: maxWidth,
                minHeight: minHeight,
                maxHeight: maxHeight,
              );

              return currentChild.getDryLayout(constraints);
            } catch (e) {
              // 如果 dry layout 失败，则回退到固有特性
              try {
                final w = currentChild.getMinIntrinsicWidth(double.infinity);
                final h = currentChild.getMinIntrinsicHeight(w);
                return Size(w, h);
              } catch (e2) {
                return Size.zero;
              }
            }
          });

          // 如果子级需要布局（例如图片已加载、文本已更改），我们必须将 Yoga 节点标记为脏
          // 以便 Yoga 再次调用测量函数。
          if (currentChild.debugNeedsLayout) {
            childNode.markDirty();
          }
        } else {
          childNode.setMeasureFunc(null);
        }
      }

      child = childParentData.nextSibling;
    }
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return computeDryLayout(
      BoxConstraints(
        minWidth: 0,
        maxWidth: 0,
        minHeight: height,
        maxHeight: height,
      ),
    ).width;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    if (_display == YogaDisplay.block) {
      double contentW = _computeBlockMaxContentWidth();

      double paddingHorizontal = 0;
      if (_padding != null) {
        if (_padding!.left.unit == YogaUnit.point) {
          paddingHorizontal += _padding!.left.value;
        }
        if (_padding!.right.unit == YogaUnit.point) {
          paddingHorizontal += _padding!.right.value;
        }
      }

      double borderHorizontal = _borderWidth.horizontal;
      if (_border != null) {
        borderHorizontal = _border!
            .resolve(TextDirection.ltr)
            .toFlutterBorder()
            .dimensions
            .horizontal;
      }

      return contentW + paddingHorizontal + borderHorizontal;
    }

    return computeDryLayout(
      BoxConstraints(
        minWidth: 0,
        maxWidth: double.infinity,
        minHeight: height,
        maxHeight: height,
      ),
    ).width;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return computeDryLayout(
      BoxConstraints(
        minWidth: width,
        maxWidth: width,
        minHeight: 0,
        maxHeight: 0,
      ),
    ).height;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return computeDryLayout(
      BoxConstraints(
        minWidth: width,
        maxWidth: width,
        minHeight: 0,
        maxHeight: double.infinity,
      ),
    ).height;
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
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<YogaDisplay>('display', _display));
    properties.add(IntProperty('flexDirection', _flexDirection));
    properties.add(IntProperty('justifyContent', _justifyContent));
    properties.add(IntProperty('alignItems', _alignItems));
    properties.add(EnumProperty<TextAlign>('textAlign', _textAlign));
    properties.add(IntProperty('alignSelf', _alignSelf));
    properties.add(DoubleProperty('flexGrow', _flexGrow));
    properties.add(DoubleProperty('flexShrink', _flexShrink));
    properties.add(DoubleProperty('flexBasis', _flexBasis));

    properties.add(DiagnosticsProperty<YogaValue>('width', _width));
    properties.add(DiagnosticsProperty<YogaValue>('height', _height));
    properties.add(DiagnosticsProperty<YogaValue>('minWidth', _minWidth));
    properties.add(DiagnosticsProperty<YogaValue>('maxWidth', _maxWidth));
    properties.add(DiagnosticsProperty<YogaValue>('minHeight', _minHeight));
    properties.add(DiagnosticsProperty<YogaValue>('maxHeight', _maxHeight));

    properties.add(DiagnosticsProperty<YogaEdgeInsets>('padding', _padding));
    properties.add(DiagnosticsProperty<YogaEdgeInsets>('margin', _margin));
    properties.add(DiagnosticsProperty<YogaBorder>('border', _border));

    properties.add(
      DiagnosticsProperty<YogaBackground>('background', _background),
    );
    properties.add(
      DiagnosticsProperty<List<YogaBoxShadow>>('boxShadow', _boxShadow),
    );
    properties.add(EnumProperty<YogaBoxSizing>('boxSizing', _boxSizing));
    properties.add(EnumProperty<YogaOverflow>('overflow', _overflow));
    properties.add(TransformProperty('transform', _transform));
    properties.add(
      DiagnosticsProperty<AlignmentGeometry>(
        'transformOrigin',
        _transformOrigin,
      ),
    );
  }

  void _paintSelfWithDecoration(PaintingContext context, Offset offset) {
    // 0. 背景
    if (_background != null) {
      _paintBackground(context, offset, size, _background!);
    }

    // 1. 阴影
    if (_boxShadow != null) {
      _paintShadows(context, offset, size, _boxShadow!);
    }

    // 2. 裁剪（溢出）和子级
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

    // 3. 边框
    if (_border != null) {
      // 我们目前不支持根节点上的边框图片（RenderObject 中未存储 ImageInfo）
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

    // 创建有效的变换矩阵
    // 我们想要围绕原点进行变换。
    // 传入 transform 的矩阵通常只是旋转/缩放。
    // 我们需要：Translate(origin) -> Transform -> Translate(-origin)

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
    // 绘制阴影
    if (childParentData.boxShadow != null) {
      _paintShadows(
        context,
        paintOffset,
        child.size,
        childParentData.boxShadow!,
      );
    }

    // 绘制子级
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

    // 绘制边框
    if (childParentData.border != null) {
      // 如果存在边框图片，则解析它（现在子级已布局）
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
    // 解析边框（目前假设为 LTR，理想情况下应传递 TextDirection）
    final resolvedBorder = border.resolve(TextDirection.ltr);

    // 如果可用，绘制边框图片
    if (border.image != null && borderImageInfo != null) {
      _paintBorderImage(context, offset, size, border.image!, borderImageInfo);
      return; // 如果绘制了边框图片，我们是否绘制标准边框？CSS 规定 border-image 替换 border-style。
    }

    // 检查是否需要自定义绘制（点线/虚线）
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
      // 对 solid/none 使用 Flutter 的优化边框绘制
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

    // 绘制单边的辅助函数
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

    // 我们将边绘制为线。
    // 为了避免半透明颜色在角落处的重叠问题，我们可能需要更复杂的逻辑。
    // 但对于虚线/点线，简单的线条通常是 Flutter 中“类 CSS”行为的可接受近似值
    // 而无需为每个虚线实现完整的梯形路径裁剪。

    // 上
    if (border.top.width != null && border.top.width! > 0) {
      paintSide(
        border.top,
        rect.topLeft.translate(0, border.top.width! / 2),
        rect.topRight.translate(0, border.top.width! / 2),
        true,
      );
    }

    // 右
    if (border.right.width != null && border.right.width! > 0) {
      paintSide(
        border.right,
        rect.topRight.translate(-border.right.width! / 2, 0),
        rect.bottomRight.translate(-border.right.width! / 2, 0),
        false,
      );
    }

    // 下
    if (border.bottom.width != null && border.bottom.width! > 0) {
      paintSide(
        border.bottom,
        rect.bottomLeft.translate(0, -border.bottom.width! / 2),
        rect.bottomRight.translate(0, -border.bottom.width! / 2),
        true,
      );
    }

    // 左
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

    // 由于它是统一的，我们采用顶边属性
    final double width = border.top.width ?? 1.0;
    final Color color = border.top.color ?? const Color(0xFF000000);
    final YogaBorderStyle style = border.top.style ?? YogaBorderStyle.solid;

    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..style = PaintingStyle.stroke;

    // 缩小一半宽度以在边框区域内描边（以内嵌线为中心）
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
    // CSS 虚线：通常是 3*width 实线，3*width 间隙（或类似）
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
    // CSS 点线：直径 = width 的圆，间隔为 width（或更小）
    // 我们对点使用圆形笔帽
    final Paint dotPaint = Paint()
      ..color = paint.color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final double distance = (p2 - p1).distance;
    final double dx = (p2.dx - p1.dx) / distance;
    final double dy = (p2.dy - p1.dy) / distance;

    // 间距：直径 (width) + 间隙 (width) = 2*width
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

    // 1. 解析切片（源）
    final double sliceL = _resolveValue(borderImage.slice.left, imgW);
    final double sliceT = _resolveValue(borderImage.slice.top, imgH);
    final double sliceR = _resolveValue(borderImage.slice.right, imgW);
    final double sliceB = _resolveValue(borderImage.slice.bottom, imgH);

    // 2. 解析外扩
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

    // 3. 解析边框宽度（目标）
    // 如果可用，使用 borderImage.width，否则回退到切片大小（如果未设置宽度，这是常见行为）
    // 或者如果我们想要严格，则为 0。对于此实现，我们使用提供的宽度或切片。
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

    // 源矩形
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

    // 目标矩形
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

    // 绘制角落（始终拉伸/缩放以适应角落框）
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

    // 绘制边缘
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

    // 绘制中心
    if (borderImage.fill) {
      // 对于中心，理想情况下我们应该在两个方向上平铺。
      // 目前，我们只是拉伸或简单平铺。
      // 实现中心的完整 2D 平铺很复杂，并且很少用于复杂的重复。
      // 让我们暂时使用拉伸作为简化，或者使用 paintImage。
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
      // 居中平铺
      if (isHorizontal) {
        double x = dst.center.dx - srcW / 2;
        // 绘制中心一个
        canvas.drawImageRect(
          image,
          src,
          Rect.fromLTWH(x, dst.top, srcW, dstH),
          Paint(),
        );

        // 绘制左侧
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

        // 绘制右侧
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
        // 垂直居中平铺
        double y = dst.center.dy - srcH / 2;
        canvas.drawImageRect(
          image,
          src,
          Rect.fromLTWH(dst.left, y, dstW, srcH),
          Paint(),
        );

        // 向上绘制
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

        // 向下绘制
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
      // Space 或其他，回退到拉伸
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

      // 我们目前假设为矩形阴影，因为 YogaItem 不知道 borderRadius。
      // 如果我们需要圆形阴影，我们需要将 borderRadius 添加到 YogaItem。
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

  @override
  bool get isRepaintBoundary {
    return _display == YogaDisplay.block;
  }

  void _resetMarginsRecursive(RenderYogaLayout renderLayout) {
    RenderBox? child = renderLayout.firstChild;
    while (child != null) {
      final childParentData = child.parentData as YogaLayoutParentData;
      // 重置有效外边距
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
    // 1. 首先递归（后序遍历）
    RenderBox? child = renderLayout.firstChild;
    while (child != null) {
      final childParentData = child.parentData as YogaLayoutParentData;

      // 重置此子级的外边距
      childParentData.effectiveMargin = null;
      if (childParentData.yogaNode != null) {
        _resetMargins(childParentData.yogaNode!, childParentData.margin);
      }

      if (child is RenderYogaLayout) {
        _collapseMarginsRecursive(child);
      }
      child = childParentData.nextSibling;
    }

    // 2. 应用兄弟合并（我的子级）
    renderLayout._applySiblingCollapsing();

    // 3. 应用父子合并（我和我的子级）
    renderLayout._applyParentChildCollapsing();
  }

  EdgeInsets _getEffectiveMargin(YogaLayoutParentData pd) {
    // 如果可能，将 YogaEdgeInsets 转换为 EdgeInsets 以进行计算
    // 注意：我们只能在 Dart 中合并点值。
    // 如果外边距是百分比，我们在不知道父级宽度的情况下无法轻松地在此处合并它。
    // 所以我们回退到 0 或任何安全的值。

    // 如果设置了 effectiveMargin，请使用它。
    if (pd.effectiveMargin != null) return pd.effectiveMargin!;

    // 否则转换 pd.margin
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
    // 外边距合并仅适用于垂直流（column/column-reverse）
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

        // 如果任一外边距基于百分比，则跳过合并
        if ((childParentData.margin?.bottom.unit == YogaUnit.percent) ||
            (nextParentData.margin?.top.unit == YogaUnit.percent)) {
          child = nextChild;
          continue;
        }

        // 获取有效外边距
        final marginBottom = _getEffectiveMargin(childParentData).bottom;
        final marginTop = _getEffectiveMargin(nextParentData).top;

        // 计算合并后的外边距
        final collapsedMargin = _collapse(marginBottom, marginTop);

        // 应用于节点并更新有效外边距
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

    // 顶部合并
    if (_isZero(_padding?.top) && _borderWidth.top == 0) {
      final firstChild = this.firstChild;
      if (firstChild != null) {
        final childParentData = firstChild.parentData as YogaLayoutParentData;
        final childNode = childParentData.yogaNode!;

        // 如果子级具有百分比顶部外边距，则跳过
        if (childParentData.margin?.top.unit == YogaUnit.percent) {
          // 什么也不做
        } else {
          // 我的顶部外边距
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

    // 底部合并
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

        // 如果子级具有百分比底部外边距，则跳过
        if (childParentData.margin?.bottom.unit == YogaUnit.percent) {
          // 什么也不做
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
        // Yoga 没有 setPaddingAuto。
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
      // 两者都为正：取最大值
      return math.max(m1, m2);
    } else if (m1 < 0 && m2 < 0) {
      // 两者都为负：取最小值（最负）
      return math.min(m1, m2);
    } else {
      // 一正一负：求和
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
        // 在 Row 中，textAlign 映射到 justifyContent
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
        // 在 Column 中，textAlign 映射到 alignItems
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

    // 1. 背景颜色
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

    // 2. 背景图片
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

    // 调整原点
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

    // 裁剪到边框半径
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
      // 如果是显式尺寸，我们计算目标矩形尺寸
      double w = _resolveValue(background.size.width, positioningArea.width);
      double h = _resolveValue(background.size.height, positioningArea.height);

      // 如果是 auto，使用图片尺寸
      if (background.size.width.unit == YogaUnit.auto) {
        w = imageInfo.image.width.toDouble();
      }
      if (background.size.height.unit == YogaUnit.auto) {
        h = imageInfo.image.height.toDouble();
      }

      // 如果是 no-repeat，我们可以通过调整 drawingRect 来模拟显式尺寸
      if (background.repeat == ImageRepeat.noRepeat) {
        // 在 positioningArea 内对齐较小的矩形
        drawingRect = alignment.inscribe(Size(w, h), positioningArea);
        fit = BoxFit.fill;
        alignment = Alignment.center; // 已通过 inscribe 对齐
      } else {
        // 如果是 repeat，paintImage 会忽略 fit/size。
        // 我们无法使用 paintImage 轻松支持带有 repeat 的显式尺寸。
        // 回退到 auto/none。
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
          // 使用 scaleDown 确保图片即使比容器大也可见，
          // 如果较小，则表现得像 none（原始尺寸）。
          fit = BoxFit.scaleDown;
          break;
      }
    }

    // 调试打印
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
      // 在不知道尺寸的情况下，Alignment 不容易支持点。
      // 但是 paintImage 使用 Alignment 在 rect 内定位。
      // 如果我们有点，在没有尺寸的情况下无法映射到 -1..1。
      // 但我们可以近似或默认为 center/start。
      // 如果是点，让我们假设为 0。
      x = -1.0;
    }

    if (pos.y.unit == YogaUnit.percent) {
      y = (pos.y.value * 2 / 100) - 1.0;
    } else if (pos.y.unit == YogaUnit.point) {
      y = -1.0;
    }

    return Alignment(x, y);
  }

  double? _resolveDimension(YogaValue? value, double parentSize) {
    if (value == null) return null;
    switch (value.unit) {
      case YogaUnit.point:
        return value.value;
      case YogaUnit.percent:
        return value.value * parentSize / 100.0;
      case YogaUnit.auto:
      case YogaUnit.undefined:
      case YogaUnit.maxContent:
      case YogaUnit.minContent:
      case YogaUnit.fitContent:
        return null;
    }
  }

  double _computeBlockMaxContentWidth() {
    double maxContentW = 0;
    double currentLineW = 0;
    RenderBox? tempChild = firstChild;

    while (tempChild != null) {
      final tempPd = tempChild.parentData as YogaLayoutParentData;
      double childIntrinsicWidth = tempChild.getMaxIntrinsicWidth(
        double.infinity,
      );

      // 添加外边距（仅固定点，auto 为 0）
      EdgeInsets tempMargin = _getEffectiveMargin(tempPd);
      double totalChildW =
          childIntrinsicWidth + tempMargin.left + tempMargin.right;

      // 检查子级是否为 inline
      bool isInline = false;
      if (tempPd.display == YogaDisplay.inline ||
          tempPd.display == YogaDisplay.inlineBlock) {
        isInline = true;
      } else if (tempPd.display == null) {
        // 如果未指定，则默认为 inline（例如 Text 组件）
        // 但是等等，RenderYogaLayout 如果未指定则默认为 block？
        // 不，在 _performCSSBlockLayout 中，对于非显式 block，我们默认为 inline。
        // 让我们匹配那个逻辑。
        if (tempChild is RenderYogaLayout) {
          // 如果 display 为 null，嵌套的 YogaLayout 默认为 block
          isInline = false;
        } else {
          // 其他组件（Text, Image）默认为 inline
          isInline = true;
        }
      }

      if (isInline) {
        currentLineW += totalChildW;
      } else {
        // 块级元素换行
        if (currentLineW > maxContentW) {
          maxContentW = currentLineW;
        }
        currentLineW = 0;

        if (totalChildW > maxContentW) {
          maxContentW = totalChildW;
        }
      }

      tempChild = tempPd.nextSibling;
    }

    // 检查最后一行
    if (currentLineW > maxContentW) {
      maxContentW = currentLineW;
    }

    // 添加一个小的 epsilon 以防止亚像素换行问题
    return maxContentW + 0.5;
  }

  @override
  double? computeDryBaseline(
    BoxConstraints constraints,
    TextBaseline baseline,
  ) {
    if (_display == YogaDisplay.block) {
      return _performCSSBlockLayout(constraints, dryRun: true).baseline;
    }
    // 对于 Flex 布局，如果不进行完整布局，我们无法轻松计算 dry baseline
    // 除非我们复制 Yoga 的逻辑。
    // 目前，返回 null，这是默认行为。
    return null;
  }

  YogaLayoutResult _performCSSBlockLayout(
    BoxConstraints constraints, {
    bool dryRun = false,
  }) {
    // 解析内边距和边框
    final double paddingLeft = _resolveValue(
      _padding?.left ?? YogaValue.zero,
      constraints.maxWidth,
    );
    final double paddingTop = _resolveValue(
      _padding?.top ?? YogaValue.zero,
      constraints.maxWidth,
    );
    final double paddingRight = _resolveValue(
      _padding?.right ?? YogaValue.zero,
      constraints.maxWidth,
    );
    final double paddingBottom = _resolveValue(
      _padding?.bottom ?? YogaValue.zero,
      constraints.maxWidth,
    );

    final EdgeInsets border =
        _border?.resolve(TextDirection.ltr).toFlutterBorder().dimensions
            as EdgeInsets? ??
        _borderWidth;

    final double contentLeft = paddingLeft + border.left;
    final double contentTop = paddingTop + border.top;
    final double contentRight = paddingRight + border.right;
    final double contentBottom = paddingBottom + border.bottom;

    // 如果设置，解析显式尺寸
    double? resolvedParentWidth = _resolveDimension(
      _width,
      constraints.maxWidth,
    );
    double? resolvedParentHeight = _resolveDimension(
      _height,
      constraints.maxHeight,
    );

    double availableWidth =
        (resolvedParentWidth ?? constraints.maxWidth) -
        contentLeft -
        contentRight;
    if (availableWidth < 0) availableWidth = 0;

    double availableHeight =
        (resolvedParentHeight ?? constraints.maxHeight) -
        contentTop -
        contentBottom;
    if (availableHeight < 0) availableHeight = 0;

    // 检查我们是否为 flex 项目（Flex 容器的子级）
    bool isFlexItem = false;
    if (parent is RenderYogaLayout) {
      isFlexItem = (parent as RenderYogaLayout)._display == YogaDisplay.flex;
    }

    // 预处理：如果我们是 fit-content，则从子级计算固有宽度
    bool isSelfFitContent =
        _width?.unit == YogaUnit.fitContent ||
        _width?.unit == YogaUnit.maxContent ||
        _width?.unit == YogaUnit.minContent ||
        (isFlexItem && (_width == null || _width?.unit == YogaUnit.auto));

    if (isSelfFitContent && !constraints.hasTightWidth) {
      double maxContentW = _computeBlockMaxContentWidth();

      // 收缩 availableWidth 以适应内容，但遵守约束
      if (availableWidth > maxContentW) {
        availableWidth = maxContentW;
      }
    }

    double cursorX = 0;
    double cursorY = 0;
    double previousBottomMargin = 0;
    double currentLineHeight = 0;

    // 跟踪当前行的基线
    double maxAscent = 0;

    // 跟踪 fit-content/auto 宽度的最大内容宽度
    double maxContentWidth = 0;

    RenderBox? child = firstChild;
    List<RenderBox> currentLineChildren = [];
    Map<RenderBox, Size> childSizes = {};
    Map<RenderBox, double?> childBaselines = {};

    void flushLine() {
      if (currentLineChildren.isEmpty) return;

      // 使用当前行宽更新 maxContentWidth
      if (cursorX > maxContentWidth) {
        maxContentWidth = cursorX;
      }

      // 如果我们正在刷新一行，它从上一个块的底部外边距之后开始。
      cursorY += previousBottomMargin;
      previousBottomMargin = 0;

      // 计算对齐偏移
      // 注意：text-align 应该只影响行内内容（inline flow）。
      // 如果这一行包含 Block 元素，通常不应该应用 text-align（除非它是 inline-block）。
      // 但在这里，我们把所有非 Block 的东西都视为行内流的一部分。
      // 如果 currentLineChildren 中有 Block 元素，flushLine 会在它之前被调用，
      // 所以 currentLineChildren 应该只包含 inline/inline-block 元素。
      // 唯一的例外是如果 Block 元素本身是 inline-block。

      double alignmentOffset = 0;
      if (_textAlign != null && availableWidth.isFinite) {
        double freeSpace = availableWidth - cursorX;
        if (freeSpace > 0) {
          switch (_textAlign!) {
            case TextAlign.center:
              alignmentOffset = freeSpace / 2;
              break;
            case TextAlign.right:
            case TextAlign.end:
              alignmentOffset = freeSpace;
              break;
            default:
              break;
          }
        }
      }

      for (final lineChild in currentLineChildren) {
        final pd = lineChild.parentData as YogaLayoutParentData;
        final childMargin = _getEffectiveMargin(pd);
        final Size childSize = childSizes[lineChild]!;

        double childY = cursorY;

        if (_alignItems == YGAlign.baseline) {
          final double distanceToBaseline =
              childBaselines[lineChild] ?? childSize.height;
          childY += (maxAscent - distanceToBaseline);
          childY += childMargin.top;
        } else {
          childY += childMargin.top;
        }

        if (!dryRun) {
          pd.offset = Offset(
            contentLeft + pd.offset.dx + alignmentOffset,
            contentTop + childY,
          );
        }
      }

      cursorY += currentLineHeight;
      cursorX = 0;
      currentLineHeight = 0;
      maxAscent = 0;
      currentLineChildren.clear();
    }

    while (child != null) {
      final childParentData = child.parentData as YogaLayoutParentData;

      // 解析有效属性
      YogaValue? width = childParentData.width;
      YogaValue? height = childParentData.height;
      YogaValue? minWidth = childParentData.minWidth;
      YogaValue? maxWidth = childParentData.maxWidth;
      YogaValue? minHeight = childParentData.minHeight;
      YogaValue? maxHeight = childParentData.maxHeight;
      YogaDisplay? display = childParentData.display;
      YogaEdgeInsets? margin = childParentData.margin;

      if (child is RenderYogaLayout) {
        width ??= child._width;
        height ??= child._height;
        minWidth ??= child._minWidth;
        maxWidth ??= child._maxWidth;
        minHeight ??= child._minHeight;
        maxHeight ??= child._maxHeight;
        display ??= child._display;
        margin ??= child._margin;
      }

      if (display == YogaDisplay.none) {
        child = childParentData.nextSibling;
        continue;
      }

      EdgeInsets childMargin;
      if (childParentData.effectiveMargin != null) {
        childMargin = childParentData.effectiveMargin!;
      } else {
        childMargin = margin == null
            ? EdgeInsets.zero
            : EdgeInsets.only(
                left: margin.left.unit == YogaUnit.point
                    ? margin.left.value
                    : 0,
                top: margin.top.unit == YogaUnit.point ? margin.top.value : 0,
                right: margin.right.unit == YogaUnit.point
                    ? margin.right.value
                    : 0,
                bottom: margin.bottom.unit == YogaUnit.point
                    ? margin.bottom.value
                    : 0,
              );
      }

      bool isBlock =
          display == YogaDisplay.block || display == YogaDisplay.flex;
      if (display == null) {
        // 在 CSS 块级布局中，我们默认为 inline 以支持文本自然流动。
        // 显式块级元素（如嵌套的 YogaLayouts）将设置 display: block。
        isBlock = false;
      }

      // 如果嵌套的 RenderYogaLayouts 未显式设置为 inline，则强制其为 block 行为
      if (child is RenderYogaLayout &&
          display != YogaDisplay.inline &&
          display != YogaDisplay.inlineBlock) {
        isBlock = true;
      }

      BoxConstraints childConstraints;

      double? resolvedWidth = _resolveDimension(width, availableWidth);
      double? resolvedHeight = _resolveDimension(height, availableHeight);
      double? resolvedMinWidth = _resolveDimension(minWidth, availableWidth);
      double? resolvedMaxWidth = _resolveDimension(maxWidth, availableWidth);
      double? resolvedMinHeight = _resolveDimension(minHeight, availableHeight);
      double? resolvedMaxHeight = _resolveDimension(maxHeight, availableHeight);

      if (isBlock) {
        double childAvailableWidth =
            availableWidth - childMargin.left - childMargin.right;
        if (childAvailableWidth < 0) childAvailableWidth = 0;

        bool isFitContent = width?.unit == YogaUnit.fitContent;
        bool isMaxContent = width?.unit == YogaUnit.maxContent;
        bool isMinContent = width?.unit == YogaUnit.minContent;

        double minW;
        double maxW;

        if (isFitContent || isMinContent || isMaxContent) {
          double minIntrinsic = child.getMinIntrinsicWidth(double.infinity);

          if (isMinContent) {
            minW = minIntrinsic;
            maxW = minIntrinsic;
          } else if (isMaxContent) {
            minW = minIntrinsic;
            maxW = double.infinity;
          } else {
            // fit-content (适应内容)
            minW = minIntrinsic;
            maxW = math.max(childAvailableWidth, minIntrinsic);
          }
        } else {
          if (resolvedWidth == null && childAvailableWidth.isInfinite) {
            minW = 0;
            maxW = double.infinity;
          } else {
            double targetWidth = resolvedWidth ?? childAvailableWidth;
            minW = targetWidth;
            maxW = targetWidth;
          }
        }

        if (resolvedMinWidth != null) {
          if (minW < resolvedMinWidth) minW = resolvedMinWidth;
          if (maxW < resolvedMinWidth) maxW = resolvedMinWidth;
        }
        if (resolvedMaxWidth != null) {
          if (maxW > resolvedMaxWidth) maxW = resolvedMaxWidth;
          if (minW > resolvedMaxWidth) minW = resolvedMaxWidth;
        }

        if (minW > maxW) {
          maxW = minW;
        }

        double minH = resolvedMinHeight ?? 0;
        double maxH = resolvedMaxHeight ?? availableHeight;
        if (resolvedHeight != null) {
          minH = resolvedHeight;
          maxH = resolvedHeight;
        }

        // 健全性检查以防止导致 Flutter 崩溃的无限 minHeight
        if (minH.isInfinite) {
          minH = 0;
        }

        childConstraints = BoxConstraints(
          minWidth: minW,
          maxWidth: maxW,
          minHeight: minH,
          maxHeight: maxH,
        );
      } else {
        // 行内元素
        bool isFitContent = width?.unit == YogaUnit.fitContent;
        bool isMaxContent = width?.unit == YogaUnit.maxContent;
        bool isMinContent = width?.unit == YogaUnit.minContent;

        double minW;
        double maxW;

        if (isFitContent || isMinContent || isMaxContent) {
          double minIntrinsic = child.getMinIntrinsicWidth(double.infinity);

          if (isMinContent) {
            minW = minIntrinsic;
            maxW = minIntrinsic;
          } else if (isMaxContent) {
            minW = minIntrinsic;
            maxW = double.infinity;
          } else {
            // fit-content (适应内容)
            minW = minIntrinsic;
            maxW = math.max(availableWidth, minIntrinsic);
          }
        } else if (resolvedWidth != null) {
          minW = resolvedWidth;
          maxW = resolvedWidth;
        } else {
          minW = resolvedMinWidth ?? 0;
          maxW = resolvedMaxWidth ?? availableWidth;
        }

        if (resolvedMinWidth != null) {
          if (minW < resolvedMinWidth) minW = resolvedMinWidth;
          if (maxW < resolvedMinWidth) maxW = resolvedMinWidth;
        }
        if (resolvedMaxWidth != null) {
          if (maxW > resolvedMaxWidth) maxW = resolvedMaxWidth;
          if (minW > resolvedMaxWidth) minW = resolvedMaxWidth;
        }

        if (minW > maxW) {
          maxW = minW;
        }

        double minH = resolvedMinHeight ?? 0;
        double maxH = resolvedMaxHeight ?? availableHeight;
        if (resolvedHeight != null) {
          minH = resolvedHeight;
          maxH = resolvedHeight;
        }

        // 健全性检查以防止导致 Flutter 崩溃的无限 minHeight
        if (minH.isInfinite) {
          minH = 0;
        }

        childConstraints = BoxConstraints(
          minWidth: minW,
          maxWidth: maxW,
          minHeight: minH,
          maxHeight: maxH,
        );
      }

      if (dryRun) {
        child.getDryLayout(childConstraints);
      } else {
        child.layout(childConstraints, parentUsesSize: true);
      }

      final Size childSize = dryRun
          ? child.getDryLayout(childConstraints)
          : child.size;
      childSizes[child] = childSize;

      final double childW = childSize.width;
      final double childH = childSize.height;
      final double totalChildW = childW + childMargin.left + childMargin.right;
      final double totalChildH = childH + childMargin.top + childMargin.bottom;

      if (isBlock) {
        flushLine();

        // 水平外边距自动解析
        double marginLeft = childMargin.left;

        bool isMarginLeftAuto = margin?.left.unit == YogaUnit.auto;
        bool isMarginRightAuto = margin?.right.unit == YogaUnit.auto;

        // 检查项目上的 textAlign（如果我们将它视为对齐方式，则覆盖 margin auto）
        // 或者与它一起工作。
        // 如果设置了 textAlign，我们使用它来对齐块。
        // TextAlign? itemTextAlign = childParentData.textAlign;

        // 修正：完全移除基于 textAlign 调整 Block 元素位置的逻辑。
        // Block 元素的位置只受 margin (auto) 影响。

        if ((isMarginLeftAuto || isMarginRightAuto) &&
            availableWidth.isFinite) {
          // childMargin 对于 auto 为 0，所以我们只减去固定部分（如果有）和子项宽度
          double availableSpace =
              availableWidth - childW - childMargin.left - childMargin.right;

          if (availableSpace > 0) {
            if (isMarginLeftAuto && isMarginRightAuto) {
              marginLeft += availableSpace / 2;
            } else if (isMarginLeftAuto) {
              marginLeft += availableSpace;
            }
            // 如果只有右边是 auto，marginLeft 保持原样（左对齐），这是正确的。
          }
        }

        // 兄弟外边距折叠
        double marginTop = childMargin.top;
        double marginBottom = childMargin.bottom;

        // 与前一个底部外边距折叠
        double effectiveSpacing;
        if (_enableMarginCollapsing) {
          effectiveSpacing = _collapse(previousBottomMargin, marginTop);
        } else {
          effectiveSpacing = previousBottomMargin + marginTop;
        }

        // 定位子项
        // cursorY 位于前一个元素边框盒的底部。
        double childY = cursorY + effectiveSpacing;

        if (!dryRun) {
          childParentData.offset = Offset(
            contentLeft + marginLeft,
            contentTop + childY,
          );
        }

        // 跟踪块级元素的宽度
        double totalChildW = childW + childMargin.left + childMargin.right;
        if (totalChildW > maxContentWidth) {
          maxContentWidth = totalChildW;
        }

        cursorY = childY + childH;
        previousBottomMargin = marginBottom;
      } else {
        if (cursorX + totalChildW > availableWidth && cursorX > 0) {
          flushLine();
        }

        if (!dryRun) {
          if (!dryRun) {
            childParentData.offset = Offset(cursorX + childMargin.left, 0);
          }
        }
        currentLineChildren.add(child);

        cursorX += totalChildW;

        if (totalChildH > currentLineHeight) {
          currentLineHeight = totalChildH;
        }

        if (_alignItems == YGAlign.baseline) {
          double? distanceToBaseline;
          if (dryRun) {
            try {
              distanceToBaseline = child.getDryBaseline(
                childConstraints,
                TextBaseline.alphabetic,
              );
            } catch (e) {
              // 如果不支持 getDryBaseline 或失败，则忽略
            }
          } else {
            distanceToBaseline = child.getDistanceToBaseline(
              TextBaseline.alphabetic,
            );
          }
          distanceToBaseline ??= childH;
          childBaselines[child] = distanceToBaseline;

          final double ascent = distanceToBaseline + childMargin.top;
          if (ascent > maxAscent) {
            maxAscent = ascent;
          }
        }
      }

      child = childParentData.nextSibling;
    }

    flushLine();

    // 将剩余的底部外边距添加到高度
    cursorY += previousBottomMargin;

    double contentWidth = maxContentWidth + contentLeft + contentRight;

    double finalWidth;
    bool isFitContent =
        _width?.unit == YogaUnit.fitContent ||
        _width?.unit == YogaUnit.maxContent ||
        _width?.unit == YogaUnit.minContent;

    if (constraints.hasTightWidth) {
      finalWidth = constraints.maxWidth;
    } else if (isFitContent) {
      finalWidth = contentWidth;
      if (constraints.hasBoundedWidth && finalWidth > constraints.maxWidth) {
        finalWidth = constraints.maxWidth;
      }
    } else if (constraints.hasBoundedWidth) {
      finalWidth = constraints.maxWidth;
    } else {
      finalWidth = contentWidth;
    }

    double finalHeight = cursorY + contentTop + contentBottom;
    if (resolvedParentHeight != null) {
      finalHeight = resolvedParentHeight;
    } else if (constraints.hasTightHeight) {
      finalHeight = constraints.maxHeight;
    }

    final Size finalSize = constraints.constrain(Size(finalWidth, finalHeight));
    if (!dryRun) {
      size = finalSize;
    }
    return YogaLayoutResult(finalSize, maxAscent > 0 ? maxAscent : null);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // 检查我们需要绘制自己的装饰
    // 如果父级是 RenderYogaLayout，它会根据我们的 parentData 绘制我们的装饰（边框、阴影、变换）。
    bool parentHandlesDecoration = parent is RenderYogaLayout;

    if (parentHandlesDecoration) {
      // 即使父级处理装饰（边框、阴影、变换），
      // 我们仍然负责绘制自己的背景。
      // 父级在调用我们之前绘制阴影，在调用我们之后绘制边框。
      // 所以我们只需要绘制背景然后绘制子项。
      if (_background != null) {
        _paintBackground(context, offset, size, _background!);
      }
      _paintChildren(context, offset);
    } else {
      _paintSelfWithDecoration(context, offset);
    }
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    // 返回具有基线的第一个子项的基线。
    // 这是一个简化的行为，但涵盖了 Flex/Flow 容器的大多数情况。
    RenderBox? child = firstChild;
    while (child != null) {
      final double? result = child.getDistanceToActualBaseline(baseline);
      if (result != null) {
        final childParentData = child.parentData as YogaLayoutParentData;
        return result + childParentData.offset.dy;
      }
      child = (child.parentData as YogaLayoutParentData).nextSibling;
    }
    return super.computeDistanceToActualBaseline(baseline);
  }
}
