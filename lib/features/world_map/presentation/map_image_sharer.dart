import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'share_map_image_io.dart'
    if (dart.library.js_interop) 'share_map_image_web.dart'
    as platform;

/// Hands the "Share my map" image to the platform (FR-MAP-42). [origin] is
/// where the share sheet points from on iPad.
typedef MapImageSharer =
    Future<void> Function(
      Uint8List png, {
      required String fileName,
      Rect? origin,
    });

/// On Android and iOS, the system share sheet; on web, a PNG download.
final mapImageSharerProvider = Provider<MapImageSharer>(
  (ref) => platform.shareMapImage,
);
