import 'package:livee/domain/models/clip.dart';
import 'package:livee/domain/repositories/clip_repository.dart';

/// 숏클립 관련 비즈니스 로직을 처리
class ClipUseCase {
  final ClipRepository _repository;
  ClipUseCase(this._repository);

  // 숏클립 목록을 조회
  Future<List<Clip>> getClips() {
    return _repository.getClips();
  }

  // 숏클립을 생성
  Future<Clip> createClip(
      {required String url, String? title, String? description}) {
    return _repository.createClip(
        url: url, title: title, description: description);
  }

  // 숏클립을 삭제
  Future<void> deleteClip(String clipId) {
    return _repository.deleteClip(clipId);
  }

  // 영상 정보를 스크래핑
  Future<Map<String, dynamic>> scrapeVideoInfo(String videoUrl) {
    return _repository.scrapeVideoInfo(videoUrl);
  }
}
