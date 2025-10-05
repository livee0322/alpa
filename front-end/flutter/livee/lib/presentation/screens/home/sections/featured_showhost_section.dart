import 'package:flutter/material.dart';
import 'package:livee/domain/models/portfolio.dart';
import 'package:livee/presentation/providers/auth_provider.dart';
import 'package:livee/presentation/screens/proposal/proposal_bottom_sheet.dart';
import 'package:livee/presentation/styles/app_colors.dart';
import 'package:livee/presentation/common/custom_toast.dart';
import 'package:livee/presentation/common/standard_content_card.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';

// '이런 쇼호스트는 어떠세요?' 섹션
class FeaturedShowhostListSection extends StatelessWidget {
  final List<Portfolio> models;

  const FeaturedShowhostListSection({
    super.key,
    required this.models,
  });

  @override
  Widget build(BuildContext context) {
    if (models.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      // List.generate 대신 map을 사용하여 각 모델을 카드 위젯으로 변환
      children: models.map((model) {
        return _buildModelCard(context, model);
      }).toList(),
    );
  }

  // 개별 모델 정보를 표시하는 카드 위젯
  Widget _buildModelCard(BuildContext context, Portfolio model) {
    // AuthProvider를 사용하여 현재 사용자 정보를 가져오기
    final authProvider = context.watch<AuthProvider>();

    return StandardContentCard(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
      child: Column(
        children: [
          Row(
            children: [
              // 1. 프로필 이미지
              CircleAvatar(
                radius: 32,
                backgroundImage: model.mainThumbnailUrl != null ? NetworkImage(model.mainThumbnailUrl!) : null,
                child: model.mainThumbnailUrl == null ? const Icon(Icons.person) : null,
              ),
              const SizedBox(width: 16),
              // 2. 이름과 한 줄 소개
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      model.nickname ?? '이름 없음',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      model.oneLineIntro ?? '소개 준비 중',
                      style: const TextStyle(color: AppColors.textGrey, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 3. '제안', '프로필 보기' 버튼
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(RemixIcons.send_plane_line, size: 16),
                  label: const Text(
                    '제안',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () => authProvider.role == 'brand'
                      ? showProposalBottomSheet(context, portfolio: model)
                      : showCustomToast(
                          context,
                          '브랜드 회원만 제안하기가 가능합니다.',
                          type: ToastType.info,
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonDark,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(RemixIcons.user_line, size: 16),
                  label: const Text(
                    '프로필 보기',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    // TODO: 프로필 보기 페이지로 이동
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textBlack,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.border, height: 0.1, thickness: 1), // [추가] 구분선을 추가합니다

          // 4. '프로필 상세보기' 텍스트 버튼
          TextButton(
            onPressed: () {
              // TODO: 프로필 상세보기 페이지로 이동
            },
            child: const Text(
              '프로필 상세보기 >',
              style: TextStyle(
                color: AppColors.textGrey,
                fontSize: 13,
                fontWeight: FontWeight.normal,
              ),
            ),
          )
        ],
      ),
    );
  }
}
