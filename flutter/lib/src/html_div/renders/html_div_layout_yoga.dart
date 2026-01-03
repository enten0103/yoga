part of '../../../html_div.dart';

extension _RenderHtmlDivLayoutYogaExt on RenderHtmlDiv {
  Yoga? _ensureYogaOrNull() {
    if (_yoga != null) return _yoga;
    if (RenderHtmlDiv._sharedYoga != null) {
      return _yoga = RenderHtmlDiv._sharedYoga;
    }
    if (RenderHtmlDiv._sharedYogaUnavailable) return null;
    try {
      final Yoga yoga = Yoga();
      RenderHtmlDiv._sharedYoga = yoga;
      _yoga = yoga;
      return yoga;
    } catch (_) {
      RenderHtmlDiv._sharedYogaUnavailable = true;
      return null;
    }
  }

  int _toYGFlexDirection(HtmlFlexDirection v) {
    return switch (v) {
      HtmlFlexDirection.row => YGFlexDirection.row,
      HtmlFlexDirection.rowReverse => YGFlexDirection.rowReverse,
      HtmlFlexDirection.column => YGFlexDirection.column,
      HtmlFlexDirection.columnReverse => YGFlexDirection.columnReverse,
    };
  }

  int _toYGJustifyContent(HtmlJustifyContent v) {
    return switch (v) {
      HtmlJustifyContent.flexStart => YGJustify.flexStart,
      HtmlJustifyContent.center => YGJustify.center,
      HtmlJustifyContent.flexEnd => YGJustify.flexEnd,
      HtmlJustifyContent.spaceBetween => YGJustify.spaceBetween,
      HtmlJustifyContent.spaceAround => YGJustify.spaceAround,
      HtmlJustifyContent.spaceEvenly => YGJustify.spaceEvenly,
    };
  }

  int _toYGAlignItems(HtmlAlignItems v) {
    return switch (v) {
      HtmlAlignItems.stretch => YGAlign.stretch,
      HtmlAlignItems.flexStart => YGAlign.flexStart,
      HtmlAlignItems.center => YGAlign.center,
      HtmlAlignItems.flexEnd => YGAlign.flexEnd,
      HtmlAlignItems.baseline => YGAlign.baseline,
    };
  }

  int _toYGAlignSelf(HtmlAlignSelf v) {
    return switch (v) {
      HtmlAlignSelf.auto => YGAlign.auto,
      HtmlAlignSelf.stretch => YGAlign.stretch,
      HtmlAlignSelf.flexStart => YGAlign.flexStart,
      HtmlAlignSelf.center => YGAlign.center,
      HtmlAlignSelf.flexEnd => YGAlign.flexEnd,
      HtmlAlignSelf.baseline => YGAlign.baseline,
    };
  }

  int _toYGWrap(HtmlFlexWrap v) {
    return switch (v) {
      HtmlFlexWrap.noWrap => YGWrap.noWrap,
      HtmlFlexWrap.wrap => YGWrap.wrap,
      HtmlFlexWrap.wrapReverse => YGWrap.wrapReverse,
    };
  }

  void _applyFlexBasis(
    Yoga yoga,
    ffi.Pointer<ffi.Void> node,
    HtmlLength basis,
    double referenceWidth,
  ) {
    if (basis.isAuto) {
      yoga.setFlexBasisAuto(node);
      return;
    }
    if (basis.isPercent) {
      yoga.setFlexBasisPercent(node, basis.value);
      return;
    }
    yoga.setFlexBasis(node, basis.resolvePx(reference: referenceWidth));
  }

  void _applyYogaSizeFromHtmlSize(
    Yoga yoga,
    ffi.Pointer<ffi.Void> node, {
    required bool isWidth,
    required HtmlSize size,
  }) {
    if (size is FixedSize) {
      if (isWidth) {
        yoga.setWidth(node, size.value);
      } else {
        yoga.setHeight(node, size.value);
      }
      return;
    }
    if (size is PercentSize) {
      if (isWidth) {
        yoga.setWidthPercent(node, size.value);
      } else {
        yoga.setHeightPercent(node, size.value);
      }
      return;
    }
    if (isWidth) {
      yoga.setWidthAuto(node);
    } else {
      yoga.setHeightAuto(node);
    }
  }

  double? _performFlexLayoutIfPossible({
    required double contentWidth,
    required double xOffset,
    required double yOffset,
    required double availableBorderBoxHeight,
    required double borderVertical,
    required double paddingVertical,
  }) {
    final Yoga? yoga = _ensureYogaOrNull();
    if (yoga == null) return null;
    return _performFlexLayoutWithYoga(
      yoga: yoga,
      contentWidth: contentWidth,
      xOffset: xOffset,
      yOffset: yOffset,
      availableBorderBoxHeight: availableBorderBoxHeight,
      borderVertical: borderVertical,
      paddingVertical: paddingVertical,
    );
  }

  double _performFlexLayoutWithYoga({
    required Yoga yoga,
    required double contentWidth,
    required double xOffset,
    required double yOffset,
    required double availableBorderBoxHeight,
    required double borderVertical,
    required double paddingVertical,
  }) {
    final ffi.Pointer<ffi.Void> root = yoga.newNode();

    final List<RenderBox> children = <RenderBox>[];
    RenderBox? child = firstChild;
    while (child != null) {
      children.add(child);
      child = (child.parentData! as HtmlDivParentData).nextSibling;
    }

    final List<ffi.Pointer<ffi.Void>> childNodes = <ffi.Pointer<ffi.Void>>[];

    try {
      yoga.setDisplay(root, YGDisplay.flex);
      yoga.setFlexDirection(root, _toYGFlexDirection(_flexDirection));
      yoga.setJustifyContent(root, _toYGJustifyContent(_justifyContent));
      yoga.setAlignItems(root, _toYGAlignItems(_alignItems));
      yoga.setFlexWrap(root, _toYGWrap(_flexWrap));

      yoga.setWidth(root, contentWidth);

      double? resolveRootContentLimit(HtmlSize? v) {
        if (v == null) return null;
        double? borderBox;
        if (v is FixedSize) {
          borderBox = v.value;
        } else if (v is PercentSize && availableBorderBoxHeight.isFinite) {
          borderBox = availableBorderBoxHeight * v.value / 100.0;
        } else {
          return null;
        }

        if (_boxSizing == HtmlBoxSizing.borderBox) {
          borderBox = math.max(
            0.0,
            borderBox - borderVertical - paddingVertical,
          );
        }
        return borderBox;
      }

      double? rootMinH = resolveRootContentLimit(_minHeight);
      double? rootMaxH = resolveRootContentLimit(_maxHeight);
      if (rootMinH != null && rootMaxH != null && rootMaxH < rootMinH) {
        rootMaxH = rootMinH;
      }

      double? explicitRootContentHeight;
      if (_height is FixedSize) {
        final double h = (_height as FixedSize).value;
        explicitRootContentHeight = _boxSizing == HtmlBoxSizing.borderBox
            ? math.max(0.0, h - borderVertical - paddingVertical)
            : h;
      } else if (_height is PercentSize && constraints.hasBoundedHeight) {
        final double h =
            constraints.maxHeight * (_height as PercentSize).value / 100.0;
        explicitRootContentHeight = _boxSizing == HtmlBoxSizing.borderBox
            ? math.max(0.0, h - borderVertical - paddingVertical)
            : h;
      }

      // Yoga may not clamp an explicit height against maxHeight when the root
      // has unbounded availableHeight (e.g. inside ListView). Clamp eagerly to
      // match CSS used values.
      double? usedRootContentHeight = explicitRootContentHeight;
      if (usedRootContentHeight != null) {
        if (rootMinH != null) {
          usedRootContentHeight = math.max(usedRootContentHeight, rootMinH);
        }
        if (rootMaxH != null) {
          usedRootContentHeight = math.min(usedRootContentHeight, rootMaxH);
        }
        yoga.setHeight(root, usedRootContentHeight);
      } else {
        yoga.setHeightAuto(root);
      }

      if (rootMinH != null) yoga.setMinHeight(root, rootMinH);
      if (rootMaxH != null) yoga.setMaxHeight(root, rootMaxH);

      final bool mainAxisIsRow =
          _flexDirection == HtmlFlexDirection.row ||
          _flexDirection == HtmlFlexDirection.rowReverse;

      double preMeasureMaxHeight = (() {
        if (_height is FixedSize) {
          final double h = (_height as FixedSize).value;
          return _boxSizing == HtmlBoxSizing.borderBox
              ? math.max(0.0, h - borderVertical - paddingVertical)
              : h;
        }
        if (_height is PercentSize && availableBorderBoxHeight.isFinite) {
          final double h =
              availableBorderBoxHeight * (_height as PercentSize).value / 100.0;
          return _boxSizing == HtmlBoxSizing.borderBox
              ? math.max(0.0, h - borderVertical - paddingVertical)
              : h;
        }
        if (availableBorderBoxHeight.isFinite) {
          return math.max(
            0.0,
            availableBorderBoxHeight - borderVertical - paddingVertical,
          );
        }
        return double.infinity;
      })();

      if (usedRootContentHeight != null && usedRootContentHeight.isFinite) {
        preMeasureMaxHeight = math.min(
          preMeasureMaxHeight,
          usedRootContentHeight,
        );
      }
      if (rootMaxH != null && rootMaxH.isFinite) {
        preMeasureMaxHeight = math.min(preMeasureMaxHeight, rootMaxH);
      }

      double? resolveChildLimitContentPx(
        RenderHtmlDiv child,
        HtmlSize? v, {
        required bool isWidthAxis,
      }) {
        if (v == null) return null;

        double? borderBox;
        if (v is FixedSize) {
          borderBox = v.value;
        } else if (v is PercentSize) {
          final double ref = isWidthAxis ? contentWidth : preMeasureMaxHeight;
          if (!ref.isFinite) return null;
          borderBox = ref * v.value / 100.0;
        } else {
          return null;
        }

        if (child._boxSizing == HtmlBoxSizing.borderBox) {
          // CSS: percentage padding/margin is resolved against the containing
          // block's width (here: parent contentWidth), not the child's own size.
          final double containingBlockWidth = contentWidth;
          final EdgeInsets childBorder = child._calculateBorderWidths(
            containingBlockWidth,
          );
          final EdgeInsets childPadding =
              child._padding?.resolve(referenceWidth: containingBlockWidth) ??
              EdgeInsets.zero;
          final double sub = isWidthAxis
              ? (childBorder.horizontal + childPadding.horizontal)
              : (childBorder.vertical + childPadding.vertical);
          borderBox = math.max(0.0, borderBox - sub);
        }

        return borderBox;
      }

      for (final RenderBox c in children) {
        // Loose pre-layout for a measurable basis.
        c.layout(
          BoxConstraints(
            minWidth: 0,
            // For flex-basis:auto we want a content-based (intrinsic) main-axis
            // measurement, not a stretched-to-container one.
            maxWidth: mainAxisIsRow ? double.infinity : contentWidth,
            minHeight: 0,
            maxHeight: preMeasureMaxHeight,
          ),
          parentUsesSize: true,
        );

        final ffi.Pointer<ffi.Void> node = yoga.newNode();
        childNodes.add(node);
        yoga.insertChild(root, node, childNodes.length - 1);

        // Flex item styles.
        if (c is RenderHtmlDiv) {
          yoga.setFlexGrow(node, c._flexGrow);
          yoga.setFlexShrink(node, c._flexShrink);
          _applyFlexBasis(yoga, node, c._flexBasis, contentWidth);
          yoga.setAlignSelf(node, _toYGAlignSelf(c._alignSelf));
        } else {
          yoga.setFlexGrow(node, 0.0);
          yoga.setFlexShrink(node, 1.0);
          yoga.setFlexBasisAuto(node);
          yoga.setAlignSelf(node, YGAlign.auto);
        }

        // Margin.
        final HtmlMargin? mObj = RenderHtmlDiv._readChildHtmlMargin(c);
        if (mObj != null) {
          if (mObj.left.isAuto) {
            yoga.setMarginAuto(node, YGEdge.left);
          } else {
            yoga.setMargin(
              node,
              YGEdge.left,
              mObj.left.resolvePx(reference: contentWidth),
            );
          }
          if (mObj.right.isAuto) {
            yoga.setMarginAuto(node, YGEdge.right);
          } else {
            yoga.setMargin(
              node,
              YGEdge.right,
              mObj.right.resolvePx(reference: contentWidth),
            );
          }
          yoga.setMargin(
            node,
            YGEdge.top,
            mObj.top.isAuto ? 0.0 : mObj.top.resolvePx(reference: contentWidth),
          );
          yoga.setMargin(
            node,
            YGEdge.bottom,
            mObj.bottom.isAuto
                ? 0.0
                : mObj.bottom.resolvePx(reference: contentWidth),
          );
        }

        // Size. Forward explicit width/height; otherwise use measured size.
        if (c is RenderHtmlDiv) {
          final HtmlSize w = c._width;
          final HtmlSize h = c._height;
          final HtmlLength basis = c._flexBasis;

          // Apply min/max constraints to Yoga so that the final tight layout
          // respects CSS-like size limits (otherwise the child render box can't
          // shrink when given tight constraints).
          double? childMinW = resolveChildLimitContentPx(
            c,
            c._minWidth,
            isWidthAxis: true,
          );
          double? childMaxW = resolveChildLimitContentPx(
            c,
            c._maxWidth,
            isWidthAxis: true,
          );
          if (childMinW != null && childMaxW != null && childMaxW < childMinW) {
            childMaxW = childMinW;
          }
          if (childMinW != null) yoga.setMinWidth(node, childMinW);
          if (childMaxW != null) yoga.setMaxWidth(node, childMaxW);

          double? childMinH = resolveChildLimitContentPx(
            c,
            c._minHeight,
            isWidthAxis: false,
          );
          double? childMaxH = resolveChildLimitContentPx(
            c,
            c._maxHeight,
            isWidthAxis: false,
          );
          if (childMinH != null && childMaxH != null && childMaxH < childMinH) {
            childMaxH = childMinH;
          }
          if (childMinH != null) yoga.setMinHeight(node, childMinH);
          if (childMaxH != null) yoga.setMaxHeight(node, childMaxH);

          if (mainAxisIsRow) {
            if (w is FixedSize || w is PercentSize) {
              _applyYogaSizeFromHtmlSize(yoga, node, isWidth: true, size: w);
            } else {
              yoga.setWidthAuto(node);
              // Only treat the measured main size as the basis when flex-basis is auto.
              // Otherwise (e.g. flex-basis:0) keep the explicit basis already applied.
              if (basis.isAuto) {
                yoga.setFlexBasis(node, c.size.width);
              }
            }

            if (_alignItems == HtmlAlignItems.stretch &&
                !(h is FixedSize || h is PercentSize)) {
              yoga.setHeightAuto(node);
            } else if (h is FixedSize || h is PercentSize) {
              _applyYogaSizeFromHtmlSize(yoga, node, isWidth: false, size: h);
            } else {
              yoga.setHeight(node, c.size.height);
            }
          } else {
            if (h is FixedSize || h is PercentSize) {
              _applyYogaSizeFromHtmlSize(yoga, node, isWidth: false, size: h);
            } else {
              yoga.setHeightAuto(node);
              if (basis.isAuto) {
                yoga.setFlexBasis(node, c.size.height);
              }
            }

            if (_alignItems == HtmlAlignItems.stretch &&
                !(w is FixedSize || w is PercentSize)) {
              yoga.setWidthAuto(node);
            } else if (w is FixedSize || w is PercentSize) {
              _applyYogaSizeFromHtmlSize(yoga, node, isWidth: true, size: w);
            } else {
              yoga.setWidth(node, c.size.width);
            }
          }
        } else {
          yoga.setWidth(node, c.size.width);
          yoga.setHeight(node, c.size.height);
        }
      }

      final double availableContentHeight = availableBorderBoxHeight.isFinite
          ? math.max(
              0.0,
              availableBorderBoxHeight - borderVertical - paddingVertical,
            )
          : ((usedRootContentHeight != null && usedRootContentHeight.isFinite)
                ? usedRootContentHeight
                : double.nan);

      yoga.calculateLayout(
        root,
        availableWidth: contentWidth,
        availableHeight: availableContentHeight,
      );

      double maxBottom = yOffset;
      for (int i = 0; i < children.length; i++) {
        final RenderBox c = children[i];
        final ffi.Pointer<ffi.Void> node = childNodes[i];

        final double left = yoga.getLeft(node);
        final double top = yoga.getTop(node);
        final double w = yoga.getLayoutWidth(node);
        final double h = yoga.getLayoutHeight(node);

        c.layout(
          BoxConstraints.tightFor(width: w, height: h),
          parentUsesSize: true,
        );

        final HtmlDivParentData pd = c.parentData! as HtmlDivParentData;
        pd.offset = Offset(xOffset + left, yOffset + top);
        maxBottom = math.max(maxBottom, pd.offset.dy + c.size.height);
      }

      return math.max(0.0, maxBottom - yOffset);
    } finally {
      try {
        yoga.freeNodeRecursive(root);
      } catch (_) {
        // ignore
      }
    }
  }
}
