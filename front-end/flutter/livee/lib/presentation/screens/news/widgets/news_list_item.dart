import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/domain/models/news.dart';
import 'package:livee/presentation/styles/app_colors.dart';
import 'package:livee/presentation/utils/utility.dart';
import 'package:livee/presentation/widgets/standard_content_card.dart';

class NewsListItem extends StatelessWidget {
  final News news;
  const NewsListItem({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    // 새로 만든 유틸리티 함수를 사용하여 상대 시간을 계산
    final relativeTime = Utility.formatRelativeTime(news.createdAt);
    return StandardContentCard(
      onTap: () => GoRouter.of(context).go('/news/${news.id}'),
      child: Row(
        children: [
          // 텍스트 영역
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // '공지' 태그와 날짜
                Row(
                  children: [
                    Chip(
                      label: const Text('공지'),
                      labelStyle: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
                      backgroundColor: AppColors.primary.withAlpha(50), // 20% 투명도
                      shape: const StadiumBorder(),
                      side:  BorderSide(
                        color: AppColors.disabled.withAlpha(50), // 테두리 색상
                        width: 1.0, // 테두리 두께
                      ),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      relativeTime,
                      style: TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // 제목
                Text(
                  news.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  maxLines: 1, // 1줄로 제한
                  overflow: TextOverflow.ellipsis, // 넘어갈 경우 ... 처리
                ),
                const SizedBox(height: 4),
                // 내용
                Text(
                  news.content,
                  style: const TextStyle(color: Colors.black87, fontSize: 14),
                  maxLines: 2, // 2줄로 제한
                  overflow: TextOverflow.ellipsis, // 넘어갈 경우 ... 처리
                ),
              ],
            ),
          ),
          // 이미지가 있을 경우에만 썸네일 표시
          if (news.imageUrl != null) ...[
            const SizedBox(width: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                news.imageUrl!,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                // 이미지 로딩 중 에러가 발생하면 회색 박스 표시
                errorBuilder: (context, error, stackTrace) {
                  return Container(width: 80, height: 80, color: Colors.grey[200]);
                },
              ),
            ),
          ]
        ],
      ),
    );
  }
}
