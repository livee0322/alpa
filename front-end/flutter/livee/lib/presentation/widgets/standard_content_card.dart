import 'package:flutter/material.dart';

/// 메인 화면 섹션들에서 사용할 표준 디자인의 공통 카드 위젯
class StandardContentCard extends StatelessWidget {
  /// 카드 내부에 표시될 내용
  final Widget child;

  /// 카드를 탭했을 때 실행될 함수
  final VoidCallback? onTap;

  const StandardContentCard({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: const Color(0xFFF1F3F5),
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.06),
              offset: Offset(0, 2),
              blurRadius: 8,
            )
          ],
        ),
        child: child,
      ),
    );
  }
}
