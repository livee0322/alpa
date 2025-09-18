import 'package:flutter/material.dart';
import 'package:livee/domain/models/portfolio.dart';
import 'package:livee/presentation/styles/app_colors.dart';
import 'package:livee/presentation/widgets/standard_content_card.dart';

// '컨셉에 맞는 모델 찾기' 섹션
class ConceptModelSection extends StatelessWidget {
  final List<Portfolio> models;

  const ConceptModelSection({
    super.key,
    required this.models,
  });

  @override
  Widget build(BuildContext context) {
    // 모델 데이터가 없으면 아무것도 표시 X
    if (models.isEmpty) {
      return const SizedBox.shrink();
    }

    return StandardContentCard(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: List.generate(models.length, (index) {
          final model = models[index];
          // 각 모델 정보를 표시하는 _buildModelListItem 호출
          return _buildModelListItem(context, model, isLast: index == models.length - 1);
        }),
      ),
    );
  }

  // 개별 모델 정보를 표시하는 리스트 아이템
  Widget _buildModelListItem(BuildContext context, Portfolio model, {bool isLast = false}) {
    return Padding(
      // 마지막 아이템에는 하단 여백 X
      padding: EdgeInsets.only(bottom: isLast ? 0 : 20.0),
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
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      model.oneLineIntro ?? '소개 준비 중',
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 14,
                      ),
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
                  icon: const Icon(Icons.send, size: 16),
                  label: const Text('제안'),
                  onPressed: () {
                    // TODO: 제안하기 기능 구현
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonDark, // 새로 추가한 색상 사용
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.person_outline, size: 16),
                  label: const Text('프로필 보기'),
                  onPressed: () {
                    // TODO: 프로필 보기 페이지로 이동
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textBlack,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 4. '프로필 상세보기' 텍스트 버튼
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // TODO: 프로필 상세보기 페이지로 이동
              },
              child: const Text(
                '프로필 상세보기 >',
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 13,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
