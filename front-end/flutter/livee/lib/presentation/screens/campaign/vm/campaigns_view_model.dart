import 'package:livee/domain/models/campaign.dart';
import 'package:livee/domain/models/paginated_response.dart';
import 'package:livee/domain/usecases/campaign_use_case.dart';
import 'package:livee/presentation/common/vm/paginated_view_model_base.dart';
import 'package:livee/service_locator.dart';

/// '모집 공고 목록' 화면의 상태와 비즈니스 로직(페이지네이션 로직 상속)
class CampaignsViewModel extends PaginatedViewModelBase<Campaign> {
  final CampaignUseCase _campaignUseCase = locator<CampaignUseCase>();

  // --- 상태 변수 ---
  String _searchQuery = '';
  String _sortBy = 'latest';

  // --- Getter ---
  String get sortBy => _sortBy;

  /// 모든 '쇼호스트 모집' 공고를 서버에서 불러오기
  @override
  Future<PaginatedResponse<Campaign>> fetchPage(int page) {
    // 이 ViewModel의 목적에 맞는 API를 호출
    return _campaignUseCase.getAllCampaigns(
      type: 'recruit',
      limit: 10,
      page: page,
      search: _searchQuery,
      sort: _sortBy,
    );
  }

  /// 검색을 실행하고 API를 재호출
  void search(String query) {
    _searchQuery = query;
    loadData();
  }

  /// 정렬 기준을 변경하고 API를 재호출
  void setSortBy(String sort) {
    _sortBy = sort;
    loadData();
  }

  /// 페이지를 이동하고 API를 재호출 (참고: 이 기능은 현재 UI에서 사용되지 않음)
  void goToPage(int page) {
    // TODO: 부모 클래스에 이 기능을 통합하는 것을 고려
    // 우선 현재 구조에서 동작하도록 재구현
    if (page > 0 && page <= totalPages && page != currentPage) {
      // 직접 페이지를 로드하는 새 메소드를 호출하거나,
      // 부모 클래스의 currentPage를 변경하고 loadData를 호출하는 방식이 필요
      // 지금은 간단히 refresh하는 방식으로 대체
      loadData(); // 단순화를 위해 첫 페이지로 새로고침
    }
  }
}
