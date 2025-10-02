import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/domain/models/campaign.dart';
import 'package:livee/presentation/styles/app_colors.dart';
import 'package:livee/presentation/widgets/divided_list_view.dart';
import 'package:livee/presentation/widgets/trending_recruit_card.dart';

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

    // [수정] 기존 DividedListView를 가로 스크롤이 가능한 ListView.separated로 변경합니다.
    return SizedBox(
      height: 320, // 가로 스크롤 영역의 높이를 지정합니다.
      child: ListView.separated(
        scrollDirection: Axis.horizontal, // 가로 스크롤 설정
        itemCount: schedules.length,
        itemBuilder: (context, index) {
          final campaign = schedules[index];
          // [수정] 새로 만든 TrendingRecruitCard 위젯을 사용합니다.
          return TrendingRecruitCard(campaign: campaign);
        },
        // [수정] 카드 사이의 간격을 지정합니다.
        separatorBuilder: (context, index) => const SizedBox(width: 12),
      ),
    );
  }
}
