import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/domain/models/campaign.dart';
import 'package:livee/presentation/providers/auth_provider.dart';
import 'package:livee/presentation/screens/main/vm/main_view_model.dart';
import 'package:livee/presentation/screens/main/widgets/apply_bottom_sheet.dart';
import 'package:livee/presentation/widgets/common_prompt_dialog.dart';
import 'package:livee/presentation/widgets/custom_toast.dart';
import 'package:provider/provider.dart';

/// 메인 화면의 '브랜드 pick' 섹션을 보여주는 위젯
class RecruitSection extends StatelessWidget {
  final List<Campaign> recruits;

  const RecruitSection({
    super.key,
    required this.recruits,
  });

  @override
  Widget build(BuildContext context) {
    if (recruits.isEmpty) {
      return const Center(child: Text('등록된 공고가 없습니다'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recruits.length,
      itemBuilder: (context, index) {
        final campaign = recruits[index];
        return _buildRecruitCard(context, campaign);
      },
    );
  }

  /// 개별 공고 카드를 빌드하는 메소드
  Widget _buildRecruitCard(BuildContext context, Campaign campaign) {
    final authProvider = context.watch<AuthProvider>();
    final mainViewModel = context.read<MainViewModel>();
    // D-day와 출연료 텍스트를 계산하는 로직
    final dDay = _calculateDday(campaign.closeAt);
    String feeText = '협의';
    if (campaign.fee != null && campaign.fee! > 0) {
      feeText = '${(campaign.fee! / 10000).round()}만원';
    } else if (campaign.feeNegotiable == true) {
      feeText = '협의';
    }

    return GestureDetector(
      onTap: () => GoRouter.of(context).push('/campaign/${campaign.id}'),
      child: Card(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        margin: const EdgeInsets.only(bottom: 10.0),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 왼쪽 이미지
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      campaign.coverImageUrl ??
                          'https://picsum.photos/seed/recruit${campaign.id}/120/120',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[200],
                        child:
                            Icon(Icons.broken_image, color: Colors.grey[400]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 오른쪽 텍스트 및 버튼 영역
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          campaign.brand ?? '브랜드명',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        // const SizedBox(height: 2),
                        Text(
                          campaign.title ?? '공고 제목',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // const SizedBox(height: 2),
                        // 마감일과 출연료 표시 부분을 D-day 뱃지 스타일로 변경
                        Row(
                          children: [
                            if (dDay.isNotEmpty) ...[
                              // D-day 뱃지
                              Text(
                                dDay,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF4338CA),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              _buildMetaSeparator(),
                            ],
                            // 출연료
                            Text(
                              '출연료 $feeText',
                              style: const TextStyle(
                                  fontSize: 13, color: Color(0xFF6B7280)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 지원하기 버튼
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        // 1. 비회원인 경우 로그인 유도 팝업을 띄웁니다.
                        if (!authProvider.isLoggedIn) {
                          final confirm = await showCommonPromptDialog(
                            context: context,
                            title: '로그인이 필요합니다',
                            content: '공고에 지원하려면 로그인이 필요해요.\n로그인 페이지로 이동하시겠습니까?',
                            confirmText: '로그인',
                          );
                          if (confirm == true && context.mounted) {
                            GoRouter.of(context).go('/login');
                          }
                          return;
                        }

                        // 2. 로그인된 사용자의 역할에 따라 기능을 분기합니다.
                        switch (authProvider.role) {
                          case 'showhost':
                            // 쇼호스트일 경우, 이미 지원했는지 확인합니다.
                            if (campaign.isApplied == true) {
                              // 이미 지원했다면 토스트 메시지를 표시합니다.
                              showCustomToast(context, '이미 지원한 공고입니다.',
                                  type: ToastType.info);
                            } else {
                              // 아직 지원하지 않았다면 지원 바텀 시트를 엽니다.
                              final result =
                                  await showApplyBottomSheet(context, campaign);
                              // 지원에 성공했다면(결과가 true), 메인 화면 데이터를 새로고침합니다.
                              if (result == true) {
                                mainViewModel.loadData();
                              }
                            }
                            break;
                          case 'brand':
                            // 브랜드 계정은 메인 화면에서 '지원 현황' 버튼이 없지만,
                            // 예외적으로 이 버튼을 보게 될 경우 지원자 목록 페이지로 이동시킵니다.
                            GoRouter.of(context)
                                .go('/campaign/${campaign.id}/applicants');
                            break;
                          default:
                            // 기타 로그인 사용자(역할이 없거나 다른 역할)의 경우,
                            // 쇼호스트와 동일하게 지원 로직을 수행합니다.
                            final result =
                                await showApplyBottomSheet(context, campaign);
                            if (result == true) {
                              mainViewModel.loadData();
                            }
                            break;
                        }
                      },
                      icon: const Icon(Icons.send_outlined, size: 18),
                      label: const Text('지원하기'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF6C63FF),
                        side: const BorderSide(color: Color(0xFF6C63FF)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 북마크 아이콘 버튼
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => showCustomToast(context, '준비중인 기능입니다.',
                          type: ToastType.info),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Icon(Icons.bookmark_outline, size: 24),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 메타 정보 구분자 위젯
  Widget _buildMetaSeparator() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: Text('|', style: TextStyle(color: Color(0xFFD1D5DB))),
    );
  }

  /// D-day 계산 로직
  String _calculateDday(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final today = DateTime.now();
      final difference =
          date.difference(DateTime(today.year, today.month, today.day)).inDays;

      if (difference < 0) return '마감';
      if (difference == 0) return 'D-DAY';
      return 'D-$difference';
    } catch (e) {
      return '';
    }
  }
}
