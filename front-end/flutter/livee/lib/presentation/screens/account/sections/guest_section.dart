import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 비로그인 사용자를 위한 마이페이지 섹션 (로그인 유도)
class GuestSection extends StatelessWidget {
  const GuestSection({super.key});

  @override
  Widget build(BuildContext context) {
    // 기존 mypage_screen.dart에는 비로그인 시 별도 UI가 없었으므로,
    // 이전 리팩토링에서 만들었던 로그인 유도 UI를 재사용합니다.
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text('로그인하고 모든 기능을 이용해보세요', style: TextStyle(color: Colors.black87, fontSize: 16)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => GoRouter.of(context).go('/login'),
            child: const Text('로그인 / 회원가입'),
          )
        ],
      ),
    );
  }
}
