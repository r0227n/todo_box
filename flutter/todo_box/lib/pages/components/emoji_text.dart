import 'package:flutter/material.dart';

class EmojiText extends StatelessWidget {
  const EmojiText(this.data, {super.key});

  final String data;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 24,
      child: FittedBox(
        child: Text(
          data,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'EmojiOne',
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
