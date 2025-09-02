import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CommonBottomNavBar extends StatelessWidget {
  const CommonBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            _buildNavItem(context, CupertinoIcons.home, '홈', '/'),
            _buildNavItem(context, CupertinoIcons.archivebox, '모집캠페인', '/recruits'),
            _buildNavItem(context, CupertinoIcons.bookmark, '라이브러리', '/library'),
            _buildNavItem(context, CupertinoIcons.person, '인플루언서', '/showhosts'),
            _buildNavItem(context, CupertinoIcons.settings, '마이페이지', '/mypage'),
          ],
        ),
      ),
    );
  }
}

Widget _buildNavItem(BuildContext context, IconData icon, String label, String path) {
  final GoRouter router = GoRouter.of(context);
  final isActive = router.routerDelegate.currentConfiguration.uri.toString() == path;
  final activeColor = isActive ? const Color(0xFF6C63FF) : const Color(0xFF9AA3AF);
  final activeTextColor = isActive ? const Color(0xFF1F2937) : const Color(0xFF9AA3AF);

  return Expanded(
    child: InkWell(
      onTap: () {
        router.go(path);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: activeColor),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.w700,
                color: activeTextColor,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
