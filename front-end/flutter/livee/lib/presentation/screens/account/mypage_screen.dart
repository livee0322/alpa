import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livee/presentation/providers/auth_provider.dart';
import 'package:livee/presentation/widgets/common_bottom_nav_bar.dart';
import 'package:livee/presentation/widgets/common_header.dart';
import 'package:livee/presentation/widgets/common_prompt_dialog.dart';
import 'package:livee/presentation/widgets/custom_toast.dart';
import 'package:livee/presentation/screens/account/widgets/profile_card.dart';
import 'package:livee/presentation/screens/account/widgets/section_header.dart';
import 'package:livee/presentation/screens/account/widgets/mypage_menu_item.dart';
import 'package:livee/presentation/screens/account/sections/guest_section.dart';
import 'package:livee/presentation/screens/account/sections/brand_section.dart';
import 'package:livee/presentation/screens/account/sections/showhost_section.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;

class MypageScreen extends StatelessWidget {
  const MypageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

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
                  // 1. 공통 프로필 카드
                  ProfileCard(authProvider: authProvider),
                  const SizedBox(height: 32),

                  // 2. 역할별 섹션 표시
                  _buildRoleSpecificSection(authProvider),
                  const SizedBox(height: 32),

                  // 3. 공통 설정 메뉴 (로그인한 사용자에게만 보임)
                  if (authProvider.isLoggedIn) _buildSettingsSection(context, authProvider)
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CommonBottomNavBar(),
    );
  }

  /// 사용자의 역할에 따라 적절한 섹션 위젯을 반환하는 헬퍼 메소드
  Widget _buildRoleSpecificSection(AuthProvider authProvider) {
    if (!authProvider.isLoggedIn) {
      return const GuestSection();
    }
    switch (authProvider.role) {
      case 'brand':
        return const BrandSection();
      case 'showhost':
        return const ShowhostSection();
      default:
        // 해당하는 역할이 없을 경우 아무것도 표시하지 않음
        return const SizedBox.shrink();
    }
  }

  /// 로그인한 모든 사용자에게 공통으로 표시될 설정 메뉴 섹션
  Widget _buildSettingsSection(BuildContext context, AuthProvider authProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: '설정'),
        const SizedBox(height: 10),
        MyPageMenuItem(
          icon: CupertinoIcons.settings,
          title: '알림 설정',
          subtitle: '푸시/이메일 수신 관리',
          onTap: () => showCustomToast(context, '준비중인 기능입니다.', type: ToastType.info),
        ),
        MyPageMenuItem(
          icon: CupertinoIcons.square_arrow_left,
          title: '로그아웃',
          subtitle: '계정 전환 및 로그인',
          onTap: () async => _handleLogout(context, authProvider),
        ),
      ],
    );
  }

  /// 로그아웃 로직을 처리하는 헬퍼 함수
  Future<void> _handleLogout(BuildContext context, AuthProvider authProvider) async {
    final confirm = await showCommonPromptDialog(
      context: context,
      title: '로그아웃',
      content: '정말로 로그아웃 하시겠습니까?',
      confirmText: '로그아웃',
    );
    if (confirm == true) {
      await authProvider.logout();
      if (context.mounted) {
        showCustomToast(context, '로그아웃 되었습니다.');
        html.window.history.go(-1);
      }
    }
  }
}
