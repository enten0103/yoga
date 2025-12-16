import 'dart:io' as io;
import 'dart:typed_data';

import 'package:flutter/painting.dart' show FileImage, NetworkImage;
import 'package:flutter/widgets.dart' show ImageProvider;

double? tryGetScaleForProvider(ImageProvider provider) {
  if (provider is NetworkImage) return provider.scale;
  if (provider is FileImage) return provider.scale;
  return null;
}

Future<Uint8List?> tryLoadHeaderBytesForKey(
  ImageProvider provider, {
  int maxBytes = 64 * 1024,
}) async {
  if (provider is FileImage) {
    return _readFileHeader(provider.file, maxBytes: maxBytes);
  }
  if (provider is NetworkImage) {
    return _readNetworkHeader(
      provider.url,
      headers: provider.headers,
      maxBytes: maxBytes,
    );
  }
  return null;
}

Future<Uint8List?> _readFileHeader(
  io.File file, {
  required int maxBytes,
}) async {
  final io.RandomAccessFile raf = await file.open(mode: io.FileMode.read);
  try {
    final int len = await raf.length();
    final int toRead = len < maxBytes ? len : maxBytes;
    if (toRead <= 0) return null;
    final Uint8List bytes = await raf.read(toRead);
    return bytes;
  } finally {
    await raf.close();
  }
}

Future<Uint8List?> _readNetworkHeader(
  String url, {
  required Map<String, String>? headers,
  required int maxBytes,
}) async {
  final Uri uri = Uri.parse(url);
  if (uri.scheme != 'http' && uri.scheme != 'https') return null;

  final io.HttpClient client = io.HttpClient();
  try {
    final io.HttpClientRequest req = await client.getUrl(uri);

    // Best-effort range request; servers may ignore it.
    req.headers.set('Range', 'bytes=0-${maxBytes - 1}');
    headers?.forEach((String k, String v) {
      req.headers.set(k, v);
    });

    final io.HttpClientResponse resp = await req.close();

    final BytesBuilder builder = BytesBuilder(copy: false);
    int total = 0;

    await for (final List<int> chunk in resp) {
      if (total >= maxBytes) break;
      final int remaining = maxBytes - total;
      if (chunk.length <= remaining) {
        builder.add(chunk);
        total += chunk.length;
      } else {
        builder.add(chunk.sublist(0, remaining));
        total += remaining;
        break;
      }
    }

    if (total <= 0) return null;
    return builder.takeBytes();
  } catch (_) {
    return null;
  } finally {
    client.close(force: true);
  }
}
