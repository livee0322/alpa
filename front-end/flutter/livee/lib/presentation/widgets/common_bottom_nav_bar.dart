import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/presentation/providers/auth_provider.dart';
import 'package:livee/presentation/widgets/login_prompt_dialog.dart';
import 'package:provider/provider.dart';

class CommonBottomNavBar extends StatelessWidget {
  const CommonBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
        builder: (context, authProvider, child) => Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFECEFF1),
                    width: 1.0,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.06),
                    offset: Offset(0, -8),
                    blurRadius: 22,
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(context, authProvider, CupertinoIcons.home, '홈', '/'),
                    _buildNavItem(context, authProvider, CupertinoIcons.archivebox, '모집공고', '/recruits'),
                    _buildNavItem(context, authProvider, CupertinoIcons.bookmark, '라이브러리', '/library'),
                    _buildNavItem(context, authProvider, CupertinoIcons.person, '인플루언서', '/showhosts'),
                    _buildNavItem(context, authProvider, CupertinoIcons.settings, '마이페이지', '/mypage'),
                  ],
                ),
              ),
            ));
  }
}

Widget _buildNavItem(BuildContext context, AuthProvider authProvider, IconData icon, String label, String path) {
  final GoRouter router = GoRouter.of(context);
  final currentPath = router.routerDelegate.currentConfiguration.uri.toString();
  // 경로가 정확히 일치하는지 확인하는 로직을 강화
  final isActive = currentPath == path;

  // 활성화 색상을 이미지와 유사한 파란색 계열로 변경
  const activeColor = Color(0xFF007AFF); // iOS System Blue와 유사한 색상
  const inactiveColor = Color(0xFF9AA3AF); // 비활성화 색상은 유지

  return Expanded(
    child: InkWell(
      // onTap 로직에 접근 제어 기능을 추가
      onTap: () {
        final isLoggedIn = authProvider.isLoggedIn;

        // 로그인이 필요한 페이지 목록
        final authRequiredRoutes = ['/mypage', '/library']; // 예시: 마이페이지, 라이브러리

        if (authRequiredRoutes.contains(path) && !isLoggedIn) {
          showLoginPromptDialog(context);
        } else {
          router.go(path);
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 26, color: isActive ? activeColor : inactiveColor),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.w700,
                color: isActive ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
