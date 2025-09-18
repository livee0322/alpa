import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/presentation/providers/auth_provider.dart';
import 'package:livee/presentation/styles/app_colors.dart';
import 'package:livee/presentation/widgets/common_prompt_dialog.dart';
import 'package:provider/provider.dart';

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
                      CupertinoIcons.home,
                      '홈',
                      '/',
                      effectivePath,
                    ),
                    _buildNavItem(
                      context,
                      authProvider,
                      CupertinoIcons.archivebox,
                      '모집공고',
                      '/recruits',
                      effectivePath,
                    ),
                    _buildNavItem(
                      context,
                      authProvider,
                      CupertinoIcons.settings,
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
        // ... (onTap 로직은 동일)
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
          GoRouter.of(context).go(itemPath);
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
