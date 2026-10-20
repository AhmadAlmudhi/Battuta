import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'features/countries/presentation/country_providers.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: 'Battuta', home: _DatabaseCheckScreen());
  }
}

/// Temporary screen that proves the local database works on every platform.
/// Replaced by the Welcome and Explore screens.
class _DatabaseCheckScreen extends ConsumerWidget {
  const _DatabaseCheckScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countries = ref.watch(countriesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Battuta')),
      body: countries.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Database error: $error')),
        data: (countries) => ListView.builder(
          itemCount: countries.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return ListTile(title: Text('${countries.length} countries'));
            }
            final country = countries[index - 1];
            return ListTile(
              title: Text(country.nameEn),
              subtitle: Text('${country.nameAr ?? '-'} · ${country.region}'),
              trailing: Text(country.code),
            );
          },
        ),
      ),
    );
  }
}
