import 'package:flutter/widgets.dart';
import 'package:flutter_yoga/src/rendering/yoga_sliver_layout.dart';

class YogaScrollController extends ScrollController {
  YogaScrollController({
    super.initialScrollOffset,
    super.keepScrollOffset,
    super.debugLabel,
  });

  RenderSliverYogaLayout? _renderSliver;

  void attachRenderSliver(RenderSliverYogaLayout renderSliver) {
    _renderSliver = renderSliver;
  }

  void detachRenderSliver() {
    _renderSliver = null;
  }

  Future<void> scrollToIndex(
    int index, {
    Duration? duration,
    Curve? curve,
  }) async {
    if (_renderSliver != null) {
      final double offset = await _renderSliver!.measureOffsetForIndex(index);
      if (duration != null) {
        animateTo(offset, duration: duration, curve: curve ?? Curves.ease);
      } else {
        jumpTo(offset);
      }
    }
  }
}
