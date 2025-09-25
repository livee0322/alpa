import 'dart:convert';

import 'package:livee/data/core/api_client.dart';
import 'package:livee/domain/models/studio.dart';

/// 스튜디오 관련 API 호출을 담당하는 저장소
class StudioRepository {
  final ApiClient _apiClient = ApiClient();

  /// 새로운 스튜디오 정보를 생성 (POST /studios)
  Future<void> createStudio(Map<String, dynamic> data) async {
    final response = await _apiClient.post('/studios', body: data);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(utf8.decode(response.bodyBytes));
    }
  }

  // ID로 특정 스튜디오 정보 조회 (GET /studios/:id)
  Future<Studio> getStudioById(String id) async {
    final response = await _apiClient.get('/studios/$id');
    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      return Studio.fromJson(json['data'] ?? json);
    } else {
      throw Exception('Failed to load studio by id');
    }
  }
}
