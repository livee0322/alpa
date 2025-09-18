import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/domain/models/campaign.dart';
import 'package:livee/presentation/styles/app_colors.dart';
import 'package:livee/presentation/widgets/divided_list_view.dart';

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
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.border,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            '예정된 일정이 없습니다.',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF9AA3AF),
            ),
          ),
        ),
      );
    }

    // 구분선으로 분리된 리스트
    return DividedListView(
      children: schedules.map((campaign) {
        final closeDate = campaign.closeAt?.substring(0, 10) ?? '미정';
        String feeText = '미정';
        if (campaign.fee != null && campaign.fee! > 0) {
          feeText = '${(campaign.fee! / 10000).round()}만원';
        } else if (campaign.feeNegotiable == true) {
          feeText = '협의';
        }

        return DividedListItem(
          onTap: () => GoRouter.of(context).push('/campaign/${campaign.id}'),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  campaign.coverImageUrl ??
                      'https://picsum.photos/seed/schedule${campaign.id}/96/96',
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Placeholder(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      campaign.brand ?? '브랜드',
                      style: const TextStyle(
                        color: AppColors.textBlack,
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      campaign.title ?? '제목 없음',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '마감 $closeDate · 출연료 $feeText',
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
