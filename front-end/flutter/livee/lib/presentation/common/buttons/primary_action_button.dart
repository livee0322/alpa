import 'package:flutter/material.dart';
import 'package:livee/presentation/styles/app_colors.dart';

// 앱의 주요 액션(로그인, 저장 등)을 위한 공통 버튼 위젯
class PrimaryActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;

  const PrimaryActionButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ElevatedButton.styleFrom(
      minimumSize: isFullWidth ? const Size(double.infinity, 54) : null,
      padding: isFullWidth ? null : const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isFullWidth ? 14 : 8), // 작은 버튼일 때 더 작은 radius
      ),
      disabledBackgroundColor: AppColors.disabled,
    );

    final textStyle = TextStyle(
      fontSize: isFullWidth ? 18 : 14,
      fontWeight: FontWeight.bold,
    );

    final loadingIndicator = const SizedBox(
      width: 24,
      height: 24,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        color: Colors.white,
      ),
    );

    // [수정] icon 파라미터의 유무에 따라 다른 버튼 위젯을 반환합니다.
    if (icon != null) {
      // 아이콘이 있을 경우: ElevatedButton.icon 사용
      return ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        icon: isLoading ? const SizedBox.shrink() : Icon(icon, size: isFullWidth ? 20 : 16),
        label: isLoading ? loadingIndicator : Text(text, style: textStyle),
      );
    } else {
      // 아이콘이 없을 경우: 기존 ElevatedButton 사용
      return ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        child: isLoading ? loadingIndicator : Text(text, style: textStyle),
      );
    }
  }
}
