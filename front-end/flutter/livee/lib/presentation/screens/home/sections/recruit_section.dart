// [파일경로/파일명] lib/presentation/screens/home/sections/recruit_section.dart 파일이 수정되었습니다.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/domain/models/campaign.dart';
import 'package:livee/presentation/providers/auth_provider.dart';
import 'package:livee/presentation/screens/home/vm/home_view_model.dart';
import 'package:livee/presentation/screens/main/widgets/apply_bottom_sheet.dart';
import 'package:livee/presentation/styles/app_colors.dart';
import 'package:livee/presentation/utils/utility.dart';
import 'package:livee/presentation/widgets/common_prompt_dialog.dart';
import 'package:livee/presentation/widgets/custom_toast.dart';
import 'package:livee/presentation/widgets/standard_content_card.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';

// 브랜드 PICK 섹션
class RecruitSection extends StatelessWidget {
  final List<Campaign> recruits;

  const RecruitSection({
    super.key,
    required this.recruits,
  });

  // 위젯의 UI 빌드
  @override
  Widget build(BuildContext context) {
    if (recruits.isEmpty) {
      return const Center(child: Text('등록된 공고가 없습니다'));
    }

    // 카드 리스트 UI
    return SizedBox(
      height: 320,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: recruits.length,
        itemBuilder: (context, index) {
          final campaign = recruits[index];
          return _buildRecruitCard(context, campaign);
        },
        separatorBuilder: (context, index) => const SizedBox(width: 12),
      ),
    );
  }

  // 개별 공고 카드 위젯을 생성
  Widget _buildRecruitCard(BuildContext context, Campaign campaign) {
    final authProvider = context.watch<AuthProvider>();
    final mainViewModel = context.read<HomeViewModel>();
    final dDay = Utility.calculateDday(campaign.closeAt?.toIso8601String());
    final isClosed = dDay == '마감';

    String feeText = '협의';
    if (campaign.fee != null && campaign.fee! > 0) {
      feeText = '${(campaign.fee! / 10000).round()}만원';
    } else if (campaign.feeNegotiable == true) {
      feeText = '협의';
    }

    // 카드의 폭을 지정하고 공통 카드 컴포넌트를 사용
    return SizedBox(
      width: 240,
      child: StandardContentCard(
        padding: EdgeInsets.zero,
        margin: EdgeInsets.zero,
        onTap: () => context.push('/campaign/${campaign.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 공고 썸네일 이미지
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  campaign.coverImageUrl ??
                      'https://picsum.photos/seed/recruit${campaign.id}',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.disabled,
                    child: Icon(
                      Icons.broken_image,
                      color: AppColors.textGrey,
                    ),
                  ),
                ),
              ),
            ),
            // 공고 정보 (텍스트, 버튼)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          campaign.brandName ?? '브랜드명',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textGrey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Visibility(
                          visible: !isClosed,
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          child: Chip(
                            label: const Text('모집중'),
                            labelStyle: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            backgroundColor: AppColors.primary.withAlpha(26),
                            side: BorderSide.none,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: const VisualDensity(
                                horizontal: 0, vertical: -4),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // 제목
                    Text(
                      campaign.title ?? '공고 제목',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const Spacer(),

                    // 출연료
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        feeText,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textBlack,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // 지원하기 버튼
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(
                          RemixIcons.send_plane_line,
                          size: 18,
                        ),
                        label: Text(
                          authProvider.recruitButtonText,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        onPressed: () async {
                          if (!authProvider.isLoggedIn) {
                            final confirm = await showCommonPromptDialog(
                              context: context,
                              title: '로그인이 필요합니다',
                              content:
                                  '공고에 지원하려면 로그인이 필요해요.\n로그인 페이지로 이동하시겠습니까?',
                              confirmText: '로그인',
                            );
                            if (confirm == true && context.mounted) {
                              context.go('/login');
                            }
                            return;
                          }
                          switch (authProvider.role) {
                            case 'showhost':
                              if (campaign.isApplied == true) {
                                showCustomToast(context, '이미 지원한 공고입니다.',
                                    type: ToastType.info);
                              } else {
                                final result = await showApplyBottomSheet(
                                    context, campaign);
                                if (result == true) mainViewModel.loadData();
                              }
                              break;
                            case 'brand':
                              context.go('/campaign/${campaign.id}/applicants');
                              break;
                            default:
                              final result =
                                  await showApplyBottomSheet(context, campaign);
                              if (result == true) mainViewModel.loadData();
                              break;
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonDark,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
