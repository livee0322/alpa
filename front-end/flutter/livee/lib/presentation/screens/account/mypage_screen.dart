import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/presentation/providers/auth_provider.dart';
import 'package:livee/presentation/widgets/buttons/primary_action_button.dart';
import 'package:livee/presentation/widgets/common_bottom_nav_bar.dart';
import 'package:livee/presentation/widgets/common_header.dart';
import 'package:livee/presentation/widgets/custom_toast.dart';
import 'package:provider/provider.dart';

class MypageScreen extends StatelessWidget {
  const MypageScreen({super.key});

  // 접근 제한 팝업을 표시
  Future<void> _showAccessDeniedDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('접근 불가'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('“쇼호스트” 유형 가입자만 사용 가능한 기능입니다.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('닫기'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('내 정보 변경'),
              onPressed: () {
                Navigator.of(context).pop();
                GoRouter.of(context).go('/account-edit');
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final role = authProvider.role;
    final isLoggedIn = authProvider.isLoggedIn;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            CommonHeader(isLoggedIn: authProvider.isLoggedIn),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. 프로필 카드 섹션
                  _buildProfileCard(context, authProvider),
                  const SizedBox(height: 24),

                  // 2. 브랜드 전용 메뉴 (브랜드 역할일 때만 보임)
                  if (role == 'brand') ...[
                    _buildSectionHeader(
                      title: '내가 등록한 공고',
                      actionWidget: PrimaryActionButton(
                        text: '공고 등록하기',
                        onPressed: () => GoRouter.of(context).go('/campaign-form'),
                        isFullWidth: false, // 전체 너비가 아닌 작은 버튼으로 설정
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildMyPageItem(
                      icon: CupertinoIcons.list_bullet,
                      title: '등록한 공고 목록',
                      subtitle: '진행중/마감 구분',
                      onTap: () => GoRouter.of(context).go('/campaigns'),
                    ),
                    _buildMyPageItem(
                      icon: CupertinoIcons.person_2,
                      title: '지원자 현황',
                      subtitle: '캠페인별 지원자/상태',
                      onTap: () => showCustomToast(context, '준비중인 기능입니다.', type: ToastType.info),
                    ),
                    _buildMyPageItem(
                      icon: CupertinoIcons.paperplane,
                      title: '제안하기',
                      subtitle: '쇼호스트에게 직접 제안',
                      onTap: () => showCustomToast(context, '준비중인 기능입니다.', type: ToastType.info),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // 3. 쇼호스트 전용 메뉴 (쇼호스트 역할일 때만 보임)
                  if (role == 'showhost') ...[
                    _buildSectionHeader(title: '쇼호스트 메뉴'),
                    const SizedBox(height: 10),
                    _buildMyPageItem(
                      icon: CupertinoIcons.person_badge_plus,
                      title: '내 포트폴리오',
                      subtitle: '프로필/경력/미디어 관리',
                      onTap: () => GoRouter.of(context).go('/portfolio-edit'),
                    ),
                    _buildMyPageItem(
                      icon: CupertinoIcons.doc_text,
                      title: '내 지원 내역',
                      subtitle: '대기/합격/거절/정산',
                      onTap: () => GoRouter.of(context).go('/my-applications'),
                    ),
                    _buildMyPageItem(
                      icon: CupertinoIcons.envelope_open,
                      title: '받은 제안',
                      subtitle: '브랜드가 보낸 제안',
                      onTap: () => GoRouter.of(context).go('/received-offers'),
                    ),
                    _buildMyPageItem(
                      icon: CupertinoIcons.heart,
                      title: '찜한 공고',
                      subtitle: '북마크한 공고 모아보기',
                      onTap: () => GoRouter.of(context).go('/bookmarked-recruits'),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // 4. 설정 메뉴 (모두에게 보임)
                  _buildSectionHeader(title: '설정'),
                  const SizedBox(height: 10),
                  _buildMyPageItem(
                    icon: CupertinoIcons.settings,
                    title: '알림 설정',
                    subtitle: '푸시/이메일 수신 관리',
                    onTap: () => showCustomToast(context, '준비중인 기능입니다.', type: ToastType.info),
                  ),
                  _buildMyPageItem(
                    icon: isLoggedIn ? CupertinoIcons.square_arrow_left : CupertinoIcons.square_arrow_right,
                    title: isLoggedIn ? '로그아웃' : '로그인',
                    subtitle: '계정 전환 및 로그인',
                    onTap: () {
                      if (isLoggedIn) {
                        authProvider.logout();
                      }
                      GoRouter.of(context).go('/login');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CommonBottomNavBar(),
    );
  }

  // 상단 프로필 카드 위젯
  Widget _buildProfileCard(BuildContext context, AuthProvider authProvider) {
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
              // TODO: 사용자 프로필 이미지 연동
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

  // 섹션 헤더 위젯 (예: "내가 등록한 공고" + 버튼)
  Widget _buildSectionHeader({required String title, Widget? actionWidget}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        if (actionWidget != null) actionWidget,
      ],
    );
  }

  // 아이콘과 새로운 스타일이 적용된 메뉴 아이템 위젯
  Widget _buildMyPageItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: Colors.grey[600]),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
