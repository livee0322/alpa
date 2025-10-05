import 'package:livee/domain/models/news.dart';
import 'package:livee/domain/models/paginated_response.dart';
import 'package:livee/domain/usecases/news_use_case.dart';
import 'package:livee/presentation/common/vm/paginated_view_model_base.dart';
import 'package:livee/service_locator.dart';

/// '뉴스 목록' 화면의 상태와 로직을 관리
class NewsListViewModel extends PaginatedViewModelBase<News> {
  final NewsUseCase _newsUseCase = locator<NewsUseCase>();

  @override
  Future<PaginatedResponse<News>> fetchPage(int page) {
    return _newsUseCase.getNewsList(page: page, limit: 10);
  }
}
