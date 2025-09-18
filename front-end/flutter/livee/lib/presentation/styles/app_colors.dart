import 'package:flutter/material.dart';

// 색상 팔레트를 정의하는 클래스
class AppColors {
  // 이 클래스는 인스턴스화(객체 생성)할 필요가 없으므로 private 생성자를 만들기
  AppColors._();

  // 기본 색상 (Primary Color)
  static const Color primary = Color(0xFF687CF4);

  // 자주 사용되는 색상
  static const Color background = Color(0xFFF7F8FA);
  static const Color white = Colors.white;
  static const Color black = Colors.black;

  // 텍스트 색상
  static const Color textBlack = Color(0xFF1F2937);
  static const Color textGrey = Color(0xFF6B7280);

  // 버튼 등 어두운 UI 색상
  static const Color buttonDark = Color(0xFF1F2937);

  // 비활성화 또는 보조적인 UI 색상
  static const Color disabled = Color(0xFFE5E7EB);
  static const Color border = Color(0xFFE6EDF3);
  static const Color dividerColor = Color(0xFFF8FBFD);
  static const Color footerColor = Color(0xFFFAFAFA);

  // 기타 색상
  static const Color error = Colors.red;
  static const Color success = Colors.green;
}
