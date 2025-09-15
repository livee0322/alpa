import 'package:flutter/material.dart';
import 'package:livee/presentation/widgets/divided_list_view.dart';

// 뉴스 기사 데이터를 담기 위한 임시 내부 클래스
class _NewsArticle {
  final String title;
  final String description;
  final String publishedAt;
  _NewsArticle(
      {required this.title,
      required this.description,
      required this.publishedAt});
}

// 메인 화면의 '라이비 뉴스' 섹션 UI
class NewsSection extends StatelessWidget {
  const NewsSection({super.key});

  @override
  Widget build(BuildContext context) {
    // API 대신 사용할 임시 데이터
    final dummyArticles = [
      _NewsArticle(
        title: '[테스트] LT텔레콤 쇼핑라이브 최예나, 누적 3천·동시 50만',
        description: '장단점 ‘있는 그대로’ 전달…“7년 차 베테랑 진행 감탄”',
        publishedAt: '2025-09-07',
      ),
      _NewsArticle(
        title: '라이브 커머스, 이제 AI가 진행한다…업계 패러다임 변화 예고',
        description: '가상 쇼호스트를 활용한 24시간 방송 시대 열리나',
        publishedAt: '2025-09-06',
      ),
    ];

    // DividedListView와 DividedListItem을 사용하여 UI를 구성
    return DividedListView(
      children: dummyArticles.map((article) {
        return DividedListItem(
          onTap: () {
            // TODO: 외부 링크로 이동하는 기능 구현
          },
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
                '${article.publishedAt} · ${article.description}',
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
