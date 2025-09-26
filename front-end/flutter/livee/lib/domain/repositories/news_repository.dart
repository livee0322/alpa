import 'dart:convert';
import 'package:livee/data/core/api_client.dart';
import 'package:livee/domain/models/news.dart';
import 'package:livee/domain/models/paginated_response.dart';

/// 뉴스 기능 관련 API 호출을 담당하는 저장소
class NewsRepository {
  final ApiClient _apiClient = ApiClient();

  /// 뉴스 목록 조회 (GET /news)
  ///
  /// 페이지네이션을 지원
  Future<PaginatedResponse<News>> getNewsList({int page = 1, int limit = 10}) async {
    final response = await _apiClient.get('/news?page=$page&limit=$limit');
    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      return PaginatedResponse.fromJson(json, (itemJson) => News.fromJson(itemJson));
    } else {
      throw Exception('Failed to load news list');
    }
  }

  /// 뉴스 상세 정보 조회 (GET /news/:id)
  ///
  /// 특정 ID를 가진 뉴스 게시물 하나의 데이터를 가져오기
  Future<News> getNewsById(String id) async {
    final response = await _apiClient.get('/news/$id');
    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      return News.fromJson(json['data'] ?? json);
    } else {
      throw Exception('Failed to load news by id');
    }
  }

  /// 뉴스 생성 (POST /news)
  ///
  /// 새로운 뉴스 게시물을 서버에 생성 (쇼호스트 권한 필요)
  Future<void> createNews(Map<String, dynamic> data) async {
    final response = await _apiClient.post('/news', body: data);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(utf8.decode(response.bodyBytes));
    }
  }

  /// 뉴스 수정 (PUT /news/:id)
  ///
  /// 기존 뉴스 게시물을 수정 (쇼호스트 권한 필요)
  Future<void> updateNews(String id, Map<String, dynamic> data) async {
    final response = await _apiClient.put('/news/$id', body: data);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(utf8.decode(response.bodyBytes));
    }
  }

  /// 뉴스 삭제 (DELETE /news/:id)
  ///
  /// 특정 뉴스 게시물을 삭제 (쇼호스트 권한 필요)
  Future<void> deleteNews(String id) async {
    final response = await _apiClient.delete('/news/$id');
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to delete news');
    }
  }
}
