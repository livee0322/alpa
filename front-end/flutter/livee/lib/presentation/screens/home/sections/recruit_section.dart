import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/domain/models/campaign.dart';
import 'package:livee/presentation/providers/auth_provider.dart';
import 'package:livee/presentation/screens/home/vm/home_view_model.dart';
import 'package:livee/presentation/screens/main/widgets/apply_bottom_sheet.dart';
import 'package:livee/presentation/utils/utility.dart';
import 'package:livee/presentation/widgets/common_prompt_dialog.dart';
import 'package:livee/presentation/widgets/compact_campaign_card.dart';
import 'package:livee/presentation/widgets/custom_toast.dart';
import 'package:livee/presentation/widgets/standard_content_card.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';

// 브랜드 pick' 섹션 위젯
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
          // [수정] 공용 CompactCampaignCard 위젯을 사용합니다.
          return CompactCampaignCard(campaign: campaign);
        },
        separatorBuilder: (context, index) => const SizedBox(width: 12),
      ),
    );
  }
}
