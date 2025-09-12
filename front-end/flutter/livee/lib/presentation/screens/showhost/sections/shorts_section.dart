import 'package:flutter/material.dart';

class ShortsSection extends StatelessWidget {
  const ShortsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.refresh),
              label: const Text('새로고침'),
            )
          ],
        ),
        const SizedBox(height: 8),
        const Text('로그인 시 내 쇼츠가 표시됩니다.'),
      ],
    );
  }
}
