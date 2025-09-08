import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:livee/domain/models/news_article.dart';

class NewsRepository {
  // 실제 뉴스 API 엔드포인트와 API 키로 교체해야 합니다.
  final String _apiKey = 'YOUR_NEWS_API_KEY';
  final String _baseUrl = 'https://newsapi.org/v2/everything';

  Future<List<NewsArticle>> getLiveCommerceNews({int limit = 5}) async {
    // '라이브커머스' 키워드로 뉴스를 검색합니다.
    final response = await http.get(
      Uri.parse('$_baseUrl?q=live-commerce&apiKey=$_apiKey&pageSize=$limit&language=ko'),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      final List<dynamic> articlesJson = json['articles'] ?? [];
      return articlesJson.map((item) => NewsArticle.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load news');
    }
  }
}
