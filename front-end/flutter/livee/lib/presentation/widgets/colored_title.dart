import 'package:flutter/material.dart';

class ColoredTitle extends StatelessWidget {
  final String blackText;
  final String purpleText;
  final bool purpleFirst;

  const ColoredTitle({
    super.key,
    required this.blackText,
    required this.purpleText,
    this.purpleFirst = false, // 기본값은 false (검정 -> 보라 순서)
  });

  @override
  Widget build(BuildContext context) {
    final blackSpan = TextSpan(text: blackText);
    final purpleSpan = TextSpan(
      text: purpleText,
      style: const TextStyle(
        fontFamily: 'SUIT',
        fontSize: 16,
        color: Color(0xFF8B5CF6),
        fontWeight: FontWeight.w900,
      ),
    );

    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontFamily: 'SUIT',
          fontSize: 16,
          fontWeight: FontWeight.w900,
          color: Colors.black,
        ),
        // [수정] purpleFirst 값에 따라 TextSpan의 순서를 결정
        children: purpleFirst ? [purpleSpan, blackSpan] : [blackSpan, purpleSpan],
      ),
    );
  }
}
