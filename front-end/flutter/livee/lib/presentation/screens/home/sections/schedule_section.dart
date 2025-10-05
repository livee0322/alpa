import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/domain/models/campaign.dart';
import 'package:livee/presentation/styles/app_colors.dart';
import 'package:livee/presentation/utils/utility.dart';
import 'package:livee/presentation/common/standard_content_card.dart';

/// '지금 뜨는 쇼핑 라이브 공고' 섹션 UI
class ScheduleSection extends StatelessWidget {
  final List<Campaign> schedules;

  const ScheduleSection({
    super.key,
    required this.schedules,
  });

  @override
  Widget build(BuildContext context) {
    if (schedules.isEmpty) {
      return const Center(child: Text('등록된 공고가 없습니다'));
    }

    // 카드 리스트 UI
    return SizedBox(
      height: 500,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: schedules.length,
        itemBuilder: (context, index) {
          final campaign = schedules[index];
          return _buildRecruitCard(context, campaign);
        },
        separatorBuilder: (context, index) => const SizedBox(width: 12),
      ),
    );
  }

  // 개별 공고 카드 위젯을 생성
  Widget _buildRecruitCard(BuildContext context, Campaign campaign) {
    final dDay = Utility.calculateDday(campaign.closeAt?.toIso8601String());
    final isClosed = dDay == '마감';

    // 카드의 폭을 지정하고 공통 카드 컴포넌트를 사용
    return SizedBox(
      width: 230,
      child: StandardContentCard(
        padding: EdgeInsets.zero,
        margin: EdgeInsets.zero,
        onTap: () => context.push('/campaign/${campaign.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 공고 썸네일 이미지
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: AspectRatio(
                aspectRatio: 2 / 3,
                child: Image.network(
                  campaign.liveVerticalCoverUrl ?? 'https://picsum.photos/seed/recruit${campaign.id}',
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
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            campaign.brandName ?? '브랜드명',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textGrey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Spacer(),
                        Expanded(
                          flex: 4,
                          child: Chip(
                            label: Text(campaign.prefix!),
                            labelStyle: const TextStyle(
                              color: AppColors.buttonDark,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            backgroundColor: AppColors.buttonDark.withAlpha(26),
                            side: BorderSide.none,
                            padding: EdgeInsets.zero,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Visibility(
                            visible: !isClosed,
                            maintainSize: true,
                            maintainAnimation: true,
                            maintainState: true,
                            child: Chip(
                              label: const Text('모집중'),
                              labelStyle: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              backgroundColor: AppColors.primary.withAlpha(26),
                              side: BorderSide.none,
                              padding: EdgeInsets.zero,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // 제목
                    Text(
                      campaign.title ?? '공고 제목',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const Spacer(),

                    // 상품 이미지 및 가격 위젯
                    _buildProductInfo(context, campaign),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// [추가] 상품 이미지, 상품명, 가격을 표시하는 위젯
  Widget _buildProductInfo(BuildContext context, Campaign campaign) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. 정사각형 상품 이미지
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.network(
            // [수정] productThumbnailUrl 필드를 사용합니다.
            campaign.productThumbnailUrl ?? 'https://picsum.photos/seed/${campaign.id}/50/50',
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 50,
              height: 50,
              color: AppColors.disabled,
            ),
          ),
        ),
        const SizedBox(width: 8),

        // 2. 상품명 및 가격
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                // [수정] productName 필드를 사용합니다.
                campaign.productName ?? '상품명 미정',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textGrey,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
