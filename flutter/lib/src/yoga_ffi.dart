import 'dart:ffi';
import 'dart:io';

// Enums
class YGAlign {
  static const int auto = 0;
  static const int flexStart = 1;
  static const int center = 2;
  static const int flexEnd = 3;
  static const int stretch = 4;
  static const int baseline = 5;
  static const int spaceBetween = 6;
  static const int spaceAround = 7;
  static const int spaceEvenly = 8;
}

class YGDimension {
  static const int width = 0;
  static const int height = 1;
}

class YGDirection {
  static const int inherit = 0;
  static const int ltr = 1;
  static const int rtl = 2;
}

class YGDisplay {
  static const int flex = 0;
  static const int none = 1;
}

class YGEdge {
  static const int left = 0;
  static const int top = 1;
  static const int right = 2;
  static const int bottom = 3;
  static const int start = 4;
  static const int end = 5;
  static const int horizontal = 6;
  static const int vertical = 7;
  static const int all = 8;
}

class YGFlexDirection {
  static const int column = 0;
  static const int columnReverse = 1;
  static const int row = 2;
  static const int rowReverse = 3;
}

class YGJustify {
  static const int flexStart = 0;
  static const int center = 1;
  static const int flexEnd = 2;
  static const int spaceBetween = 3;
  static const int spaceAround = 4;
  static const int spaceEvenly = 5;
}

class YGMeasureMode {
  static const int undefined = 0;
  static const int exactly = 1;
  static const int atMost = 2;
}

class YGNodeType {
  static const int defaultNode = 0;
  static const int text = 1;
}

class YGOverflow {
  static const int visible = 0;
  static const int hidden = 1;
  static const int scroll = 2;
}

class YGPositionType {
  static const int staticPosition = 0;
  static const int relative = 1;
  static const int absolute = 2;
}

class YGUnit {
  static const int undefined = 0;
  static const int point = 1;
  static const int percent = 2;
  static const int auto = 3;
}

class YGWrap {
  static const int noWrap = 0;
  static const int wrap = 1;
  static const int wrapReverse = 2;
}

// Typedefs
typedef YGNodeNewFunc = Pointer<Void> Function();
typedef YGNodeNew = Pointer<Void> Function();

typedef YGNodeFreeFunc = Void Function(Pointer<Void>);
typedef YGNodeFree = void Function(Pointer<Void>);

typedef YGNodeResetFunc = Void Function(Pointer<Void>);
typedef YGNodeReset = void Function(Pointer<Void>);

typedef YGNodeFreeRecursiveFunc = Void Function(Pointer<Void>);
typedef YGNodeFreeRecursive = void Function(Pointer<Void>);

typedef YGNodeMarkDirtyFunc = Void Function(Pointer<Void>);
typedef YGNodeMarkDirty = void Function(Pointer<Void>);

typedef YGNodeSetNodeTypeFunc = Void Function(Pointer<Void>, Int32);
typedef YGNodeSetNodeType = void Function(Pointer<Void>, int);

typedef YGNodeGetNodeTypeFunc = Int32 Function(Pointer<Void>);
typedef YGNodeGetNodeType = int Function(Pointer<Void>);

typedef YGNodeCopyStyleFunc = Void Function(Pointer<Void>, Pointer<Void>);
typedef YGNodeCopyStyle = void Function(Pointer<Void>, Pointer<Void>);

typedef YGNodeInsertChildFunc =
    Void Function(Pointer<Void>, Pointer<Void>, Uint32);
typedef YGNodeInsertChild = void Function(Pointer<Void>, Pointer<Void>, int);

typedef YGNodeRemoveChildFunc = Void Function(Pointer<Void>, Pointer<Void>);
typedef YGNodeRemoveChild = void Function(Pointer<Void>, Pointer<Void>);

typedef YGNodeRemoveAllChildrenFunc = Void Function(Pointer<Void>);
typedef YGNodeRemoveAllChildren = void Function(Pointer<Void>);

typedef YGNodeGetChildFunc = Pointer<Void> Function(Pointer<Void>, Uint32);
typedef YGNodeGetChild = Pointer<Void> Function(Pointer<Void>, int);

typedef YGNodeGetChildCountFunc = Uint32 Function(Pointer<Void>);
typedef YGNodeGetChildCount = int Function(Pointer<Void>);

typedef YGNodeGetParentFunc = Pointer<Void> Function(Pointer<Void>);
typedef YGNodeGetParent = Pointer<Void> Function(Pointer<Void>);

typedef YGNodeStyleSetDirectionFunc = Void Function(Pointer<Void>, Int32);
typedef YGNodeStyleSetDirection = void Function(Pointer<Void>, int);

typedef YGNodeStyleSetFlexDirectionFunc = Void Function(Pointer<Void>, Int32);
typedef YGNodeStyleSetFlexDirection = void Function(Pointer<Void>, int);

typedef YGNodeStyleSetJustifyContentFunc = Void Function(Pointer<Void>, Int32);
typedef YGNodeStyleSetJustifyContent = void Function(Pointer<Void>, int);

typedef YGNodeStyleSetAlignContentFunc = Void Function(Pointer<Void>, Int32);
typedef YGNodeStyleSetAlignContent = void Function(Pointer<Void>, int);

typedef YGNodeStyleSetAlignItemsFunc = Void Function(Pointer<Void>, Int32);
typedef YGNodeStyleSetAlignItems = void Function(Pointer<Void>, int);

typedef YGNodeStyleSetAlignSelfFunc = Void Function(Pointer<Void>, Int32);
typedef YGNodeStyleSetAlignSelf = void Function(Pointer<Void>, int);

typedef YGNodeStyleSetPositionTypeFunc = Void Function(Pointer<Void>, Int32);
typedef YGNodeStyleSetPositionType = void Function(Pointer<Void>, int);

typedef YGNodeStyleSetFlexWrapFunc = Void Function(Pointer<Void>, Int32);
typedef YGNodeStyleSetFlexWrap = void Function(Pointer<Void>, int);

typedef YGNodeStyleSetOverflowFunc = Void Function(Pointer<Void>, Int32);
typedef YGNodeStyleSetOverflow = void Function(Pointer<Void>, int);

typedef YGNodeStyleSetDisplayFunc = Void Function(Pointer<Void>, Int32);
typedef YGNodeStyleSetDisplay = void Function(Pointer<Void>, int);

typedef YGNodeStyleSetFlexFunc = Void Function(Pointer<Void>, Float);
typedef YGNodeStyleSetFlex = void Function(Pointer<Void>, double);

typedef YGNodeStyleSetFlexGrowFunc = Void Function(Pointer<Void>, Float);
typedef YGNodeStyleSetFlexGrow = void Function(Pointer<Void>, double);

typedef YGNodeStyleSetFlexShrinkFunc = Void Function(Pointer<Void>, Float);
typedef YGNodeStyleSetFlexShrink = void Function(Pointer<Void>, double);

typedef YGNodeStyleSetFlexBasisFunc = Void Function(Pointer<Void>, Float);
typedef YGNodeStyleSetFlexBasis = void Function(Pointer<Void>, double);

typedef YGNodeStyleSetFlexBasisPercentFunc =
    Void Function(Pointer<Void>, Float);
typedef YGNodeStyleSetFlexBasisPercent = void Function(Pointer<Void>, double);

typedef YGNodeStyleSetFlexBasisAutoFunc = Void Function(Pointer<Void>);
typedef YGNodeStyleSetFlexBasisAuto = void Function(Pointer<Void>);

typedef YGNodeStyleSetPositionFunc = Void Function(Pointer<Void>, Int32, Float);
typedef YGNodeStyleSetPosition = void Function(Pointer<Void>, int, double);

typedef YGNodeStyleSetPositionPercentFunc =
    Void Function(Pointer<Void>, Int32, Float);
typedef YGNodeStyleSetPositionPercent =
    void Function(Pointer<Void>, int, double);

typedef YGNodeStyleSetMarginFunc = Void Function(Pointer<Void>, Int32, Float);
typedef YGNodeStyleSetMargin = void Function(Pointer<Void>, int, double);

typedef YGNodeStyleSetMarginPercentFunc =
    Void Function(Pointer<Void>, Int32, Float);
typedef YGNodeStyleSetMarginPercent = void Function(Pointer<Void>, int, double);

typedef YGNodeStyleSetMarginAutoFunc = Void Function(Pointer<Void>, Int32);
typedef YGNodeStyleSetMarginAuto = void Function(Pointer<Void>, int);

typedef YGNodeStyleSetPaddingFunc = Void Function(Pointer<Void>, Int32, Float);
typedef YGNodeStyleSetPadding = void Function(Pointer<Void>, int, double);

typedef YGNodeStyleSetPaddingPercentFunc =
    Void Function(Pointer<Void>, Int32, Float);
typedef YGNodeStyleSetPaddingPercent =
    void Function(Pointer<Void>, int, double);

typedef YGNodeStyleSetBorderFunc = Void Function(Pointer<Void>, Int32, Float);
typedef YGNodeStyleSetBorder = void Function(Pointer<Void>, int, double);

typedef YGNodeStyleSetWidthFunc = Void Function(Pointer<Void>, Float);
typedef YGNodeStyleSetWidth = void Function(Pointer<Void>, double);

typedef YGNodeStyleSetWidthPercentFunc = Void Function(Pointer<Void>, Float);
typedef YGNodeStyleSetWidthPercent = void Function(Pointer<Void>, double);

typedef YGNodeStyleSetWidthAutoFunc = Void Function(Pointer<Void>);
typedef YGNodeStyleSetWidthAuto = void Function(Pointer<Void>);

typedef YGNodeStyleSetHeightFunc = Void Function(Pointer<Void>, Float);
typedef YGNodeStyleSetHeight = void Function(Pointer<Void>, double);

typedef YGNodeStyleSetHeightPercentFunc = Void Function(Pointer<Void>, Float);
typedef YGNodeStyleSetHeightPercent = void Function(Pointer<Void>, double);

typedef YGNodeStyleSetHeightAutoFunc = Void Function(Pointer<Void>);
typedef YGNodeStyleSetHeightAuto = void Function(Pointer<Void>);

typedef YGNodeStyleSetMinWidthFunc = Void Function(Pointer<Void>, Float);
typedef YGNodeStyleSetMinWidth = void Function(Pointer<Void>, double);

typedef YGNodeStyleSetMinWidthPercentFunc = Void Function(Pointer<Void>, Float);
typedef YGNodeStyleSetMinWidthPercent = void Function(Pointer<Void>, double);

typedef YGNodeStyleSetMinHeightFunc = Void Function(Pointer<Void>, Float);
typedef YGNodeStyleSetMinHeight = void Function(Pointer<Void>, double);

typedef YGNodeStyleSetMinHeightPercentFunc =
    Void Function(Pointer<Void>, Float);
typedef YGNodeStyleSetMinHeightPercent = void Function(Pointer<Void>, double);

typedef YGNodeStyleSetMaxWidthFunc = Void Function(Pointer<Void>, Float);
typedef YGNodeStyleSetMaxWidth = void Function(Pointer<Void>, double);

typedef YGNodeStyleSetMaxWidthPercentFunc = Void Function(Pointer<Void>, Float);
typedef YGNodeStyleSetMaxWidthPercent = void Function(Pointer<Void>, double);

typedef YGNodeStyleSetMaxHeightFunc = Void Function(Pointer<Void>, Float);
typedef YGNodeStyleSetMaxHeight = void Function(Pointer<Void>, double);

typedef YGNodeStyleSetMaxHeightPercentFunc =
    Void Function(Pointer<Void>, Float);
typedef YGNodeStyleSetMaxHeightPercent = void Function(Pointer<Void>, double);

typedef YGNodeStyleSetAspectRatioFunc = Void Function(Pointer<Void>, Float);
typedef YGNodeStyleSetAspectRatio = void Function(Pointer<Void>, double);

typedef YGNodeCalculateLayoutFunc =
    Void Function(Pointer<Void>, Float, Float, Int32);
typedef YGNodeCalculateLayout =
    void Function(Pointer<Void>, double, double, int);

typedef YGNodeLayoutGetLeftFunc = Float Function(Pointer<Void>);
typedef YGNodeLayoutGetLeft = double Function(Pointer<Void>);

typedef YGNodeLayoutGetTopFunc = Float Function(Pointer<Void>);
typedef YGNodeLayoutGetTop = double Function(Pointer<Void>);

typedef YGNodeLayoutGetRightFunc = Float Function(Pointer<Void>);
typedef YGNodeLayoutGetRight = double Function(Pointer<Void>);

typedef YGNodeLayoutGetBottomFunc = Float Function(Pointer<Void>);
typedef YGNodeLayoutGetBottom = double Function(Pointer<Void>);

typedef YGNodeLayoutGetWidthFunc = Float Function(Pointer<Void>);
typedef YGNodeLayoutGetWidth = double Function(Pointer<Void>);

typedef YGNodeLayoutGetHeightFunc = Float Function(Pointer<Void>);
typedef YGNodeLayoutGetHeight = double Function(Pointer<Void>);

typedef YGNodeLayoutGetDirectionFunc = Int32 Function(Pointer<Void>);
typedef YGNodeLayoutGetDirection = int Function(Pointer<Void>);

typedef YGNodeLayoutGetHadOverflowFunc = Bool Function(Pointer<Void>);
typedef YGNodeLayoutGetHadOverflow = bool Function(Pointer<Void>);

class Yoga {
  late DynamicLibrary _lib;

  late YGNodeNew _ygNodeNew;
  late YGNodeFree _ygNodeFree;
  late YGNodeReset _ygNodeReset;
  late YGNodeFreeRecursive _ygNodeFreeRecursive;
  late YGNodeMarkDirty _ygNodeMarkDirty;
  late YGNodeSetNodeType _ygNodeSetNodeType;
  late YGNodeGetNodeType _ygNodeGetNodeType;
  late YGNodeCopyStyle _ygNodeCopyStyle;

  late YGNodeInsertChild _ygNodeInsertChild;
  late YGNodeRemoveChild _ygNodeRemoveChild;
  late YGNodeRemoveAllChildren _ygNodeRemoveAllChildren;
  late YGNodeGetChild _ygNodeGetChild;
  late YGNodeGetChildCount _ygNodeGetChildCount;
  late YGNodeGetParent _ygNodeGetParent;

  late YGNodeStyleSetDirection _ygNodeStyleSetDirection;
  late YGNodeStyleSetFlexDirection _ygNodeStyleSetFlexDirection;
  late YGNodeStyleSetJustifyContent _ygNodeStyleSetJustifyContent;
  late YGNodeStyleSetAlignContent _ygNodeStyleSetAlignContent;
  late YGNodeStyleSetAlignItems _ygNodeStyleSetAlignItems;
  late YGNodeStyleSetAlignSelf _ygNodeStyleSetAlignSelf;
  late YGNodeStyleSetPositionType _ygNodeStyleSetPositionType;
  late YGNodeStyleSetFlexWrap _ygNodeStyleSetFlexWrap;
  late YGNodeStyleSetOverflow _ygNodeStyleSetOverflow;
  late YGNodeStyleSetDisplay _ygNodeStyleSetDisplay;

  late YGNodeStyleSetFlex _ygNodeStyleSetFlex;
  late YGNodeStyleSetFlexGrow _ygNodeStyleSetFlexGrow;
  late YGNodeStyleSetFlexShrink _ygNodeStyleSetFlexShrink;
  late YGNodeStyleSetFlexBasis _ygNodeStyleSetFlexBasis;
  late YGNodeStyleSetFlexBasisPercent _ygNodeStyleSetFlexBasisPercent;
  late YGNodeStyleSetFlexBasisAuto _ygNodeStyleSetFlexBasisAuto;

  late YGNodeStyleSetPosition _ygNodeStyleSetPosition;
  late YGNodeStyleSetPositionPercent _ygNodeStyleSetPositionPercent;

  late YGNodeStyleSetMargin _ygNodeStyleSetMargin;
  late YGNodeStyleSetMarginPercent _ygNodeStyleSetMarginPercent;
  late YGNodeStyleSetMarginAuto _ygNodeStyleSetMarginAuto;

  late YGNodeStyleSetPadding _ygNodeStyleSetPadding;
  late YGNodeStyleSetPaddingPercent _ygNodeStyleSetPaddingPercent;

  late YGNodeStyleSetBorder _ygNodeStyleSetBorder;

  late YGNodeStyleSetWidth _ygNodeStyleSetWidth;
  late YGNodeStyleSetWidthPercent _ygNodeStyleSetWidthPercent;
  late YGNodeStyleSetWidthAuto _ygNodeStyleSetWidthAuto;

  late YGNodeStyleSetHeight _ygNodeStyleSetHeight;
  late YGNodeStyleSetHeightPercent _ygNodeStyleSetHeightPercent;
  late YGNodeStyleSetHeightAuto _ygNodeStyleSetHeightAuto;

  late YGNodeStyleSetMinWidth _ygNodeStyleSetMinWidth;
  late YGNodeStyleSetMinWidthPercent _ygNodeStyleSetMinWidthPercent;

  late YGNodeStyleSetMinHeight _ygNodeStyleSetMinHeight;
  late YGNodeStyleSetMinHeightPercent _ygNodeStyleSetMinHeightPercent;

  late YGNodeStyleSetMaxWidth _ygNodeStyleSetMaxWidth;
  late YGNodeStyleSetMaxWidthPercent _ygNodeStyleSetMaxWidthPercent;

  late YGNodeStyleSetMaxHeight _ygNodeStyleSetMaxHeight;
  late YGNodeStyleSetMaxHeightPercent _ygNodeStyleSetMaxHeightPercent;

  late YGNodeStyleSetAspectRatio _ygNodeStyleSetAspectRatio;

  late YGNodeCalculateLayout _ygNodeCalculateLayout;

  late YGNodeLayoutGetLeft _ygNodeLayoutGetLeft;
  late YGNodeLayoutGetTop _ygNodeLayoutGetTop;
  late YGNodeLayoutGetRight _ygNodeLayoutGetRight;
  late YGNodeLayoutGetBottom _ygNodeLayoutGetBottom;
  late YGNodeLayoutGetWidth _ygNodeLayoutGetWidth;
  late YGNodeLayoutGetHeight _ygNodeLayoutGetHeight;
  late YGNodeLayoutGetDirection _ygNodeLayoutGetDirection;
  late YGNodeLayoutGetHadOverflow _ygNodeLayoutGetHadOverflow;

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
      _ygNodeReset = _lib
          .lookup<NativeFunction<YGNodeResetFunc>>('YGNodeReset')
          .asFunction();
      _ygNodeFreeRecursive = _lib
          .lookup<NativeFunction<YGNodeFreeRecursiveFunc>>(
            'YGNodeFreeRecursive',
          )
          .asFunction();
      _ygNodeMarkDirty = _lib
          .lookup<NativeFunction<YGNodeMarkDirtyFunc>>('YGNodeMarkDirty')
          .asFunction();
      _ygNodeSetNodeType = _lib
          .lookup<NativeFunction<YGNodeSetNodeTypeFunc>>('YGNodeSetNodeType')
          .asFunction();
      _ygNodeGetNodeType = _lib
          .lookup<NativeFunction<YGNodeGetNodeTypeFunc>>('YGNodeGetNodeType')
          .asFunction();
      _ygNodeCopyStyle = _lib
          .lookup<NativeFunction<YGNodeCopyStyleFunc>>('YGNodeCopyStyle')
          .asFunction();

      _ygNodeInsertChild = _lib
          .lookup<NativeFunction<YGNodeInsertChildFunc>>('YGNodeInsertChild')
          .asFunction();
      _ygNodeRemoveChild = _lib
          .lookup<NativeFunction<YGNodeRemoveChildFunc>>('YGNodeRemoveChild')
          .asFunction();
      _ygNodeRemoveAllChildren = _lib
          .lookup<NativeFunction<YGNodeRemoveAllChildrenFunc>>(
            'YGNodeRemoveAllChildren',
          )
          .asFunction();
      _ygNodeGetChild = _lib
          .lookup<NativeFunction<YGNodeGetChildFunc>>('YGNodeGetChild')
          .asFunction();
      _ygNodeGetChildCount = _lib
          .lookup<NativeFunction<YGNodeGetChildCountFunc>>(
            'YGNodeGetChildCount',
          )
          .asFunction();
      _ygNodeGetParent = _lib
          .lookup<NativeFunction<YGNodeGetParentFunc>>('YGNodeGetParent')
          .asFunction();

      _ygNodeStyleSetDirection = _lib
          .lookup<NativeFunction<YGNodeStyleSetDirectionFunc>>(
            'YGNodeStyleSetDirection',
          )
          .asFunction();
      _ygNodeStyleSetFlexDirection = _lib
          .lookup<NativeFunction<YGNodeStyleSetFlexDirectionFunc>>(
            'YGNodeStyleSetFlexDirection',
          )
          .asFunction();
      _ygNodeStyleSetJustifyContent = _lib
          .lookup<NativeFunction<YGNodeStyleSetJustifyContentFunc>>(
            'YGNodeStyleSetJustifyContent',
          )
          .asFunction();
      _ygNodeStyleSetAlignContent = _lib
          .lookup<NativeFunction<YGNodeStyleSetAlignContentFunc>>(
            'YGNodeStyleSetAlignContent',
          )
          .asFunction();
      _ygNodeStyleSetAlignItems = _lib
          .lookup<NativeFunction<YGNodeStyleSetAlignItemsFunc>>(
            'YGNodeStyleSetAlignItems',
          )
          .asFunction();
      _ygNodeStyleSetAlignSelf = _lib
          .lookup<NativeFunction<YGNodeStyleSetAlignSelfFunc>>(
            'YGNodeStyleSetAlignSelf',
          )
          .asFunction();
      _ygNodeStyleSetPositionType = _lib
          .lookup<NativeFunction<YGNodeStyleSetPositionTypeFunc>>(
            'YGNodeStyleSetPositionType',
          )
          .asFunction();
      _ygNodeStyleSetFlexWrap = _lib
          .lookup<NativeFunction<YGNodeStyleSetFlexWrapFunc>>(
            'YGNodeStyleSetFlexWrap',
          )
          .asFunction();
      _ygNodeStyleSetOverflow = _lib
          .lookup<NativeFunction<YGNodeStyleSetOverflowFunc>>(
            'YGNodeStyleSetOverflow',
          )
          .asFunction();
      _ygNodeStyleSetDisplay = _lib
          .lookup<NativeFunction<YGNodeStyleSetDisplayFunc>>(
            'YGNodeStyleSetDisplay',
          )
          .asFunction();

      _ygNodeStyleSetFlex = _lib
          .lookup<NativeFunction<YGNodeStyleSetFlexFunc>>('YGNodeStyleSetFlex')
          .asFunction();
      _ygNodeStyleSetFlexGrow = _lib
          .lookup<NativeFunction<YGNodeStyleSetFlexGrowFunc>>(
            'YGNodeStyleSetFlexGrow',
          )
          .asFunction();
      _ygNodeStyleSetFlexShrink = _lib
          .lookup<NativeFunction<YGNodeStyleSetFlexShrinkFunc>>(
            'YGNodeStyleSetFlexShrink',
          )
          .asFunction();
      _ygNodeStyleSetFlexBasis = _lib
          .lookup<NativeFunction<YGNodeStyleSetFlexBasisFunc>>(
            'YGNodeStyleSetFlexBasis',
          )
          .asFunction();
      _ygNodeStyleSetFlexBasisPercent = _lib
          .lookup<NativeFunction<YGNodeStyleSetFlexBasisPercentFunc>>(
            'YGNodeStyleSetFlexBasisPercent',
          )
          .asFunction();
      _ygNodeStyleSetFlexBasisAuto = _lib
          .lookup<NativeFunction<YGNodeStyleSetFlexBasisAutoFunc>>(
            'YGNodeStyleSetFlexBasisAuto',
          )
          .asFunction();

      _ygNodeStyleSetPosition = _lib
          .lookup<NativeFunction<YGNodeStyleSetPositionFunc>>(
            'YGNodeStyleSetPosition',
          )
          .asFunction();
      _ygNodeStyleSetPositionPercent = _lib
          .lookup<NativeFunction<YGNodeStyleSetPositionPercentFunc>>(
            'YGNodeStyleSetPositionPercent',
          )
          .asFunction();

      _ygNodeStyleSetMargin = _lib
          .lookup<NativeFunction<YGNodeStyleSetMarginFunc>>(
            'YGNodeStyleSetMargin',
          )
          .asFunction();
      _ygNodeStyleSetMarginPercent = _lib
          .lookup<NativeFunction<YGNodeStyleSetMarginPercentFunc>>(
            'YGNodeStyleSetMarginPercent',
          )
          .asFunction();
      _ygNodeStyleSetMarginAuto = _lib
          .lookup<NativeFunction<YGNodeStyleSetMarginAutoFunc>>(
            'YGNodeStyleSetMarginAuto',
          )
          .asFunction();

      _ygNodeStyleSetPadding = _lib
          .lookup<NativeFunction<YGNodeStyleSetPaddingFunc>>(
            'YGNodeStyleSetPadding',
          )
          .asFunction();
      _ygNodeStyleSetPaddingPercent = _lib
          .lookup<NativeFunction<YGNodeStyleSetPaddingPercentFunc>>(
            'YGNodeStyleSetPaddingPercent',
          )
          .asFunction();

      _ygNodeStyleSetBorder = _lib
          .lookup<NativeFunction<YGNodeStyleSetBorderFunc>>(
            'YGNodeStyleSetBorder',
          )
          .asFunction();

      _ygNodeStyleSetWidth = _lib
          .lookup<NativeFunction<YGNodeStyleSetWidthFunc>>(
            'YGNodeStyleSetWidth',
          )
          .asFunction();
      _ygNodeStyleSetWidthPercent = _lib
          .lookup<NativeFunction<YGNodeStyleSetWidthPercentFunc>>(
            'YGNodeStyleSetWidthPercent',
          )
          .asFunction();
      _ygNodeStyleSetWidthAuto = _lib
          .lookup<NativeFunction<YGNodeStyleSetWidthAutoFunc>>(
            'YGNodeStyleSetWidthAuto',
          )
          .asFunction();

      _ygNodeStyleSetHeight = _lib
          .lookup<NativeFunction<YGNodeStyleSetHeightFunc>>(
            'YGNodeStyleSetHeight',
          )
          .asFunction();
      _ygNodeStyleSetHeightPercent = _lib
          .lookup<NativeFunction<YGNodeStyleSetHeightPercentFunc>>(
            'YGNodeStyleSetHeightPercent',
          )
          .asFunction();
      _ygNodeStyleSetHeightAuto = _lib
          .lookup<NativeFunction<YGNodeStyleSetHeightAutoFunc>>(
            'YGNodeStyleSetHeightAuto',
          )
          .asFunction();

      _ygNodeStyleSetMinWidth = _lib
          .lookup<NativeFunction<YGNodeStyleSetMinWidthFunc>>(
            'YGNodeStyleSetMinWidth',
          )
          .asFunction();
      _ygNodeStyleSetMinWidthPercent = _lib
          .lookup<NativeFunction<YGNodeStyleSetMinWidthPercentFunc>>(
            'YGNodeStyleSetMinWidthPercent',
          )
          .asFunction();

      _ygNodeStyleSetMinHeight = _lib
          .lookup<NativeFunction<YGNodeStyleSetMinHeightFunc>>(
            'YGNodeStyleSetMinHeight',
          )
          .asFunction();
      _ygNodeStyleSetMinHeightPercent = _lib
          .lookup<NativeFunction<YGNodeStyleSetMinHeightPercentFunc>>(
            'YGNodeStyleSetMinHeightPercent',
          )
          .asFunction();

      _ygNodeStyleSetMaxWidth = _lib
          .lookup<NativeFunction<YGNodeStyleSetMaxWidthFunc>>(
            'YGNodeStyleSetMaxWidth',
          )
          .asFunction();
      _ygNodeStyleSetMaxWidthPercent = _lib
          .lookup<NativeFunction<YGNodeStyleSetMaxWidthPercentFunc>>(
            'YGNodeStyleSetMaxWidthPercent',
          )
          .asFunction();

      _ygNodeStyleSetMaxHeight = _lib
          .lookup<NativeFunction<YGNodeStyleSetMaxHeightFunc>>(
            'YGNodeStyleSetMaxHeight',
          )
          .asFunction();
      _ygNodeStyleSetMaxHeightPercent = _lib
          .lookup<NativeFunction<YGNodeStyleSetMaxHeightPercentFunc>>(
            'YGNodeStyleSetMaxHeightPercent',
          )
          .asFunction();

      _ygNodeStyleSetAspectRatio = _lib
          .lookup<NativeFunction<YGNodeStyleSetAspectRatioFunc>>(
            'YGNodeStyleSetAspectRatio',
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
      _ygNodeLayoutGetTop = _lib
          .lookup<NativeFunction<YGNodeLayoutGetTopFunc>>('YGNodeLayoutGetTop')
          .asFunction();
      _ygNodeLayoutGetRight = _lib
          .lookup<NativeFunction<YGNodeLayoutGetRightFunc>>(
            'YGNodeLayoutGetRight',
          )
          .asFunction();
      _ygNodeLayoutGetBottom = _lib
          .lookup<NativeFunction<YGNodeLayoutGetBottomFunc>>(
            'YGNodeLayoutGetBottom',
          )
          .asFunction();
      _ygNodeLayoutGetWidth = _lib
          .lookup<NativeFunction<YGNodeLayoutGetWidthFunc>>(
            'YGNodeLayoutGetWidth',
          )
          .asFunction();
      _ygNodeLayoutGetHeight = _lib
          .lookup<NativeFunction<YGNodeLayoutGetHeightFunc>>(
            'YGNodeLayoutGetHeight',
          )
          .asFunction();
      _ygNodeLayoutGetDirection = _lib
          .lookup<NativeFunction<YGNodeLayoutGetDirectionFunc>>(
            'YGNodeLayoutGetDirection',
          )
          .asFunction();
      _ygNodeLayoutGetHadOverflow = _lib
          .lookup<NativeFunction<YGNodeLayoutGetHadOverflowFunc>>(
            'YGNodeLayoutGetHadOverflow',
          )
          .asFunction();
    } catch (e) {
      print("Failed to lookup symbols: $e");
      rethrow;
    }
  }

  Pointer<Void> newNode() => _ygNodeNew();
  void freeNode(Pointer<Void> node) => _ygNodeFree(node);
  void resetNode(Pointer<Void> node) => _ygNodeReset(node);
  void freeNodeRecursive(Pointer<Void> node) => _ygNodeFreeRecursive(node);
  void markDirty(Pointer<Void> node) => _ygNodeMarkDirty(node);
  void setNodeType(Pointer<Void> node, int nodeType) =>
      _ygNodeSetNodeType(node, nodeType);
  int getNodeType(Pointer<Void> node) => _ygNodeGetNodeType(node);
  void copyStyle(Pointer<Void> dstNode, Pointer<Void> srcNode) =>
      _ygNodeCopyStyle(dstNode, srcNode);

  void insertChild(Pointer<Void> node, Pointer<Void> child, int index) =>
      _ygNodeInsertChild(node, child, index);
  void removeChild(Pointer<Void> node, Pointer<Void> child) =>
      _ygNodeRemoveChild(node, child);
  void removeAllChildren(Pointer<Void> node) => _ygNodeRemoveAllChildren(node);
  Pointer<Void> getChild(Pointer<Void> node, int index) =>
      _ygNodeGetChild(node, index);
  int getChildCount(Pointer<Void> node) => _ygNodeGetChildCount(node);
  Pointer<Void> getParent(Pointer<Void> node) => _ygNodeGetParent(node);

  void setDirection(Pointer<Void> node, int direction) =>
      _ygNodeStyleSetDirection(node, direction);
  void setFlexDirection(Pointer<Void> node, int flexDirection) =>
      _ygNodeStyleSetFlexDirection(node, flexDirection);
  void setJustifyContent(Pointer<Void> node, int justifyContent) =>
      _ygNodeStyleSetJustifyContent(node, justifyContent);
  void setAlignContent(Pointer<Void> node, int alignContent) =>
      _ygNodeStyleSetAlignContent(node, alignContent);
  void setAlignItems(Pointer<Void> node, int alignItems) =>
      _ygNodeStyleSetAlignItems(node, alignItems);
  void setAlignSelf(Pointer<Void> node, int alignSelf) =>
      _ygNodeStyleSetAlignSelf(node, alignSelf);
  void setPositionType(Pointer<Void> node, int positionType) =>
      _ygNodeStyleSetPositionType(node, positionType);
  void setFlexWrap(Pointer<Void> node, int flexWrap) =>
      _ygNodeStyleSetFlexWrap(node, flexWrap);
  void setOverflow(Pointer<Void> node, int overflow) =>
      _ygNodeStyleSetOverflow(node, overflow);
  void setDisplay(Pointer<Void> node, int display) =>
      _ygNodeStyleSetDisplay(node, display);

  void setFlex(Pointer<Void> node, double flex) =>
      _ygNodeStyleSetFlex(node, flex);
  void setFlexGrow(Pointer<Void> node, double flexGrow) =>
      _ygNodeStyleSetFlexGrow(node, flexGrow);
  void setFlexShrink(Pointer<Void> node, double flexShrink) =>
      _ygNodeStyleSetFlexShrink(node, flexShrink);
  void setFlexBasis(Pointer<Void> node, double flexBasis) =>
      _ygNodeStyleSetFlexBasis(node, flexBasis);
  void setFlexBasisPercent(Pointer<Void> node, double flexBasis) =>
      _ygNodeStyleSetFlexBasisPercent(node, flexBasis);
  void setFlexBasisAuto(Pointer<Void> node) =>
      _ygNodeStyleSetFlexBasisAuto(node);

  void setPosition(Pointer<Void> node, int edge, double position) =>
      _ygNodeStyleSetPosition(node, edge, position);
  void setPositionPercent(Pointer<Void> node, int edge, double position) =>
      _ygNodeStyleSetPositionPercent(node, edge, position);

  void setMargin(Pointer<Void> node, int edge, double margin) =>
      _ygNodeStyleSetMargin(node, edge, margin);
  void setMarginPercent(Pointer<Void> node, int edge, double margin) =>
      _ygNodeStyleSetMarginPercent(node, edge, margin);
  void setMarginAuto(Pointer<Void> node, int edge) =>
      _ygNodeStyleSetMarginAuto(node, edge);

  void setPadding(Pointer<Void> node, int edge, double padding) =>
      _ygNodeStyleSetPadding(node, edge, padding);
  void setPaddingPercent(Pointer<Void> node, int edge, double padding) =>
      _ygNodeStyleSetPaddingPercent(node, edge, padding);

  void setBorder(Pointer<Void> node, int edge, double border) =>
      _ygNodeStyleSetBorder(node, edge, border);

  void setWidth(Pointer<Void> node, double width) =>
      _ygNodeStyleSetWidth(node, width);
  void setWidthPercent(Pointer<Void> node, double width) =>
      _ygNodeStyleSetWidthPercent(node, width);
  void setWidthAuto(Pointer<Void> node) => _ygNodeStyleSetWidthAuto(node);

  void setHeight(Pointer<Void> node, double height) =>
      _ygNodeStyleSetHeight(node, height);
  void setHeightPercent(Pointer<Void> node, double height) =>
      _ygNodeStyleSetHeightPercent(node, height);
  void setHeightAuto(Pointer<Void> node) => _ygNodeStyleSetHeightAuto(node);

  void setMinWidth(Pointer<Void> node, double minWidth) =>
      _ygNodeStyleSetMinWidth(node, minWidth);
  void setMinWidthPercent(Pointer<Void> node, double minWidth) =>
      _ygNodeStyleSetMinWidthPercent(node, minWidth);

  void setMinHeight(Pointer<Void> node, double minHeight) =>
      _ygNodeStyleSetMinHeight(node, minHeight);
  void setMinHeightPercent(Pointer<Void> node, double minHeight) =>
      _ygNodeStyleSetMinHeightPercent(node, minHeight);

  void setMaxWidth(Pointer<Void> node, double maxWidth) =>
      _ygNodeStyleSetMaxWidth(node, maxWidth);
  void setMaxWidthPercent(Pointer<Void> node, double maxWidth) =>
      _ygNodeStyleSetMaxWidthPercent(node, maxWidth);

  void setMaxHeight(Pointer<Void> node, double maxHeight) =>
      _ygNodeStyleSetMaxHeight(node, maxHeight);
  void setMaxHeightPercent(Pointer<Void> node, double maxHeight) =>
      _ygNodeStyleSetMaxHeightPercent(node, maxHeight);

  void setAspectRatio(Pointer<Void> node, double aspectRatio) =>
      _ygNodeStyleSetAspectRatio(node, aspectRatio);

  void calculateLayout(
    Pointer<Void> node, {
    double availableWidth = double.nan,
    double availableHeight = double.nan,
    int ownerDirection = YGDirection.ltr,
  }) => _ygNodeCalculateLayout(
    node,
    availableWidth,
    availableHeight,
    ownerDirection,
  );

  double getLeft(Pointer<Void> node) => _ygNodeLayoutGetLeft(node);
  double getTop(Pointer<Void> node) => _ygNodeLayoutGetTop(node);
  double getRight(Pointer<Void> node) => _ygNodeLayoutGetRight(node);
  double getBottom(Pointer<Void> node) => _ygNodeLayoutGetBottom(node);
  double getLayoutWidth(Pointer<Void> node) => _ygNodeLayoutGetWidth(node);
  double getLayoutHeight(Pointer<Void> node) => _ygNodeLayoutGetHeight(node);
  int getLayoutDirection(Pointer<Void> node) => _ygNodeLayoutGetDirection(node);
  bool getHadOverflow(Pointer<Void> node) => _ygNodeLayoutGetHadOverflow(node);
}
