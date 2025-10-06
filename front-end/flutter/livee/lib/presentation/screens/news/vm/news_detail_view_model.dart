import 'package:livee/domain/models/news.dart';
import 'package:livee/domain/usecases/news_use_case.dart';
import 'package:livee/presentation/common/vm/detail_view_model_base.dart';
import 'package:livee/service_locator.dart';

/// '뉴스 상세' 페이지의 상태와 로직을 관리
class NewsDetailViewModel extends DetailViewModelBase<News> {
  final NewsUseCase _newsUseCase = locator<NewsUseCase>();

  NewsDetailViewModel({required String newsId}) {
    loadItem(newsId);
  }

  /// 서버에서 특정 뉴스의 상세 정보를 불러오는 메소드
  @override
  Future<News> fetchItem(String id) {
    return _newsUseCase.getNewsById(id);
  }
}
