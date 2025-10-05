import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/presentation/screens/account/widgets/mypage_menu_item.dart';
import 'package:livee/presentation/screens/account/widgets/section_header.dart';
import 'package:livee/presentation/common/buttons/primary_action_button.dart';

/// 쇼호스트 역할의 사용자를 위한 마이페이지 메뉴 섹션
class ShowhostSection extends StatelessWidget {
  const ShowhostSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: '쇼호스트 메뉴',
          actionWidget: PrimaryActionButton(
            text: '+ 등록',
            onPressed: () => context.go('/portfolio-edit'),
            isFullWidth: false,
          ),
        ),
        const SizedBox(height: 10),
        MyPageMenuItem(
          icon: CupertinoIcons.person_badge_plus,
          title: '내 포트폴리오',
          subtitle: '프로필/경력/미디어 관리',
          onTap: () => context.go('/my-portfolios'),
        ),
        MyPageMenuItem(
          icon: CupertinoIcons.doc_text,
          title: '내 지원 내역',
          subtitle: '대기/합격/거절/정산',
          onTap: () => context.go('/my-applications'),
        ),
        MyPageMenuItem(
          icon: CupertinoIcons.envelope_open,
          title: '받은 제안',
          subtitle: '브랜드가 보낸 제안',
          onTap: () => context.go('/received-offers'),
        ),
        MyPageMenuItem(
          icon: CupertinoIcons.heart,
          title: '찜한 공고',
          subtitle: '북마크한 공고 모아보기',
          onTap: () => context.go('/bookmarked-recruits'),
        ),
      ],
    );
  }
}
