import 'package:flutter/material.dart';
import 'package:livee/domain/models/portfolio.dart';
import 'package:livee/presentation/styles/app_colors.dart';
import 'package:livee/presentation/widgets/standard_content_card.dart';

/// 메인 화면의 '추천 쇼호스트' 섹션 UI
class FeaturedShowhostSection extends StatelessWidget {
  final List<Portfolio> showhosts;

  const FeaturedShowhostSection({
    super.key,
    required this.showhosts,
  });

  @override
  Widget build(BuildContext context) {
    if (showhosts.isEmpty) {
      return const Center(child: Text('추천 쇼호스트가 없습니다.'));
    }

    // 목록의 첫 번째 쇼호스트 정보를 사용
    final host = showhosts.first;

    return StandardContentCard(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 1. 상단 프로필 정보 (프로필 이미지, 이름, 소개, 별 아이콘)
          Row(
            children: [
              // 프로필 이미지
              CircleAvatar(
                radius: 32,
                backgroundImage: host.mainThumbnailUrl != null
                    ? NetworkImage(host.mainThumbnailUrl!)
                    : null,
                child: host.mainThumbnailUrl == null
                    ? const Icon(Icons.person)
                    : null,
              ),
              const SizedBox(width: 16),
              // 이름과 한 줄 소개
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      host.nickname ?? host.name ?? '이름 없음',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      host.oneLineIntro ?? '소개 준비 중',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              // 별 아이콘 버튼
              IconButton(
                icon: const Icon(Icons.star_border, color: Colors.grey),
                onPressed: () {
                  // TODO: 찜하기 기능 구현
                },
              )
            ],
          ),
          const SizedBox(height: 16),

          // 2. '제안하기' 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: 제안하기 기능 구현
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    AppColors.primary.withOpacity(0.1), // 반투명한 기본 색상
                foregroundColor: AppColors.primary, // 기본 색상 텍스트
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('제안하기',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 8),

          // 3. 하단 구분선 및 '프로필 상세보기' 링크
          const Divider(
            color: AppColors.border,
            thickness: 1,
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.center,
            child: InkWell(
              onTap: () {
                // TODO: 프로필 상세보기 페이지로 이동
              },
              child: Text(
                '프로필 상세보기',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
