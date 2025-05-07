import 'package:flutter/material.dart';

class HighlightedText extends StatelessWidget {
  final String fullText;
  final String matchedText;
  final TextStyle? baseStyle;
  final TextStyle highlightedStyle;

  const HighlightedText({
    required this.fullText,
    required this.matchedText,
    this.baseStyle,
    this.highlightedStyle = const TextStyle(fontWeight: FontWeight.bold),
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!fullText.contains(matchedText)) {
      return Text(fullText, style: baseStyle);
    }

    final textSpans = <TextSpan>[];
    final parts = fullText.split(matchedText);
    
    for (int i = 0; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        textSpans.add(TextSpan(text: parts[i], style: baseStyle));
      }
      if (i != parts.length - 1) {
        textSpans.add(TextSpan(text: matchedText, style: highlightedStyle));
      }
    }

    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style.merge(baseStyle),
        children: textSpans,
      ),
    );
  }
}