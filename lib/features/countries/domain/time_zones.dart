/// A time zone's offset from UTC in minutes, read from names such as
/// UTC+05:30 or UTC-03:00. Plain UTC, or a name in another form, is 0.
int utcOffsetMinutes(String zone) {
  final match = RegExp(r'^UTC([+\-−])(\d{1,2}):(\d{2})$').firstMatch(zone);
  if (match == null) return 0;
  final minutes = int.parse(match[2]!) * 60 + int.parse(match[3]!);
  return match[1] == '+' ? minutes : -minutes;
}

/// [zones] from the farthest west to the farthest east.
List<String> byUtcOffset(Iterable<String> zones) =>
    [...zones]
      ..sort((a, b) => utcOffsetMinutes(a).compareTo(utcOffsetMinutes(b)));
