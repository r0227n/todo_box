import 'package:flutter/material.dart';

class EmojiText extends Text {
  const EmojiText(
    super.data, {
    super.key,
    super.strutStyle,
    super.style = const TextStyle(
      color: Colors.white,
      fontSize: 24.0,
      fontFamily: 'EmojiOne',
    ),
    super.textAlign = TextAlign.center,
    super.textDirection,
    super.locale,
    super.softWrap,
    super.overflow,
    super.textScaleFactor,
    super.maxLines,
    super.semanticsLabel,
    super.textWidthBasis,
    super.textHeightBehavior,
    super.selectionColor,
  });
}
