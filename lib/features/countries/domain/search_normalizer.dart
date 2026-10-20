/// Normalizes text for search, applied to both the query and the stored
/// search fields (PRD section 10.4).
///
/// Latin text is lowercased, trimmed, and stripped of accents. Arabic alef
/// variants become ا, ة becomes ه, ى becomes ي, and diacritics and tatweel
/// are removed.
String normalizeForSearch(String input) {
  final buffer = StringBuffer();
  for (final rune in input.toLowerCase().runes) {
    if (_isArabicDiacritic(rune) || rune == _tatweel) continue;
    final char = String.fromCharCode(rune);
    buffer.write(_replacements[char] ?? char);
  }
  return buffer.toString().trim().replaceAll(_whitespace, ' ');
}

const _tatweel = 0x0640;

bool _isArabicDiacritic(int rune) => rune >= 0x064B && rune <= 0x0652;

final _whitespace = RegExp(r'\s+');

final Map<String, String> _replacements = {
  // Arabic
  'أ': 'ا', 'إ': 'ا', 'آ': 'ا', 'ٱ': 'ا',
  'ة': 'ه',
  'ى': 'ي',
  // Latin accents
  for (final c in 'àáâãäåāăą'.split('')) c: 'a',
  for (final c in 'çćĉċč'.split('')) c: 'c',
  for (final c in 'ďđ'.split('')) c: 'd',
  for (final c in 'èéêëēĕėęě'.split('')) c: 'e',
  for (final c in 'ĝğġģ'.split('')) c: 'g',
  for (final c in 'ĥħ'.split('')) c: 'h',
  for (final c in 'ìíîïĩīĭįı'.split('')) c: 'i',
  for (final c in 'ĵ'.split('')) c: 'j',
  for (final c in 'ķ'.split('')) c: 'k',
  for (final c in 'ĺļľŀł'.split('')) c: 'l',
  for (final c in 'ñńņňŉ'.split('')) c: 'n',
  for (final c in 'òóôõöøōŏő'.split('')) c: 'o',
  for (final c in 'ŕŗř'.split('')) c: 'r',
  for (final c in 'śŝşšș'.split('')) c: 's',
  for (final c in 'ţťŧț'.split('')) c: 't',
  for (final c in 'ùúûüũūŭůűų'.split('')) c: 'u',
  for (final c in 'ŵ'.split('')) c: 'w',
  for (final c in 'ýÿŷ'.split('')) c: 'y',
  for (final c in 'źżž'.split('')) c: 'z',
  'æ': 'ae', 'œ': 'oe', 'ß': 'ss', 'þ': 'th', 'ð': 'd',
};
