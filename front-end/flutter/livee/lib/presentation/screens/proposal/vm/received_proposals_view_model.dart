import 'package:livee/domain/models/paginated_response.dart';
import 'package:livee/domain/models/proposal.dart';
import 'package:livee/domain/usecases/proposal_use_case.dart';
import 'package:livee/presentation/common/vm/paginated_view_model_base.dart';
import 'package:livee/service_locator.dart';

/// '받은 제안' ViewModel과 거의 동일한 구조
class ReceivedProposalsViewModel extends PaginatedViewModelBase<Proposal> {
  final ProposalUseCase _useCase = locator<ProposalUseCase>();

  String _currentFilter = 'all';

  // 필터의 key와 UI에 표시될 이름을 매핑하는 Map을 추가
  final Map<String, String> filterOptions = {
    'all': '전체',
    'pending': '대기',
    'accepted': '수락',
    'rejected': '거절',
    'withdrawn': '철회',
    'hold': '보류',
  };

  String get currentFilter => _currentFilter;

  @override
  Future<PaginatedResponse<Proposal>> fetchPage(int page) {
    return _useCase.getReceivedProposals(
      status: _currentFilter,
      page: page,
    );
  }

  void setFilter(String filterKey) {
    if (_currentFilter != filterKey && filterOptions.containsKey(filterKey)) {
      _currentFilter = filterKey;
      // 부모 클래스의 loadData()를 호출하여 목록을 새로고침
      loadData();
    }
  }
}
