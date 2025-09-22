import 'package:flutter/material.dart';
import 'package:livee/presentation/styles/app_colors.dart';

// 앱의 주요 액션(로그인, 저장 등)을 위한 공통 버튼 위젯
class PrimaryActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;

  const PrimaryActionButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
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

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: buttonStyle,
      child: isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.white,
              ),
            )
          : Text(text, style: textStyle),
    );
  }
}
