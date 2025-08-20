import 'package:flutter/material.dart';

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
            _buildNavItem(Icons.home_outlined, '홈', true),
            _buildNavItem(Icons.calendar_today_outlined, '캠페인', false),
            _buildNavItem(Icons.bookmark_border_outlined, '라이브러리', false),
            _buildNavItem(Icons.person_outline, '인플루언서', false),
            _buildNavItem(Icons.account_circle_outlined, '로그인', false),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    final activeColor = isActive ? const Color(0xFF6C63FF) : const Color(0xFF9AA3AF);
    final activeTextColor = isActive ? const Color(0xFF1F2937) : const Color(0xFF9AA3AF);

    return Expanded(
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 26, color: activeColor),
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
}
