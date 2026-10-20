import 'package:battuta/features/travels/domain/travel_validation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 10, 20, 12);

  test('visit date is optional and not in the future (PRD 8.6)', () {
    expect(TravelValidation.isVisitDateValid(null, now), isTrue);
    expect(
      TravelValidation.isVisitDateValid(DateTime(2026, 10, 20), now),
      isTrue,
    );
    // Later today is still today.
    expect(
      TravelValidation.isVisitDateValid(DateTime(2026, 10, 20, 23, 59), now),
      isTrue,
    );
    expect(
      TravelValidation.isVisitDateValid(DateTime(2026, 10, 21), now),
      isFalse,
    );
  });

  test('notes are up to 500 characters, counted as people see them', () {
    expect(TravelValidation.isNotesValid('a' * 500), isTrue);
    expect(TravelValidation.isNotesValid('a' * 501), isFalse);
    // Each thumbs-up with a skin tone is 2 code points but 1 character.
    expect(TravelValidation.isNotesValid('👍🏽' * 500), isTrue);
  });

  test('target years run from this year to 20 years ahead', () {
    final years = TravelValidation.targetYears(now);
    expect(years.first, 2026);
    expect(years.last, 2046);
    expect(years, hasLength(21));
  });
}
