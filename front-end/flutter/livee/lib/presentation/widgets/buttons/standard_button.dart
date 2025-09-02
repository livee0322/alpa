import 'package:flutter/material.dart';

// '불러오기', '이미지 선택' 등 특정 섹션 내 간단한 기능을 위한 일반 버튼
class StandardButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? height;

  const StandardButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2))
            : Text(text),
      ),
    );
  }
}