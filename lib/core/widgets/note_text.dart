import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart' show Bidi;

/// Text the user wrote, such as notes, read in its own direction: English
/// notes on an Arabic screen keep their punctuation in place, and Arabic
/// notes on an English screen too. Either way it lines up with the screen's
/// start edge.
class NoteText extends StatelessWidget {
  const NoteText(this.text, {super.key, this.style, this.maxLines});

  final String text;
  final TextStyle? style;

  /// When set, longer text ends in an ellipsis.
  final int? maxLines;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: style,
    maxLines: maxLines,
    overflow: maxLines == null ? null : TextOverflow.ellipsis,
    textDirection: Bidi.detectRtlDirectionality(text)
        ? TextDirection.rtl
        : TextDirection.ltr,
    textAlign: Directionality.of(context) == TextDirection.rtl
        ? TextAlign.right
        : TextAlign.left,
  );
}
