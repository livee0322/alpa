// lib/presentation/screens/main/widgets/featured_showhost_section.dart

import 'package:flutter/material.dart';
import 'package:livee/domain/models/portfolio.dart';
import 'package:livee/presentation/widgets/standard_content_card.dart';

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

    final host = showhosts.first;

    return StandardContentCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 프로필 이미지
          CircleAvatar(
            radius: 32,
            backgroundImage: host.mainThumbnailUrl != null ? NetworkImage(host.mainThumbnailUrl!) : null,
            child: host.mainThumbnailUrl == null ? const Icon(Icons.person) : null,
          ),
          const SizedBox(width: 16),
          // 2. 나머지 정보 (이름, 소개, 버튼)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 이름
                Text(
                  host.nickname ?? host.name ?? '이름 없음',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 2),
                // 소개
                Text(
                  host.oneLineIntro ?? '소개 준비 중',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 12),
                // 버튼 그룹
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.mail_outline, size: 16),
                        label: const Text(
                          '제안하기',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        onPressed: () {
                          // TODO: 제안하기 기능 구현
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF4B5563),
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.person_outline, size: 16),
                        label: const Text(
                          '프로필 보기',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        onPressed: () {
                          // TODO: 프로필 보기 기능 구현
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF4B5563),
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
