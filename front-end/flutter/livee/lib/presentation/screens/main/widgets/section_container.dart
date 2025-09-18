import 'package:flutter/material.dart';

/// 메인 화면의 각 섹션을 구성하는 공통 컨테이너 위젯
class SectionContainer extends StatelessWidget {
  final Widget title; // 제목 위젯
  final VoidCallback? onMorePressed; // 더보기 로직
  final Widget child; // 내용 위젯

  const SectionContainer({
    super.key,
    required this.title,
    this.onMorePressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          children: [
            // 1. 섹션 헤더 (제목 + 더보기 버튼)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                title,
                if (onMorePressed != null)
                  InkWell(
                    onTap: onMorePressed,
                    child: const Text(
                      '더보기',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            // 2. 섹션 내용
            child,
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
