import 'dart:typed_data';
import 'dart:ui';

import 'package:share_plus/share_plus.dart';

/// Opens the system share sheet with the image (FR-MAP-42).
Future<void> shareMapImage(
  Uint8List png, {
  required String fileName,
  Rect? origin,
}) async {
  await SharePlus.instance.share(
    ShareParams(
      files: [XFile.fromData(png, mimeType: 'image/png', name: fileName)],
      fileNameOverrides: [fileName],
      sharePositionOrigin: origin,
    ),
  );
}
