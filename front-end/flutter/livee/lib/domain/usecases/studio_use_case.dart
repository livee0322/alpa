import 'package:livee/domain/repositories/studio_repository.dart';

/// '스튜디오' 관련 비즈니스 로직
class StudioUseCase {
  final StudioRepository _repository;

  StudioUseCase(this._repository);

  /// 새로운 스튜디오를 생성
  Future<void> createStudio(Map<String, dynamic> data) {
    return _repository.createStudio(data);
  }

  // TODO: 스튜디오 수정 및 조회 UseCase 메소드 추가 예정
}
