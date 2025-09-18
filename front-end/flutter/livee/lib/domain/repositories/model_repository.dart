import 'dart:convert';
import 'package:livee/data/core/api_client.dart';
import 'package:livee/domain/models/model.dart';
import 'package:livee/domain/models/paginated_response.dart';

/// '모델' 관련 API 호출을 담당하는 저장소
class ModelRepository {
  final ApiClient _apiClient = ApiClient();

  /// 새로운 모델 프로필을 생성 (POST /models)
  Future<void> createModel(Map<String, dynamic> data) async {
    final response = await _apiClient.post('/models', body: data);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(utf8.decode(response.bodyBytes));
    }
  }

  /// 전체 모델 목록을 조회 (GET /models)
  Future<PaginatedResponse<Model>> getAllModels({int? page, int? limit}) async {
    final Map<String, dynamic> queryParams = {};
    if (page != null) queryParams['page'] = page.toString();
    if (limit != null) queryParams['limit'] = limit.toString();

    final response = await _apiClient.get('/models?${Uri(queryParameters: queryParams).query}');

    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      return PaginatedResponse.fromJson(json, (itemJson) => Model.fromJson(itemJson));
    } else {
      throw Exception('Failed to load all models');
    }
  }

  /// 특정 모델을 삭제 (DELETE /models/:id)
  Future<void> deleteModel(String id) async {
    final response = await _apiClient.delete('/models/$id');
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to delete model');
    }
  }
}
