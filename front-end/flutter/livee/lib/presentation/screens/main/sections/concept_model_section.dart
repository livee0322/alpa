

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
    if (models.isEmpty) {
      return const SizedBox.shrink();
    }

    // 가로 스크롤이 가능한 리스트뷰를 생성
    return SizedBox(
      height: 220, // 섹션의 높이를 고정
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: models.length,
        itemBuilder: (context, index) {
          final model = models[index];
          return _buildModelCard(context, model);
        },
        // 각 카드 사이의 간격을 설정
        separatorBuilder: (context, index) => const SizedBox(width: 12),
      ),
    );
  }

  // 개별 모델 정보를 표시하는 카드
  Widget _buildModelCard(BuildContext context, Portfolio model) {
    // 카드의 너비를 고정
    return SizedBox(
      width: 150,
      child: StandardContentCard(
        padding: EdgeInsets.zero,
        margin: EdgeInsets.zero,
        onTap: () {
          // TODO: 모델 상세 페이지로 이동
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 모델 이미지 (카드 상단)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: AspectRatio(
                aspectRatio: 1, // 1:1 비율
                child: Image.network(
                  model.mainThumbnailUrl ?? 'https://picsum.photos/seed/${model.id}/200/200',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(color: AppColors.disabled),
                ),
              ),
            ),
            // 2. 모델 정보 (이름, 소개)
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model.nickname ?? '이름 없음',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    model.oneLineIntro ?? '소개 준비 중',
                    style: const TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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