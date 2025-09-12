import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/presentation/screens/account/widgets/mypage_menu_item.dart';
import 'package:livee/presentation/screens/account/widgets/section_header.dart';
import 'package:livee/presentation/widgets/buttons/primary_action_button.dart';
import 'package:livee/presentation/widgets/custom_toast.dart';

/// 브랜드 역할의 사용자를 위한 마이페이지 메뉴 섹션
class BrandSection extends StatelessWidget {
  const BrandSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: '내가 등록한 공고',
          actionWidget: PrimaryActionButton(
            text: '공고 등록하기',
            onPressed: () => GoRouter.of(context).go('/campaign-form'),
            isFullWidth: false,
          ),
        ),
        const SizedBox(height: 10),
        MyPageMenuItem(
          icon: CupertinoIcons.list_bullet,
          title: '등록한 공고 목록',
          subtitle: '진행중/마감 구분',
          onTap: () => GoRouter.of(context).go('/campaigns'),
        ),
        MyPageMenuItem(
          icon: CupertinoIcons.person_2,
          title: '지원자 현황',
          subtitle: '캠페인별 지원자/상태',
          onTap: () => showCustomToast(context, '준비중인 기능입니다.', type: ToastType.info),
        ),
        MyPageMenuItem(
          icon: CupertinoIcons.paperplane,
          title: '제안하기',
          subtitle: '쇼호스트에게 직접 제안',
          onTap: () => showCustomToast(context, '준비중인 기능입니다.', type: ToastType.info),
        ),
      ],
    );
  }
}
