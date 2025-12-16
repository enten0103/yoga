import 'dart:typed_data';

import 'package:flutter/painting.dart' show NetworkImage;
import 'package:flutter/widgets.dart' show ImageProvider;

double? tryGetScaleForProvider(ImageProvider provider) {
  if (provider is NetworkImage) return provider.scale;
  return null;
}

Future<Uint8List?> tryLoadHeaderBytesForKey(
  ImageProvider provider, {
  int maxBytes = 64 * 1024,
}) async {
  // Web implementation: intentionally returns null.
  // Network/file byte reads require platform-specific IO.
  return null;
}
