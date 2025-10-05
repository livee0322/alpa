import 'package:flutter/material.dart';

class CommonBanner extends StatelessWidget {
  const CommonBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF6C63FF),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: const Text(
        '현재 클로즈 베타 테스트 중입니다. 피드백을 환영합니다! 🚀',
        style: TextStyle(
          color: Colors.white,
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
