import 'package:flutter/material.dart';
import 'package:livee/presentation/providers/auth_provider.dart';
import 'package:livee/presentation/widgets/common_bottom_nav_bar.dart';
import 'package:livee/presentation/widgets/common_header.dart';
import 'package:livee/presentation/widgets/common_top_tab_bar.dart';
import 'package:provider/provider.dart';

/// 앱의 공통 레이아웃(Header, TopTabBar, BottomNavBar)을 제공하는 쉘(Shell) 위젯
class ShellScreen extends StatelessWidget {
  final Widget child; // 내용
  final String location; // 현재 경로 위치

  const ShellScreen({
    super.key,
    required this.child,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 공통 헤더
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return CommonHeader(isLoggedIn: authProvider.isLoggedIn);
            },
          ),
          // 공통 상단 탭바
          CommonTopTabBar(currentPath: location),
          // 내용이 표시될 영역
          Expanded(
            child: child,
          ),
        ],
      ),
      // 공통 하단 네비게이션 바
      bottomNavigationBar: CommonBottomNavBar(currentPath: location),
    );
  }
}
