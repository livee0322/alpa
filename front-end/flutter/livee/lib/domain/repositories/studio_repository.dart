import 'dart:convert';

import 'package:livee/data/core/api_client.dart';

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

  // TODO: 스튜디오 수정 및 조회 Repository 메소드 추가 예정
}
