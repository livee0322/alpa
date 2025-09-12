import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/presentation/providers/auth_provider.dart';

/// 마이페이지 상단에 표시될 프로필 정보 카드
class ProfileCard extends StatelessWidget {
  final AuthProvider authProvider;

  const ProfileCard({
    super.key,
    required this.authProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey[200],
              child: const Icon(CupertinoIcons.person_fill, color: Colors.grey),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    authProvider.user?.name ?? '로그인 필요',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    authProvider.role ?? '비회원',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                if (authProvider.isLoggedIn) {
                  GoRouter.of(context).go('/account-edit');
                } else {
                  GoRouter.of(context).go('/login');
                }
              },
              child: Text(authProvider.isLoggedIn ? '프로필 수정' : '로그인'),
            )
          ],
        ),
      ),
    );
  }
}
