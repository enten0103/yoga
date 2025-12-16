import 'dart:typed_data';

import 'package:flutter/painting.dart' show ResizeImage;
import 'package:flutter/widgets.dart' show ImageProvider;

import 'image_size_hint_io.dart'
    if (dart.library.html) 'image_size_hint_web.dart'
    as impl;

ImageProvider unwrapProvider(ImageProvider provider) {
  ImageProvider current = provider;
  while (current is ResizeImage) {
    current = current.imageProvider;
  }
  return current;
}

double? tryGetScaleForProvider(ImageProvider provider) {
  return impl.tryGetScaleForProvider(unwrapProvider(provider));
}

Future<Uint8List?> tryLoadHeaderBytesForProvider(
  ImageProvider provider, {
  int maxBytes = 64 * 1024,
}) {
  return impl.tryLoadHeaderBytesForKey(
    unwrapProvider(provider),
    maxBytes: maxBytes,
  );
}
