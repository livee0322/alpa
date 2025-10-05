import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/domain/models/campaign.dart';
import 'package:livee/presentation/styles/app_colors.dart';
import 'package:livee/presentation/utils/utility.dart';

/// 홈 화면 등에서 사용될 간소화된 형태의 공용 캠페인 카드 위젯
class CompactCampaignCard extends StatelessWidget {
  final Campaign campaign;

  const CompactCampaignCard({
    super.key,
    required this.campaign,
  });

  @override
  Widget build(BuildContext context) {
    // 마감 여부 계산
    final dDay = Utility.calculateDday(campaign.closeAt?.toIso8601String());
    final isClosed = dDay == '마감';

    // 출연료 텍스트 포맷팅
    String feeText = '협의';
    if (campaign.fee != null && campaign.fee! > 0) {
      // 30000 -> 3,000원으로 포맷팅
      feeText = '${(campaign.fee!).toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          )}원';
    } else if (campaign.feeNegotiable == true) {
      feeText = '협의';
    }

    return SizedBox(
      width: 180, // 카드의 가로 폭을 지정
      child: InkWell(
        onTap: () => context.push('/campaign/${campaign.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          shadowColor: Colors.black12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 썸네일 이미지
              AspectRatio(
                aspectRatio: 1, // 1:1 비율
                child: Image.network(
                  campaign.coverImageUrl ?? 'https://picsum.photos/seed/${campaign.id}/300/300',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(color: AppColors.disabled),
                ),
              ),
              // 텍스트 정보
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 브랜드명
                      Text(
                        campaign.brandName ?? '브랜드 없음',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textGrey,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // 모집중 태그 (마감되지 않았을 때만 표시)
                      if (!isClosed)
                        Chip(
                          label: Text(campaign.prefix ?? '모집중'),
                          labelStyle: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          backgroundColor: AppColors.primary.withAlpha(26),
                          side: BorderSide.none,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                        ),
                      const Spacer(),
                      // 공고 제목
                      Text(
                        campaign.title ?? '제목 없음',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // 출연료
                      Text(
                        '출연료 $feeText',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textBlack,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
