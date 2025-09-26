import 'package:flutter/material.dart';
import 'package:livee/presentation/styles/app_colors.dart';

/// 앱 전역에서 사용될 공통 플로팅 액션 버튼
class CommonFloatingActionButton extends StatelessWidget {
  /// 버튼을 눌렀을 때 실행될 콜백 함수
  final VoidCallback? onPressed;

  /// 버튼 내부에 표시될 아이콘 (기본값: Icons.add)
  final IconData icon;

  const CommonFloatingActionButton({
    super.key,
    required this.onPressed,
    this.icon = Icons.add,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      shape: const CircleBorder(), // 원형 모양을 명시
      child: Icon(icon),
    );
  }
}
