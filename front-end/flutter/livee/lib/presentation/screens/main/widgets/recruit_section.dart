import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/domain/models/campaign.dart';
import 'package:livee/presentation/widgets/custom_toast.dart';

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
                      campaign.coverImageUrl ?? 'https://picsum.photos/seed/recruit${campaign.id}/120/120',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[200],
                        child: Icon(Icons.broken_image, color: Colors.grey[400]),
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
                              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
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
                      onPressed: () => GoRouter.of(context).push('/campaign/${campaign.id}'),
                      icon: const Icon(Icons.send_outlined, size: 18),
                      label: const Text('지원하기'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF6C63FF),
                        side: const BorderSide(color: Color(0xFF6C63FF)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                      onPressed: () => showCustomToast(context, '준비중인 기능입니다.', type: ToastType.info),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
      final difference = date.difference(DateTime(today.year, today.month, today.day)).inDays;

      if (difference < 0) return '마감';
      if (difference == 0) return 'D-DAY';
      return 'D-$difference';
    } catch (e) {
      return '';
    }
  }
}
