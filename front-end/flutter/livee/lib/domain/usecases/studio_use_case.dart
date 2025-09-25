import 'package:livee/domain/models/studio.dart';
import 'package:livee/domain/repositories/studio_repository.dart';

/// '스튜디오' 관련 비즈니스 로직
class StudioUseCase {
  final StudioRepository _repository;

  StudioUseCase(this._repository);

  /// 새로운 스튜디오를 생성
  Future<void> createStudio(Map<String, dynamic> data) {
    return _repository.createStudio(data);
  }

  // ID로 특정 스튜디오 정보 조회
  Future<Studio> getStudioById(String id) {
    return _repository.getStudioById(id);
  }
}
