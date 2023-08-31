import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

List<InlineSpan> tagTextSpans(
  String text, {
  TextStyle? defaultStyle,
  Map<String, TextStyle?>? tagStyle,
  Map<String, Gradient>? tagShader,
  Map<String, void Function()>? tagClickEvents,
}) {
  int lastTagsStyleEndIndex = 0;
  final List<InlineSpan> inlineSpans = [];
  final RegExp regExp = RegExp(r'<(\w+)[^>]*>(.*?)</\1>');
  final Iterable<Match> matches = regExp.allMatches(text);
  for (final match in matches) {
    final tag = match.group(1);
    final content = match.group(2);
    if (tag != null && content != null) {
      final clickEvent = tagClickEvents?[tag];
      inlineSpans.add(TextSpan(text: text.substring(lastTagsStyleEndIndex, match.start), style: defaultStyle));

      final InlineSpan span;
      final gradient = tagShader?[tag];
      if (gradient != null) {
        final style = tagStyle?[tag] ?? defaultStyle;
        final text = Text(content, style: style);
        span = WidgetSpan(
            child: ShaderMask(
              shaderCallback: (rect) => gradient.createShader(rect),
              child: (clickEvent != null) ? GestureDetector(onTap: clickEvent, child: text) : text,
            ),
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            style: style);
      } else {
        span = TextSpan(
            text: content,
            style: tagStyle?[tag] ?? defaultStyle,
            recognizer: clickEvent != null ? (TapGestureRecognizer()..onTap = clickEvent) : null);
      }

      inlineSpans.add(span);
      lastTagsStyleEndIndex = match.end;
    }
  }
  if (lastTagsStyleEndIndex != text.length) {
    inlineSpans.add(TextSpan(text: text.substring(lastTagsStyleEndIndex, text.length), style: defaultStyle));
  }

  return inlineSpans;
}
