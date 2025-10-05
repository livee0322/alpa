import 'package:flutter/material.dart';

// 목록 필터링 등에 사용되는 칩(Chip) 형태의 보조 버튼 위젯
class SecondaryChipButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onPressed;

  const SecondaryChipButton({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: isSelected ? const Color(0xFF6C63FF) : Colors.white,
        foregroundColor: isSelected ? Colors.white : Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: BorderSide(
            color: isSelected ? const Color(0xFF6C63FF) : Colors.grey[300]!,
          ),
        ),
      ),
      child: Text(text),
    );
  }
}
