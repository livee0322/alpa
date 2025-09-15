import 'dart:convert';
import 'package:livee/data/core/api_client.dart';
import 'package:livee/domain/models/clip.dart';

// [설명] 숏클립 관련 API 통신을 담당
class ClipRepository {
  final ApiClient _apiClient = ApiClient();

  // 숏클립 목록 조회 API를 호출 (GET /clips)
  Future<List<Clip>> getClips() async {
    final response = await _apiClient.get('/clips');
    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      final List<dynamic> items = json['items'] ?? [];
      return items.map((item) => Clip.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load clips');
    }
  }

  // 숏클립 생성 API를 호출 (POST /clips)
  Future<Clip> createClip(
      {required String url, String? title, String? description}) async {
    final response = await _apiClient.post(
      '/clips',
      body: {
        'url': url,
        'title': title,
        'description': description,
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      return Clip.fromJson(json['data'] ?? json);
    } else {
      throw Exception(utf8.decode(response.bodyBytes));
    }
  }

  // 숏클립 삭제 API를 호출 (DELETE /clips/{clipId})
  Future<void> deleteClip(String clipId) async {
    final response = await _apiClient.delete('/clips/$clipId');
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to delete clip');
    }
  }

  // URL 스크래핑 API를 호출하여 영상 정보를 가져오기 (GET /scrape)
  Future<Map<String, dynamic>> scrapeVideoInfo(String videoUrl) async {
    final response =
        await _apiClient.get('/scrape?url=${Uri.encodeComponent(videoUrl)}');
    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      return json['data'] as Map<String, dynamic>;
    } else {
      throw Exception('Failed to scrape video info');
    }
  }
}
