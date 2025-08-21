import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/presentation/providers/auth_provider.dart';
import 'package:livee/presentation/widgets/common_bottom_nav_bar.dart';
import 'package:livee/presentation/widgets/common_header.dart';
import 'package:provider/provider.dart';

class MypageScreen extends StatelessWidget {
  const MypageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final role = authProvider.role;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            CommonHeader(isLoggedIn: authProvider.isLoggedIn),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '내 계정 관리',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildMyPageItem(
                    title: '내 정보 변경',
                    subtitle: '이름, 프로필',
                    onTap: () {
                      // TODO: 내 정보 변경 페이지 라우트 구현
                    },
                  ),
                  _buildMyPageItem(
                    title: '로그아웃',
                    subtitle: '현재 계정에서 로그아웃합니다',
                    onTap: () async {
                      await authProvider.logout();
                      GoRouter.of(context).go('/login');
                    },
                  ),
                  const SizedBox(height: 20),
                  if (role == 'brand' || role == 'admin') ...[
                    const Text(
                      '브랜드',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildMyPageItem(
                      title: '내가 등록한 캠페인',
                      subtitle: '목록 확인 / 수정 / 삭제',
                      onTap: () => GoRouter.of(context).go('/campaigns'),
                    ),
                    _buildMyPageItem(
                      title: '새 캠페인 등록',
                      subtitle: '상품 캠페인 / 쇼호스트 모집',
                      onTap: () => GoRouter.of(context).go('/campaign-form'),
                    ),
                    const SizedBox(height: 20),
                  ],
                  if (role == 'showhost') ...[
                    const Text(
                      '쇼호스트',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildMyPageItem(
                      title: '내 포트폴리오',
                      subtitle: '작성/수정',
                      onTap: () => GoRouter.of(context).go('/portfolio-edit'),
                    ),
                    _buildMyPageItem(
                      title: '내가 찜한 공고',
                      subtitle: '저장한 공고 보기',
                      onTap: () =>
                          GoRouter.of(context).go('/bookmarked-recruits'),
                    ),
                    _buildMyPageItem(
                      title: '받은 제안',
                      subtitle: '브랜드로부터 온 컨택',
                      onTap: () => GoRouter.of(context).go('/received-offers'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CommonBottomNavBar(),
    );
  }

  Widget _buildMyPageItem({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFEEF0F3)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFFC7C9CF),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
