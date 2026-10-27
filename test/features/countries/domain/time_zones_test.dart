import 'package:battuta/features/countries/domain/time_zones.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reads offsets from UTC, including half hours and plain UTC', () {
    expect(utcOffsetMinutes('UTC+05:30'), 330);
    expect(utcOffsetMinutes('UTC-03:00'), -180);
    expect(utcOffsetMinutes('UTC−09:30'), -570);
    expect(utcOffsetMinutes('UTC'), 0);
  });

  test('sorts from west to east, which plain text order gets wrong', () {
    expect(byUtcOffset(['UTC+01:00', 'UTC-10:00', 'UTC', 'UTC-02:00']), [
      'UTC-10:00',
      'UTC-02:00',
      'UTC',
      'UTC+01:00',
    ]);
  });
}
