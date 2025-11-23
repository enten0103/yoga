import 'dart:ffi';
import 'yoga_ffi.dart';

enum YogaDisplay { flex, none, block, inline, inlineBlock }

/// A high-level wrapper around a Yoga node.
///
/// This class manages the native memory of the Yoga node and provides
/// a Dart-friendly API for configuring style and layout.
class YogaNode implements Finalizable {
  // Singleton instance of the low-level FFI wrapper.
  // This ensures the dynamic library is loaded only once.
  static final Yoga _yoga = Yoga();

  // Finalizer to ensure native memory is freed when the Dart object is GC'd.
  static final Finalizer<Pointer<Void>> _finalizer = Finalizer((ptr) {
    _yoga.freeNode(ptr);
  });

  late final Pointer<Void> _nativeNode;
  final List<YogaNode> _children = [];

  /// Creates a new YogaNode.
  YogaNode([YogaConfig? config]) {
    if (config != null) {
      _nativeNode = _yoga.newNodeWithConfig(config._nativeConfig);
    } else {
      _nativeNode = _yoga.newNode();
    }
    _finalizer.attach(this, _nativeNode, detach: this);
  }

  /// Frees the native memory associated with this node.
  ///
  /// If [recursive] is true, it also frees the native memory of all children.
  /// Note: This does not dispose the Dart [YogaNode] objects of the children,
  /// so you should ensure they are not used afterwards.
  void dispose({bool recursive = false}) {
    _finalizer.detach(this);
    if (recursive) {
      _yoga.freeNodeRecursive(_nativeNode);
      // We should probably clear our children list since their native nodes are gone
      _children.clear();
    } else {
      _yoga.freeNode(_nativeNode);
    }
  }

  /// Resets the node to its default state.
  void reset() {
    _yoga.resetNode(_nativeNode);
    _children.clear();
  }

  // --- Tree Manipulation ---

  /// Inserts a child node at the given index.
  void insertChild(YogaNode child, int index) {
    _yoga.insertChild(_nativeNode, child._nativeNode, index);
    _children.insert(index, child);
  }

  /// Adds a child node to the end of the list.
  void addChild(YogaNode child) {
    insertChild(child, _children.length);
  }

  /// Removes a specific child node.
  void removeChild(YogaNode child) {
    _yoga.removeChild(_nativeNode, child._nativeNode);
    _children.remove(child);
  }

  /// Removes all children.
  void removeAllChildren() {
    _yoga.removeAllChildren(_nativeNode);
    _children.clear();
  }

  /// Returns the number of children.
  int get childCount => _children.length;

  /// Returns the child at the given index.
  YogaNode getChild(int index) => _children[index];

  // --- Layout Calculation ---

  /// Calculates the layout for this node and its children.
  void calculateLayout({
    double availableWidth = double.nan,
    double availableHeight = double.nan,
    int direction = YGDirection.ltr,
  }) {
    _yoga.calculateLayout(
      _nativeNode,
      availableWidth: availableWidth,
      availableHeight: availableHeight,
      ownerDirection: direction,
    );
  }

  // --- Layout Results ---

  double get left => _yoga.getLeft(_nativeNode);
  double get top => _yoga.getTop(_nativeNode);
  double get right => _yoga.getRight(_nativeNode);
  double get bottom => _yoga.getBottom(_nativeNode);
  double get layoutWidth => _yoga.getLayoutWidth(_nativeNode);
  double get layoutHeight => _yoga.getLayoutHeight(_nativeNode);
  int get layoutDirection => _yoga.getLayoutDirection(_nativeNode);
  bool get hadOverflow => _yoga.getHadOverflow(_nativeNode);

  // --- Style Getters ---
  int get flexDirection => _yoga.getFlexDirection(_nativeNode);

  // --- Style Setters ---

  set direction(int value) => _yoga.setDirection(_nativeNode, value);
  set flexDirection(int value) => _yoga.setFlexDirection(_nativeNode, value);
  set justifyContent(int value) => _yoga.setJustifyContent(_nativeNode, value);
  set alignContent(int value) => _yoga.setAlignContent(_nativeNode, value);
  set alignItems(int value) => _yoga.setAlignItems(_nativeNode, value);
  set alignSelf(int value) => _yoga.setAlignSelf(_nativeNode, value);
  set positionType(int value) => _yoga.setPositionType(_nativeNode, value);
  set flexWrap(int value) => _yoga.setFlexWrap(_nativeNode, value);
  set overflow(int value) => _yoga.setOverflow(_nativeNode, value);
  set display(int value) => _yoga.setDisplay(_nativeNode, value);

  set flex(double value) => _yoga.setFlex(_nativeNode, value);
  set flexGrow(double value) => _yoga.setFlexGrow(_nativeNode, value);
  set flexShrink(double value) => _yoga.setFlexShrink(_nativeNode, value);

  set flexBasis(double value) => _yoga.setFlexBasis(_nativeNode, value);
  void setFlexBasisPercent(double value) =>
      _yoga.setFlexBasisPercent(_nativeNode, value);
  void setFlexBasisAuto() => _yoga.setFlexBasisAuto(_nativeNode);

  void setPosition(int edge, double value) =>
      _yoga.setPosition(_nativeNode, edge, value);
  void setPositionPercent(int edge, double value) =>
      _yoga.setPositionPercent(_nativeNode, edge, value);

  void setMargin(int edge, double value) =>
      _yoga.setMargin(_nativeNode, edge, value);
  void setMarginPercent(int edge, double value) =>
      _yoga.setMarginPercent(_nativeNode, edge, value);
  void setMarginAuto(int edge) => _yoga.setMarginAuto(_nativeNode, edge);

  void setPadding(int edge, double value) =>
      _yoga.setPadding(_nativeNode, edge, value);
  void setPaddingPercent(int edge, double value) =>
      _yoga.setPaddingPercent(_nativeNode, edge, value);

  void setBorder(int edge, double value) =>
      _yoga.setBorder(_nativeNode, edge, value);

  set width(double value) => _yoga.setWidth(_nativeNode, value);
  void setWidthPercent(double value) =>
      _yoga.setWidthPercent(_nativeNode, value);
  void setWidthAuto() => _yoga.setWidthAuto(_nativeNode);

  set height(double value) => _yoga.setHeight(_nativeNode, value);
  void setHeightPercent(double value) =>
      _yoga.setHeightPercent(_nativeNode, value);
  void setHeightAuto() => _yoga.setHeightAuto(_nativeNode);

  set minWidth(double value) => _yoga.setMinWidth(_nativeNode, value);
  void setMinWidthPercent(double value) =>
      _yoga.setMinWidthPercent(_nativeNode, value);

  set minHeight(double value) => _yoga.setMinHeight(_nativeNode, value);
  void setMinHeightPercent(double value) =>
      _yoga.setMinHeightPercent(_nativeNode, value);

  set maxWidth(double value) => _yoga.setMaxWidth(_nativeNode, value);
  void setMaxWidthPercent(double value) =>
      _yoga.setMaxWidthPercent(_nativeNode, value);

  set maxHeight(double value) => _yoga.setMaxHeight(_nativeNode, value);
  void setMaxHeightPercent(double value) =>
      _yoga.setMaxHeightPercent(_nativeNode, value);

  set aspectRatio(double value) => _yoga.setAspectRatio(_nativeNode, value);

  // --- Config ---

  void setConfig(YogaConfig config) {
    _yoga.setNodeConfig(_nativeNode, config._nativeConfig);
  }
}

/// A wrapper around Yoga configuration.
class YogaConfig implements Finalizable {
  static final Yoga _yoga = Yoga();
  static final Finalizer<Pointer<Void>> _finalizer = Finalizer((ptr) {
    _yoga.freeConfig(ptr);
  });

  late final Pointer<Void> _nativeConfig;

  YogaConfig() {
    _nativeConfig = _yoga.newConfig();
    _finalizer.attach(this, _nativeConfig, detach: this);
  }

  void dispose() {
    _finalizer.detach(this);
    _yoga.freeConfig(_nativeConfig);
  }

  set useWebDefaults(bool value) =>
      _yoga.setConfigUseWebDefaults(_nativeConfig, value);
}
