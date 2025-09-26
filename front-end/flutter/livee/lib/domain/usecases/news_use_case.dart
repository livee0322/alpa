import 'package:livee/domain/models/news.dart';
import 'package:livee/domain/models/paginated_response.dart';
import 'package:livee/domain/repositories/news_repository.dart';

/// '뉴스' 관련 비즈니스 로직을 처리
class NewsUseCase {
  final NewsRepository _repository;

  NewsUseCase(this._repository);

  /// 뉴스 목록 조회
  Future<PaginatedResponse<News>> getNewsList({int page = 1, int limit = 10}) {
    return _repository.getNewsList(page: page, limit: limit);
  }

  /// 뉴스 상세 정보 조회
  Future<News> getNewsById(String id) {
    return _repository.getNewsById(id);
  }

  /// 뉴스 생성
  Future<void> createNews(Map<String, dynamic> data) {
    return _repository.createNews(data);
  }

  /// 뉴스 수정
  Future<void> updateNews(String id, Map<String, dynamic> data) {
    return _repository.updateNews(id, data);
  }

  /// 뉴스 삭제
  Future<void> deleteNews(String id) {
    return _repository.deleteNews(id);
  }
}
