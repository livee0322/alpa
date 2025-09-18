import 'package:flutter/material.dart';
import 'package:livee/presentation/styles/app_colors.dart';

/// 표준 디자인의 공통 카드 위젯
class StandardContentCard extends StatelessWidget {
  final Widget child; // 카드 내용
  final VoidCallback? onTap; // 카드 선택 로직
  final EdgeInsetsGeometry? padding; // 패딩
  final EdgeInsetsGeometry? margin; // 마진
  final BorderRadiusGeometry? borderRadius; // 라운드

  const StandardContentCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.borderRadius,
  });

  // 위젯의 UI를 빌드
  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(14);
    return InkWell(
      onTap: onTap,
      borderRadius: effectiveBorderRadius.resolve(Directionality.of(context)),
      child: Container(
        margin: margin ?? const EdgeInsets.only(bottom: 10),
        padding: padding ?? const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: AppColors.border,
            width: 1.0, // 테두리 두께
          ),
          borderRadius: effectiveBorderRadius.resolve(Directionality.of(context)),
        ),
        child: child,
      ),
    );
  }
}
