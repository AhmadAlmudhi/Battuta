import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'features/settings/presentation/settings_controller.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  final (prefs, _) = await (
    SharedPreferences.getInstance(),
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
  ).wait;
  if (_useEmulators) await _connectToEmulators();
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const BattutaApp(),
    ),
  );
}

/// Builds made with `--dart-define=USE_FIREBASE_EMULATORS=true` talk to the
/// local Firebase emulators (`firebase emulators:start`), never to the real
/// project.
const _useEmulators = bool.fromEnvironment('USE_FIREBASE_EMULATORS');

Future<void> _connectToEmulators() async {
  await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
}
