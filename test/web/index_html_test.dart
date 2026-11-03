import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the web page caps the pixel ratio at 2 before Flutter starts '
      '(D-13)', () {
    final html = File('web/index.html').readAsStringSync();
    final cap = html.indexOf(
      "Object.defineProperty(window, 'devicePixelRatio'",
    );
    final bootstrap = html.indexOf('flutter_bootstrap.js');

    expect(cap, isNonNegative, reason: 'the cap script is missing');
    expect(cap, lessThan(bootstrap), reason: 'it must run before Flutter');
    expect(html, contains('var max = 2;'));
  });
}
