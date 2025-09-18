import 'package:flutter/material.dart';
import 'package:livee/presentation/widgets/common_bottom_nav_bar.dart';

/// 앱의 최상위 레이아웃, 하단 네비게이션 바를 항상 표시
class RootShellScreen extends StatelessWidget {
  final Widget child; // 실제 페이지 내용이 들어올 자리
  final String location; // 현재 경로

  const RootShellScreen({
    super.key,
    required this.child,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 내용은 child 위젯
      body: child,
      // 하단 네비게이션 바는 항상 표시
      bottomNavigationBar: CommonBottomNavBar(currentPath: location),
    );
  }
}
