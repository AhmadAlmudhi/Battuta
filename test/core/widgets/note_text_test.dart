import 'package:battuta/core/widgets/note_text.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<Text> noteOn(
    WidgetTester tester,
    String note,
    TextDirection screen,
  ) async {
    await tester.pumpWidget(
      Directionality(textDirection: screen, child: NoteText(note)),
    );
    return tester.widget<Text>(find.text(note));
  }

  testWidgets('an English note on an Arabic screen reads left to right, '
      'lined up with the screen\'s start', (tester) async {
    final text = await noteOn(tester, 'Long walks.', TextDirection.rtl);

    expect(text.textDirection, TextDirection.ltr);
    expect(text.textAlign, TextAlign.right);
  });

  testWidgets('an Arabic note on an English screen reads right to left', (
    tester,
  ) async {
    final text = await noteOn(tester, 'نزهات طويلة.', TextDirection.ltr);

    expect(text.textDirection, TextDirection.rtl);
    expect(text.textAlign, TextAlign.left);
  });
}
