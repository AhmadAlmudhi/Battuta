import 'package:battuta/features/countries/domain/search_normalizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizeForSearch', () {
    test('lowercases and trims Latin text', () {
      expect(normalizeForSearch('  Saudi ARABIA '), 'saudi arabia');
    });

    test('strips Latin accents', () {
      expect(normalizeForSearch('Côte d\'Ivoire'), 'cote d\'ivoire');
      expect(normalizeForSearch('Curaçao'), 'curacao');
      expect(normalizeForSearch('Åland Islands'), 'aland islands');
      expect(normalizeForSearch('São Tomé'), 'sao tome');
    });

    test('unifies Arabic alef variants', () {
      expect(normalizeForSearch('أإآٱ'), 'اااا');
    });

    test('maps taa marbuta to haa and alef maqsura to yaa', () {
      expect(normalizeForSearch('ة'), 'ه');
      expect(normalizeForSearch('ى'), 'ي');
    });

    test('removes Arabic diacritics and tatweel', () {
      expect(normalizeForSearch('السُّعُودِيَّة'), 'السعوديه');
      expect(normalizeForSearch('مـصـر'), 'مصر');
    });

    test('query and stored name normalize to matching forms (AC-EXP-02)', () {
      final stored = normalizeForSearch('السعودية');
      expect(stored.contains(normalizeForSearch('سعو')), isTrue);
    });

    test('collapses inner whitespace', () {
      expect(normalizeForSearch('New   Zealand'), 'new zealand');
    });
  });
}
