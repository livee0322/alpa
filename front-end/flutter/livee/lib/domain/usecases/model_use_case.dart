import 'package:livee/domain/models/model.dart';
import 'package:livee/domain/models/paginated_response.dart';
import 'package:livee/domain/repositories/model_repository.dart';

/// '모델' 관련 비즈니스 로직을 처리하는 유스케이스
class ModelUseCase {
  final ModelRepository _repository;

  ModelUseCase(this._repository);

  /// 새로운 모델을 생성
  Future<void> createModel(Map<String, dynamic> data) {
    return _repository.createModel(data);
  }

  /// 전체 모델 목록을 조회
  Future<PaginatedResponse<Model>> getAllModels({int? page, int? limit}) {
    return _repository.getAllModels(page: page, limit: limit);
  }

  /// 특정 모델을 삭제
  Future<void> deleteModel(String id) {
    return _repository.deleteModel(id);
  }

  /// ID로 특정 모델의 상세 정보를 조회
  Future<Model> getModelById(String id) {
    return _repository.getModelById(id);
  }
}
