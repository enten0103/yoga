import 'dart:ffi';
import 'dart:io';

typedef YGNodeNewFunc = Pointer<Void> Function();
typedef YGNodeNew = Pointer<Void> Function();

typedef YGNodeFreeFunc = Void Function(Pointer<Void>);
typedef YGNodeFree = void Function(Pointer<Void>);

typedef YGNodeStyleSetWidthFunc = Void Function(Pointer<Void>, Float);
typedef YGNodeStyleSetWidth = void Function(Pointer<Void>, double);

typedef YGNodeStyleSetHeightFunc = Void Function(Pointer<Void>, Float);
typedef YGNodeStyleSetHeight = void Function(Pointer<Void>, double);

typedef YGNodeCalculateLayoutFunc =
    Void Function(Pointer<Void>, Float, Float, Int32);
typedef YGNodeCalculateLayout =
    void Function(Pointer<Void>, double, double, int);

typedef YGNodeLayoutGetLeftFunc = Float Function(Pointer<Void>);
typedef YGNodeLayoutGetLeft = double Function(Pointer<Void>);

class Yoga {
  late DynamicLibrary _lib;
  late YGNodeNew _ygNodeNew;
  late YGNodeFree _ygNodeFree;
  late YGNodeStyleSetWidth _ygNodeStyleSetWidth;
  late YGNodeStyleSetHeight _ygNodeStyleSetHeight;
  late YGNodeCalculateLayout _ygNodeCalculateLayout;
  late YGNodeLayoutGetLeft _ygNodeLayoutGetLeft;

  Yoga() {
    if (Platform.isAndroid) {
      try {
        _lib = DynamicLibrary.open('libyoga.so');
      } catch (e) {
        print("Failed to load libyoga.so: $e");
        rethrow;
      }
    } else if (Platform.isWindows) {
      try {
        _lib = DynamicLibrary.open('flutter_yoga_plugin.dll');
      } catch (e) {
        print("Failed to load flutter_yoga_plugin.dll: $e");
        rethrow;
      }
    } else {
      throw UnimplementedError('Platform not supported');
    }

    try {
      _ygNodeNew = _lib
          .lookup<NativeFunction<YGNodeNewFunc>>('YGNodeNew')
          .asFunction();
      _ygNodeFree = _lib
          .lookup<NativeFunction<YGNodeFreeFunc>>('YGNodeFree')
          .asFunction();
      _ygNodeStyleSetWidth = _lib
          .lookup<NativeFunction<YGNodeStyleSetWidthFunc>>(
            'YGNodeStyleSetWidth',
          )
          .asFunction();
      _ygNodeStyleSetHeight = _lib
          .lookup<NativeFunction<YGNodeStyleSetHeightFunc>>(
            'YGNodeStyleSetHeight',
          )
          .asFunction();
      _ygNodeCalculateLayout = _lib
          .lookup<NativeFunction<YGNodeCalculateLayoutFunc>>(
            'YGNodeCalculateLayout',
          )
          .asFunction();
      _ygNodeLayoutGetLeft = _lib
          .lookup<NativeFunction<YGNodeLayoutGetLeftFunc>>(
            'YGNodeLayoutGetLeft',
          )
          .asFunction();
    } catch (e) {
      print("Failed to lookup symbols: $e");
      rethrow;
    }
  }

  Pointer<Void> newNode() => _ygNodeNew();
  void freeNode(Pointer<Void> node) => _ygNodeFree(node);
  void setWidth(Pointer<Void> node, double width) =>
      _ygNodeStyleSetWidth(node, width);
  void setHeight(Pointer<Void> node, double height) =>
      _ygNodeStyleSetHeight(node, height);
  void calculateLayout(Pointer<Void> node) =>
      _ygNodeCalculateLayout(node, double.nan, double.nan, 1); // 1 = LTR
  double getLeft(Pointer<Void> node) => _ygNodeLayoutGetLeft(node);
}
