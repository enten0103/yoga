part of '../../../html_div.dart';

extension _RenderHtmlDivImageStreamsExt on RenderHtmlDiv {
  void _stopListeningToBorderImages() {
    for (final entry in _borderImageStreams.entries) {
      final provider = entry.key;
      final stream = entry.value;
      final listener = _borderImageListeners[provider];
      if (listener != null) stream.removeListener(listener);
    }
    _borderImageStreams.clear();
    _borderImageInfos.clear();
    _borderImageListeners.clear();
  }

  void _stopListeningToBackgroundImage() {
    final ImageStream? stream = _backgroundImageStream;
    final ImageStreamListener? listener = _backgroundImageListener;
    if (stream != null && listener != null) {
      stream.removeListener(listener);
    }
    _backgroundImageStream = null;
    _backgroundImageListener = null;
    _backgroundImageInfo = null;
    _backgroundImageProvider = null;
  }

  void _resolveBackgroundImage() {
    if (!attached) return;

    final ImageProvider? provider = _background?.image?.image;
    if (provider == null) {
      if (_backgroundImageProvider != null) {
        _stopListeningToBackgroundImage();
        markNeedsPaint();
      }
      return;
    }

    final ImageStream newStream = provider.resolve(_imageConfiguration);
    final ImageStream? oldStream = _backgroundImageStream;

    if (_backgroundImageProvider == provider &&
        oldStream?.key == newStream.key &&
        _backgroundImageListener != null) {
      return;
    }

    if (oldStream != null && _backgroundImageListener != null) {
      oldStream.removeListener(_backgroundImageListener!);
    }

    _backgroundImageProvider = provider;
    _backgroundImageStream = newStream;
    _backgroundImageListener = ImageStreamListener(
      (ImageInfo image, bool synchronousCall) {
        _backgroundImageInfo = image;
        markNeedsPaint();
      },
      onError: (Object exception, StackTrace? stackTrace) {
        _backgroundImageInfo = null;
        markNeedsPaint();
      },
    );
    newStream.addListener(_backgroundImageListener!);
  }

  Iterable<ImageProvider> _collectBorderImageProviders() sync* {
    final HtmlBorder? b = _border;
    final HtmlBorderImage? base = b?.borderImage;
    if (base == null) return;

    yield base.image;
    final HtmlBorderImageSides? sides = b?.borderImageSides;
    if (sides?.top != null) yield sides!.top!.image;
    if (sides?.right != null) yield sides!.right!.image;
    if (sides?.bottom != null) yield sides!.bottom!.image;
    if (sides?.left != null) yield sides!.left!.image;
  }

  void _resolveBorderImages() {
    if (!attached) return;

    final Set<ImageProvider> required = _collectBorderImageProviders().toSet();

    // Remove old listeners.
    final List<ImageProvider> toRemove = _borderImageStreams.keys
        .where((p) => !required.contains(p))
        .toList(growable: false);
    for (final provider in toRemove) {
      final stream = _borderImageStreams.remove(provider);
      final listener = _borderImageListeners.remove(provider);
      if (stream != null && listener != null) stream.removeListener(listener);
      _borderImageInfos.remove(provider);
    }

    // Add/update required.
    for (final provider in required) {
      final ImageStream newStream = provider.resolve(_imageConfiguration);
      final ImageStream? oldStream = _borderImageStreams[provider];

      if (oldStream?.key == newStream.key &&
          _borderImageListeners.containsKey(provider)) {
        continue;
      }

      final oldListener = _borderImageListeners[provider];
      if (oldStream != null && oldListener != null) {
        oldStream.removeListener(oldListener);
      }

      final listener = ImageStreamListener(
        (ImageInfo image, bool synchronousCall) {
          _borderImageInfos[provider] = image;
          markNeedsPaint();
        },
        onError: (Object exception, StackTrace? stackTrace) {
          _borderImageInfos[provider] = null;
          markNeedsPaint();
        },
      );

      _borderImageStreams[provider] = newStream;
      _borderImageListeners[provider] = listener;
      newStream.addListener(listener);
    }
  }
}
