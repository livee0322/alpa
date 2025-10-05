import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:livee/domain/models/campaign.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/presentation/providers/auth_provider.dart';
import 'package:livee/presentation/providers/recruit_list_provider.dart';
import 'package:livee/presentation/screens/apply/apply_bottom_sheet.dart';
import 'package:livee/presentation/styles/app_colors.dart';
import 'package:livee/presentation/widgets/common_prompt_dialog.dart';
import 'package:livee/presentation/widgets/custom_toast.dart';
import 'package:provider/provider.dart';

/// 모집 공고 목록에서 사용될 카드 위젯
class NewRecruitCard extends StatelessWidget {
  /// 카드에 표시할 캠페인 데이터
  final Campaign campaign;

  const NewRecruitCard({
    super.key,
    required this.campaign,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    // 출연료 텍스트를 계산 (예: 300000 -> "30만원")
    String feeText = '미정';
    if (campaign.fee != null && campaign.fee! > 0) {
      feeText = '${(campaign.fee! / 10000).round()}만원';
    } else if (campaign.feeNegotiable == true) {
      feeText = '협의';
    }

    // DateTime? 타입의 closeAt을 'yyyy-MM-dd' 형식의 문자열로 변환
    final deadline = campaign.closeAt != null ? DateFormat('yyyy-MM-dd').format(campaign.closeAt!) : '미정';

    return Card(
      color: AppColors.white,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => GoRouter.of(context).push('/campaign/${campaign.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 썸네일 이미지와 AD 뱃지
            Stack(
              children: [
                Image.network(
                  campaign.coverImageUrl ?? 'https://picsum.photos/seed/${campaign.id}/400/200',
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 180,
                    color: AppColors.disabled,
                    child: const Center(child: Icon(Icons.image_not_supported)),
                  ),
                ),
                if (campaign.isAd == true)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.black.withAlpha(179),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('AD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.black.withAlpha(179),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'AD',
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // 공고 정보 (제목, 브랜드, 메타데이터, 지원 버튼)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 공고 제목
                  Text(
                    campaign.title ?? '제목 없음',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 브랜드명과 메타 정보
                  Text(
                    '${campaign.brandName ?? '브랜드 미정'} · 출연료 $feeText · 마감 $deadline',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textGrey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 바로 지원하기 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.send, size: 18),
                      label: Text(authProvider.recruitButtonText),
                      onPressed: () async {
                        // 1. 비회원인 경우
                        if (!authProvider.isLoggedIn) {
                          final confirm = await showCommonPromptDialog(
                            context: context,
                            title: '로그인이 필요합니다',
                            content: '공고에 지원하려면 로그인이 필요해요.\n로그인 페이지로 이동하시겠습니까?',
                            confirmText: '로그인',
                          );
                          if (confirm == true) context.go('/login');
                          return;
                        }

                        // 2. 로그인된 사용자의 역할에 따라 분기
                        switch (authProvider.role) {
                          case 'showhost':
                            // 쇼호스트인 경우, 이미 지원했는지 먼저 확인
                            if (campaign.isApplied == true) {
                              // 이미 지원했다면 토스트 메시지 표시
                              showCustomToast(context, '이미 지원한 공고입니다.', type: ToastType.info);
                            } else {
                              // [수정] 바텀시트의 반환 값을 확인하여 목록을 새로고침합니다.
                              final result = await showApplyBottomSheet(context, campaign);
                              print("✅ (B) 바텀 시트가 닫혔고, 반환된 값은 [ $result ] 입니다.");
                              if (result == true) {
                                print("✅ (B-1) 반환값이 true이므로, 데이터 새로고침을 요청합니다!");
                                // 지원에 성공했으면 RecruitListProvider의 데이터를 새로고침
                                context.read<RecruitListProvider>().fetchRecruits();
                              }
                            }
                            break;
                          case 'brand':
                            // 브랜드인 경우: 지원 현황 페이지로 이동
                            GoRouter.of(context).go('/campaign/${campaign.id}/applicants');
                            break;
                          default:
                            // 기타 역할 (예: 일반 사용자)도 지원 바텀 시트 표시
                            showApplyBottomSheet(context, campaign);
                            break;
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: AppColors.primary, // 이미지와 유사한 파란색
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
