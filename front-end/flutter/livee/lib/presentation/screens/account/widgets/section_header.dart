import 'package:flutter/material.dart';

/// 마이페이지의 각 섹션 제목을 표시하는 헤더
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? actionWidget;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        if (actionWidget != null) actionWidget!,
      ],
    );
  }
}
