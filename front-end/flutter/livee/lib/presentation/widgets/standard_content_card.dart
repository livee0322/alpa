import 'package:flutter/material.dart';

/// 표준 디자인의 공통 카드 위젯
class StandardContentCard extends StatelessWidget {
  final Widget child; // 카드 내용
  final VoidCallback? onTap; // 카드 선택 로직
  final EdgeInsetsGeometry? padding; // 패딩
  final EdgeInsetsGeometry? margin; // 마진

  const StandardContentCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
  });

  // 위젯의 UI를 빌드
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: margin ?? const EdgeInsets.only(bottom: 10),
        padding: padding ?? const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.grey.shade300, // 테두리 색상
            width: 1.0, // 테두리 두께
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: child,
      ),
    );
  }
}
