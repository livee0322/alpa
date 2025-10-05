import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/presentation/providers/auth_provider.dart';
import 'package:livee/presentation/styles/app_colors.dart';
import 'package:livee/presentation/common/common_prompt_dialog.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';

class CommonBottomNavBar extends StatelessWidget {
  final String? currentPath; // 현재 경로
  const CommonBottomNavBar({
    super.key,
    this.currentPath,
  });

  @override
  Widget build(BuildContext context) {
    // 위젯이 전달받은 currentPath를 사용하고, 없으면 라우터에서 직접 가져오기
    final effectivePath = currentPath ?? GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString();
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
                    _buildNavItem(
                      context,
                      authProvider,
                      // CupertinoIcons.home,
                      RemixIcons.home_line,
                      '홈',
                      '/',
                      effectivePath,
                    ),
                    _buildNavItem(
                      context,
                      authProvider,
                      RemixIcons.archive_drawer_line,
                      '모집공고',
                      '/campaigns',
                      effectivePath,
                    ),
                    _buildNavItem(
                      context,
                      authProvider,
                      RemixIcons.user_star_line,
                      '모델',
                      '/models',
                      effectivePath,
                    ),
                    _buildNavItem(
                      context,
                      authProvider,
                      RemixIcons.user_3_line,
                      '포트폴리오',
                      '/portfolios',
                      effectivePath,
                    ),
                    _buildNavItem(
                      context,
                      authProvider,
                      RemixIcons.user_settings_line,
                      '마이페이지',
                      '/mypage',
                      effectivePath,
                    ),
                  ],
                ),
              ),
            ));
  }
}

Widget _buildNavItem(
    BuildContext context, AuthProvider authProvider, IconData icon, String label, String itemPath, String currentPath) {
  final bool isActive = currentPath == itemPath;

  const activeColor = AppColors.primary;
  const inactiveColor = AppColors.disabled;

  return Expanded(
    child: InkWell(
      onTap: () async {
        // 현재 경로와 이동할 경로가 같으면 아무것도 하지 않음 (불필요한 이동 방지)
        if (currentPath == itemPath) return;

        final isLoggedIn = authProvider.isLoggedIn;
        final authRequiredRoutes = ['/mypage']; // 라이브러리 제거
        if (authRequiredRoutes.contains(itemPath) && !isLoggedIn) {
          final result = await showCommonPromptDialog(
            context: context,
            title: '로그인이 필요합니다',
            content: '회원 전용 서비스입니다.\n로그인 하시겠습니까?',
            confirmText: '로그인',
          );
          if (result == true && context.mounted) {
            GoRouter.of(context).go('/login');
          }
        } else {
          GoRouter.of(context).replace(itemPath);
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: isActive ? activeColor : inactiveColor),
            const SizedBox(height: 8),
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
