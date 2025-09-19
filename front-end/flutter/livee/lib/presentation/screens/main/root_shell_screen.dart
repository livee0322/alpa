import 'package:flutter/material.dart';
import 'package:livee/presentation/providers/auth_provider.dart';
import 'package:livee/presentation/widgets/common_bottom_nav_bar.dart';
import 'package:livee/presentation/widgets/common_header.dart';
import 'package:provider/provider.dart';

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
    // 헤더를 표시하지 않을 경로 목록을 정의
    const noHeaderRoutes = ['/login', '/signup'];
    final bool showHeader = !noHeaderRoutes.contains(location);

    return Scaffold(
      body: Column(
        children: [
          // [추가] showHeader가 true일 때만 CommonHeader를 표시
          if (showHeader)
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return CommonHeader(isLoggedIn: authProvider.isLoggedIn);
              },
            ),
          // 페이지 내용은 Expanded로 감싸 남은 공간을 모두 채우기
          Expanded(child: child),
        ],
      ),
      // 하단 네비게이션 바는 항상 표시
      bottomNavigationBar: CommonBottomNavBar(currentPath: location),
    );
  }
}
