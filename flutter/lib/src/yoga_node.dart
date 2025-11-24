import 'dart:ffi';
import 'dart:ui' as ui;
import 'package:ffi/ffi.dart';
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
    _measureCallbacks.remove(_nativeNode.address);
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

  /// Marks the node as dirty, triggering a re-layout.
  void markDirty() => _yoga.markDirty(_nativeNode);

  // --- Config ---

  void setConfig(YogaConfig config) {
    _yoga.setNodeConfig(_nativeNode, config._nativeConfig);
  }

  // --- Measure Func ---

  static final Map<int, _MeasureCallback> _measureCallbacks = {};

  void setMeasureFunc(
    ui.Size Function(
      YogaNode node,
      double width,
      int widthMode,
      double height,
      int heightMode,
    )?
    measureFunc,
  ) {
    if (measureFunc == null) {
      _yoga.setMeasureFunc(_nativeNode, nullptr);
      _measureCallbacks.remove(_nativeNode.address);
      return;
    }

    _measureCallbacks[_nativeNode.address] =
        (width, widthMode, height, heightMode) {
          return measureFunc(this, width, widthMode, height, heightMode);
        };

    // Set context to node address so we can recover it in the static callback
    // We actually don't need to set context if we use the node pointer passed to the callback
    // as the key. The node pointer in the callback IS _nativeNode.
    // But we need to ensure _nativeNode.address matches the pointer address.
    // Yes, it should.

    _yoga.setMeasureFunc(
      _nativeNode,
      Pointer.fromFunction(_measureFuncTrampoline),
    );
  }

  static YGSize _measureFuncTrampoline(
    Pointer<Void> nodePtr,
    double width,
    int widthMode,
    double height,
    int heightMode,
  ) {
    final callback = _measureCallbacks[nodePtr.address];
    if (callback != null) {
      final size = callback(width, widthMode, height, heightMode);
      // We need to return YGSize by value.
      // Since we can't easily create a stack-allocated struct in Dart to return,
      // we use a thread-local or temporary allocation.
      // However, for FFI callbacks returning structs, we can allocate, populate, and return .ref
      // The FFI bridge should copy the value.
      // To avoid leaks, we should ideally reuse a buffer or rely on the fact that .ref returns a view
      // that is copied when returned?
      // Actually, `calloc` memory needs to be freed. If we return `.ref`, we are returning a view.
      // If we free the pointer immediately, the view is invalid?
      // No, returning `.ref` from a function returning `Struct` copies the struct data.
      // So we can allocate, get ref, free, return ref?
      // No, if we free, the memory is gone.
      // We need a way to return the value without leaking.
      // Since this is a synchronous callback, we can use a static/global buffer if we are single-threaded?
      // Dart is single-threaded.
      // So we can have a static pointer for return value.

      _returnSizePtr.ref.width = size.width;
      _returnSizePtr.ref.height = size.height;
      return _returnSizePtr.ref;
    }

    _returnSizePtr.ref.width = 0;
    _returnSizePtr.ref.height = 0;
    return _returnSizePtr.ref;
  }

  static final Pointer<YGSize> _returnSizePtr = calloc<YGSize>();
}

typedef _MeasureCallback =
    ui.Size Function(
      double width,
      int widthMode,
      double height,
      int heightMode,
    );

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
