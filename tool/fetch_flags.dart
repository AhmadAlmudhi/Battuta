// Downloads a 320 px PNG flag for every country in the bundled snapshot into
// assets/flags/{alpha2}.png (PRD section 11.4).
//
// Usage: dart run tool/fetch_flags.dart [--force]
//
// Flags are bundled because the flag CDN sends no CORS headers, which
// Flutter web needs to draw network images. Uses no API quota: the flag CDN
// needs no key. Skips flags already on disk unless --force is passed.
import 'dart:convert';
import 'dart:io';

const _snapshotPath = 'assets/data/countries_snapshot.json';
const _flagsDir = 'assets/flags';
const _flagWidth = 'w320';
const _parallel = 8;

Future<void> main(List<String> args) async {
  final force = args.contains('--force');
  final snapshot =
      jsonDecode(File(_snapshotPath).readAsStringSync())
          as Map<String, Object?>;
  final codes = <String>{
    for (final record in snapshot['objects'] as List<Object?>)
      if (((record as Map<String, Object?>)['codes'] as Map?)?['alpha_2']
          case final String code when code.isNotEmpty)
        code.toLowerCase(),
  }.toList()..sort();

  Directory(_flagsDir).createSync(recursive: true);
  final pending = [
    for (final code in codes)
      if (force || !File('$_flagsDir/$code.png').existsSync()) code,
  ];
  stdout.writeln('${codes.length} flags, ${pending.length} to download');

  final client = HttpClient()..connectionTimeout = const Duration(seconds: 15);
  final failed = <String>[];
  try {
    for (var i = 0; i < pending.length; i += _parallel) {
      final batch = pending.skip(i).take(_parallel);
      await Future.wait(
        batch.map((code) async {
          if (!await _download(client, code)) failed.add(code);
        }),
      );
    }
  } finally {
    client.close();
  }

  if (failed.isNotEmpty) {
    stderr.writeln('Failed: ${failed.join(', ')}');
    exit(1);
  }
  stdout.writeln('Done');
}

Future<bool> _download(HttpClient client, String code) async {
  final uri = Uri.parse(
    'https://flags.restcountries.com/v5/$_flagWidth/$code.png',
  );
  try {
    final response = await (await client.getUrl(uri)).close();
    if (response.statusCode != 200) return false;
    final bytes = await response.fold<List<int>>(
      [],
      (all, chunk) => all..addAll(chunk),
    );
    // PNG signature check, so an error page is never saved as a flag.
    if (bytes.length < 8 || bytes[1] != 0x50 || bytes[2] != 0x4E) return false;
    await File('$_flagsDir/$code.png').writeAsBytes(bytes);
    return true;
  } on IOException {
    return false;
  }
}
