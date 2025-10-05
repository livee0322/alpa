import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/domain/models/news.dart';
import 'package:livee/presentation/utils/utility.dart';
import 'package:livee/presentation/common/divided_list_view.dart';

// 메인 화면의 '라이비 뉴스' 섹션 UI
class NewsSection extends StatelessWidget {
  final List<News> news;
  const NewsSection({
    super.key,
    required this.news,
  });

  @override
  Widget build(BuildContext context) {
    // [추가] 전달받은 뉴스 데이터가 비어있을 경우 안내 문구를 표시합니다.
    if (news.isEmpty) {
      return const Center(child: Text('등록된 뉴스가 없습니다.'));
    }
    // DividedListView와 DividedListItem을 사용하여 UI를 구성
    return DividedListView(
      children: news.map((article) {
        // 날짜 데이터를 'O일 전'과 같은 상대 시간으로 변환합니다.
        final relativeTime = Utility.formatRelativeTime(article.createdAt);
        return DividedListItem(
          onTap: () => context.go('/news/${article.id}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                article.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '$relativeTime · ${article.content}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
