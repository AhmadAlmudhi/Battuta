import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';
import 'dart:ui';

import 'package:web/web.dart' as web;

/// Downloads the image as a PNG file (FR-MAP-42).
Future<void> shareMapImage(
  Uint8List png, {
  required String fileName,
  Rect? origin,
}) async {
  final url = web.URL.createObjectURL(
    web.Blob(<JSAny>[png.toJS].toJS, web.BlobPropertyBag(type: 'image/png')),
  );
  final link = web.HTMLAnchorElement()
    ..href = url
    ..download = fileName;
  web.document.body!.append(link);
  link.click();
  link.remove();
  // Revoking the address at once can cancel the download in some browsers.
  Timer(const Duration(minutes: 1), () => web.URL.revokeObjectURL(url));
}
