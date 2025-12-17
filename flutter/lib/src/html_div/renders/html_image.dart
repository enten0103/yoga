part of '../../../html_div.dart';

class RenderHtmlImage extends RenderBox {
  ImageProvider _image;
  BoxFit _fit;
  Alignment _alignment;
  FilterQuality _filterQuality;
  HtmlSize _width;
  HtmlSize _height;
  Size _placeholderSize;
  ImageConfiguration _imageConfiguration;
  ImageStream? _imageStream;
  ImageStreamListener? _imageStreamListener;
  ui.Image? _resolvedImage;
  double _resolvedScale = 1.0;
  Size? _metadataLogicalSize;
  int _sizeHintRequestId = 0;
  String? _debugLabel;
  TextStyle _debugLabelTextStyle;
  EdgeInsets _debugLabelPadding;
  Color _debugLabelBackgroundColor;

  RenderHtmlImage({
    required ImageProvider image,
    required BoxFit fit,
    required Alignment alignment,
    required FilterQuality filterQuality,
    required HtmlSize width,
    required HtmlSize height,
    required Size placeholderSize,
    required String? debugLabel,
    required TextStyle debugLabelTextStyle,
    required EdgeInsets debugLabelPadding,
    required Color debugLabelBackgroundColor,
    required ImageConfiguration imageConfiguration,
  }) : _image = image,
       _fit = fit,
       _alignment = alignment,
       _filterQuality = filterQuality,
       _width = width,
       _height = height,
       _placeholderSize = placeholderSize,
       _debugLabel = debugLabel,
       _debugLabelTextStyle = debugLabelTextStyle,
       _debugLabelPadding = debugLabelPadding,
       _debugLabelBackgroundColor = debugLabelBackgroundColor,
       _imageConfiguration = imageConfiguration {
    _resolveImage();
  }

  ImageProvider get image => _image;
  set image(ImageProvider value) {
    if (_image == value) return;
    _image = value;
    _resolveImage();
  }

  BoxFit get fit => _fit;
  set fit(BoxFit value) {
    if (_fit == value) return;
    _fit = value;
    markNeedsPaint();
  }

  Alignment get alignment => _alignment;
  set alignment(Alignment value) {
    if (_alignment == value) return;
    _alignment = value;
    markNeedsPaint();
  }

  FilterQuality get filterQuality => _filterQuality;
  set filterQuality(FilterQuality value) {
    if (_filterQuality == value) return;
    _filterQuality = value;
    markNeedsPaint();
  }

  HtmlSize get width => _width;
  set width(HtmlSize value) {
    if (_width == value) return;
    _width = value;
    markNeedsLayout();
  }

  HtmlSize get height => _height;
  set height(HtmlSize value) {
    if (_height == value) return;
    _height = value;
    markNeedsLayout();
  }

  Size get placeholderSize => _placeholderSize;
  set placeholderSize(Size value) {
    if (_placeholderSize == value) return;
    _placeholderSize = value;
    markNeedsLayout();
    markNeedsPaint();
  }

  String? get debugLabel => _debugLabel;
  set debugLabel(String? value) {
    if (_debugLabel == value) return;
    _debugLabel = value;
    markNeedsPaint();
  }

  TextStyle get debugLabelTextStyle => _debugLabelTextStyle;
  set debugLabelTextStyle(TextStyle value) {
    if (_debugLabelTextStyle == value) return;
    _debugLabelTextStyle = value;
    markNeedsPaint();
  }

  EdgeInsets get debugLabelPadding => _debugLabelPadding;
  set debugLabelPadding(EdgeInsets value) {
    if (_debugLabelPadding == value) return;
    _debugLabelPadding = value;
    markNeedsPaint();
  }

  Color get debugLabelBackgroundColor => _debugLabelBackgroundColor;
  set debugLabelBackgroundColor(Color value) {
    if (_debugLabelBackgroundColor == value) return;
    _debugLabelBackgroundColor = value;
    markNeedsPaint();
  }

  ImageConfiguration get imageConfiguration => _imageConfiguration;
  set imageConfiguration(ImageConfiguration value) {
    if (_imageConfiguration == value) return;
    _imageConfiguration = value;
    _resolveImage();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties.add(DiagnosticsProperty<ImageProvider>('image', _image));
    properties.add(EnumProperty<BoxFit>('fit', _fit));
    properties.add(DiagnosticsProperty<Alignment>('alignment', _alignment));
    properties.add(
      EnumProperty<FilterQuality>('filterQuality', _filterQuality),
    );

    properties.add(DiagnosticsProperty<HtmlSize>('width', _width));
    properties.add(DiagnosticsProperty<HtmlSize>('height', _height));
    properties.add(
      DiagnosticsProperty<Size>('placeholderSize', _placeholderSize),
    );
    properties.add(
      DiagnosticsProperty<ImageConfiguration>(
        'imageConfiguration',
        _imageConfiguration,
      ),
    );

    properties.add(StringProperty('debugLabel', _debugLabel));
    properties.add(
      DiagnosticsProperty<TextStyle>(
        'debugLabelTextStyle',
        _debugLabelTextStyle,
      ),
    );
    properties.add(
      DiagnosticsProperty<EdgeInsets>('debugLabelPadding', _debugLabelPadding),
    );
    properties.add(
      ColorProperty('debugLabelBackgroundColor', _debugLabelBackgroundColor),
    );

    // Runtime state (not inputs, but useful for debugging)
    properties.add(DoubleProperty('resolvedScale', _resolvedScale));
    properties.add(
      FlagProperty(
        'hasResolvedImage',
        value: _resolvedImage != null,
        ifTrue: 'true',
        ifFalse: 'false',
      ),
    );
    properties.add(
      DiagnosticsProperty<Size?>(
        'resolvedImageLogicalSize',
        _resolvedImage == null
            ? null
            : Size(
                _resolvedImage!.width.toDouble() / _resolvedScale,
                _resolvedImage!.height.toDouble() / _resolvedScale,
              ),
      ),
    );
    properties.add(
      DiagnosticsProperty<Size?>('metadataLogicalSize', _metadataLogicalSize),
    );
    properties.add(IntProperty('sizeHintRequestId', _sizeHintRequestId));
    properties.add(
      DiagnosticsProperty<Object?>('imageStreamKey', _imageStream?.key),
    );
  }

  @override
  void dispose() {
    _stopListeningToStream(clear: true);
    // Invalidate any in-flight size-hint requests.
    _sizeHintRequestId++;
    super.dispose();
  }

  void _stopListeningToStream({required bool clear}) {
    final ImageStream? stream = _imageStream;
    final ImageStreamListener? listener = _imageStreamListener;
    if (stream != null && listener != null) {
      stream.removeListener(listener);
    }
    if (clear) {
      _imageStream = null;
      _imageStreamListener = null;
    }
  }

  void _resolveImage() {
    final ImageStream newStream = _image.resolve(_imageConfiguration);
    if (_imageStream?.key == newStream.key) {
      return;
    }

    _stopListeningToStream(clear: true);
    _imageStream = newStream;
    _metadataLogicalSize = null;
    _resolveSizeHintForCurrentImage();

    final ImageStreamListener listener = ImageStreamListener(
      (ImageInfo info, bool _) {
        _resolvedImage = info.image;
        _resolvedScale = info.scale;
        markNeedsLayout();
        markNeedsPaint();
      },
      onError: (Object _, StackTrace? __) {
        _resolvedImage = null;
        _resolvedScale = 1.0;
        markNeedsLayout();
        markNeedsPaint();
      },
    );
    _imageStreamListener = listener;
    if (attached) {
      newStream.addListener(listener);
    }
  }

  Future<void> _resolveSizeHintForCurrentImage() async {
    final int requestId = ++_sizeHintRequestId;
    try {
      final ImageProvider provider = image_size_hint.unwrapProvider(_image);
      final Object key = await provider.obtainKey(_imageConfiguration);
      if (requestId != _sizeHintRequestId) return;

      Uint8List? bytes;
      double scale = 1.0;

      if (key is AssetBundleImageKey) {
        final ByteData data = await key.bundle.load(key.name);
        if (requestId != _sizeHintRequestId) return;
        bytes = data.buffer.asUint8List();
        scale = key.scale <= 0 ? 1.0 : key.scale;
      } else {
        bytes = await image_size_hint.tryLoadHeaderBytesForProvider(
          provider,
          maxBytes: 64 * 1024,
        );
        if (requestId != _sizeHintRequestId) return;
        final double? s = image_size_hint.tryGetScaleForProvider(provider);
        if (s != null && s > 0) scale = s;
      }

      if (bytes == null) return;
      final Size? px = _tryParseImagePixelSize(bytes);
      if (px == null) return;

      _metadataLogicalSize = Size(px.width / scale, px.height / scale);
      markNeedsLayout();
      markNeedsPaint();
    } catch (_) {
      // Best-effort only. Keep placeholder sizing if anything fails.
    }
  }

  static Size? _tryParseImagePixelSize(Uint8List bytes) {
    // PNG: signature then IHDR width/height at bytes 16..23.
    if (bytes.length >= 24 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47 &&
        bytes[4] == 0x0D &&
        bytes[5] == 0x0A &&
        bytes[6] == 0x1A &&
        bytes[7] == 0x0A) {
      final int w =
          (bytes[16] << 24) | (bytes[17] << 16) | (bytes[18] << 8) | bytes[19];
      final int h =
          (bytes[20] << 24) | (bytes[21] << 16) | (bytes[22] << 8) | bytes[23];
      if (w > 0 && h > 0) return Size(w.toDouble(), h.toDouble());
      return null;
    }

    // JPEG: scan markers for SOF segments.
    if (bytes.length >= 4 && bytes[0] == 0xFF && bytes[1] == 0xD8) {
      int i = 2;
      while (i + 3 < bytes.length) {
        if (bytes[i] != 0xFF) {
          i++;
          continue;
        }
        int marker = bytes[i + 1];

        // End of image / Start of scan: stop.
        if (marker == 0xD9 || marker == 0xDA) break;

        // Standalone markers without length.
        if (marker == 0x01 || (marker >= 0xD0 && marker <= 0xD7)) {
          i += 2;
          continue;
        }

        if (i + 3 >= bytes.length) break;
        final int length = (bytes[i + 2] << 8) | bytes[i + 3];
        if (length < 2) break;
        if (i + 1 + length >= bytes.length) break;

        final bool isSOF =
            (marker >= 0xC0 && marker <= 0xC3) ||
            (marker >= 0xC5 && marker <= 0xC7) ||
            (marker >= 0xC9 && marker <= 0xCB) ||
            (marker >= 0xCD && marker <= 0xCF);

        if (isSOF && i + 8 < bytes.length) {
          final int h = (bytes[i + 5] << 8) | bytes[i + 6];
          final int w = (bytes[i + 7] << 8) | bytes[i + 8];
          if (w > 0 && h > 0) return Size(w.toDouble(), h.toDouble());
          return null;
        }

        i += 2 + length;
      }
    }

    return null;
  }

  Size _naturalLogicalSize() {
    final ui.Image? img = _resolvedImage;
    if (img == null) {
      final Size? hinted = _metadataLogicalSize;
      if (hinted != null) {
        return Size(
          hinted.width.isFinite ? math.max(0.0, hinted.width) : 0.0,
          hinted.height.isFinite ? math.max(0.0, hinted.height) : 0.0,
        );
      }
      final double w = _placeholderSize.width;
      final double h = _placeholderSize.height;
      return Size(
        w.isFinite ? math.max(0.0, w) : 0.0,
        h.isFinite ? math.max(0.0, h) : 0.0,
      );
    }

    final double scale = _resolvedScale <= 0 ? 1.0 : _resolvedScale;
    return Size(img.width / scale, img.height / scale);
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    // Ensure we have a stream+listener and that it is attached.
    if (_imageStream == null || _imageStreamListener == null) {
      _resolveImage();
      return;
    }
    _imageStream!.addListener(_imageStreamListener!);
  }

  @override
  void detach() {
    // Detach should stop listening but keep cached stream/listener so
    // a re-attach can resume without losing the resolved image.
    _stopListeningToStream(clear: false);
    super.detach();
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    final Size natural = _naturalLogicalSize();
    if (!height.isFinite || height <= 0) return natural.width;
    if (natural.height <= 0) return 0;
    return height * (natural.width / natural.height);
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return computeMinIntrinsicWidth(height);
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    final Size natural = _naturalLogicalSize();
    if (!width.isFinite || width <= 0) return natural.height;
    if (natural.width <= 0) return 0;
    return width * (natural.height / natural.width);
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return computeMinIntrinsicHeight(width);
  }

  @override
  void performLayout() {
    final Size natural = _naturalLogicalSize();

    double? resolveAxis(HtmlSize v, {required bool isWidthAxis}) {
      if (v is FixedSize) return v.value;
      if (v is PercentSize) {
        if (isWidthAxis) {
          if (!constraints.hasBoundedWidth) return null;
          return constraints.maxWidth * v.value / 100.0;
        }
        if (!constraints.hasBoundedHeight) return null;
        return constraints.maxHeight * v.value / 100.0;
      }

      // AutoSize and any unsupported HtmlSize values.
      return null;
    }

    final double? resolvedW = resolveAxis(_width, isWidthAxis: true);
    final double? resolvedH = resolveAxis(_height, isWidthAxis: false);

    final bool hasW = resolvedW != null && resolvedW.isFinite;
    final bool hasH = resolvedH != null && resolvedH.isFinite;

    if (hasW && hasH) {
      // Both specified: allow stretching (CSS-like).
      size = constraints.constrain(
        Size(math.max(0.0, resolvedW), math.max(0.0, resolvedH)),
      );
      return;
    }

    if (hasW && !hasH) {
      if (natural.width > 0 && natural.height > 0) {
        final double h = resolvedW * (natural.height / natural.width);
        size = constraints.constrain(
          Size(math.max(0.0, resolvedW), math.max(0.0, h)),
        );
        return;
      }
    }

    if (!hasW && hasH) {
      if (natural.width > 0 && natural.height > 0) {
        final double w = resolvedH * (natural.width / natural.height);
        size = constraints.constrain(
          Size(math.max(0.0, w), math.max(0.0, resolvedH)),
        );
        return;
      }
    }

    // Both auto (or couldn't resolve): intrinsic size subject to constraints.
    size = constraints.constrainSizeAndAttemptToPreserveAspectRatio(natural);
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    final Rect rect = offset & size;
    final ui.Image? img = _resolvedImage;
    if (img != null && size.isFinite && !size.isEmpty) {
      paintImage(
        canvas: context.canvas,
        rect: rect,
        image: img,
        fit: _fit,
        alignment: _alignment,
        filterQuality: _filterQuality,
      );
    }

    final String? label = _debugLabel;
    if (label == null || label.isEmpty || size.isEmpty) return;

    final TextPainter tp =
        TextPainter(
          text: TextSpan(text: label, style: _debugLabelTextStyle),
          textDirection: TextDirection.ltr,
          maxLines: 1,
          ellipsis: '…',
        )..layout(
          maxWidth: math.max(0.0, size.width - _debugLabelPadding.horizontal),
        );

    final double boxW = math.min(
      size.width,
      tp.width + _debugLabelPadding.horizontal,
    );
    final double boxH = tp.height + _debugLabelPadding.vertical;
    final Rect labelRect = Rect.fromLTWH(
      rect.left + (size.width - boxW) / 2.0,
      rect.bottom - boxH,
      boxW,
      boxH,
    );

    final Paint p = Paint()..color = _debugLabelBackgroundColor;
    context.canvas.drawRect(labelRect, p);
    tp.paint(
      context.canvas,
      Offset(
        labelRect.left + _debugLabelPadding.left,
        labelRect.top + _debugLabelPadding.top,
      ),
    );
  }
}
