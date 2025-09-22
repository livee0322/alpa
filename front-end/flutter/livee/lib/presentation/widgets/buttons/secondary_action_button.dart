import 'package:flutter/material.dart';
import 'package:livee/presentation/styles/app_colors.dart';

/// 앱의 보조적인 액션(예: 문의, 취소)을 위한 공통 외곽선 버튼
class SecondaryActionButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool isFullWidth;

  const SecondaryActionButton({
    super.key,
    required this.text,
    this.icon,
    required this.onPressed,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final style = OutlinedButton.styleFrom(
      minimumSize: isFullWidth ? const Size(double.infinity, 54) : null,
      padding: isFullWidth ? null : const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      foregroundColor: AppColors.textBlack,
      side: const BorderSide(color: AppColors.border),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );

    final textStyle = TextStyle(
      fontSize: isFullWidth ? 18 : 14,
      fontWeight: FontWeight.bold,
    );

    return icon != null
        ? OutlinedButton.icon(
            icon: Icon(icon),
            label: Text(text, style: textStyle),
            onPressed: onPressed,
            style: style,
          )
        : OutlinedButton(
            onPressed: onPressed,
            style: style,
            child: Text(text, style: textStyle),
          );
  }
}
