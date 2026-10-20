// Source of web/drift_worker.js, the web worker that runs the local database
// on web (PRD section 11.4). It is compiled from the drift and sqlite3
// versions in pubspec.lock, so the worker always matches the app.
//
// Regenerate after upgrading drift or sqlite3, together with web/sqlite3.wasm
// from the matching sqlite3 release (see CLAUDE.md):
//   dart compile js -O4 --no-source-maps -o web/drift_worker.js tool/drift_worker.dart
import 'package:drift/wasm.dart';

void main() => WasmDatabase.workerMainForOpen();
