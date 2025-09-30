import 'package:flutter/material.dart';
import 'package:livee/domain/models/proposal.dart';
import 'package:livee/domain/usecases/proposal_use_case.dart';
import 'package:livee/service_locator.dart';

// '보낸 제안' ViewModel과 거의 동일한 구조
class ReceivedProposalsViewModel with ChangeNotifier {
  final ProposalUseCase _useCase = locator<ProposalUseCase>();

  ReceivedProposalsViewModel() {
    _fetchProposals();
  }

  bool _isLoading = true;
  bool _isLoadingMore = false;
  List<Proposal> _proposals = [];
  String _currentFilter = 'all';
  int _currentPage = 1;
  int _totalPages = 1;

  // 필터의 key와 UI에 표시될 이름을 매핑하는 Map을 추가
  final Map<String, String> filterOptions = {
    'all': '전체',
    'pending': '대기',
    'accepted': '수락',
    'rejected': '거절',
    'withdrawn': '철회',
    'hold': '보류',
  };

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  List<Proposal> get proposals => _proposals;
  String get currentFilter => _currentFilter;
  bool get hasMore => _currentPage < _totalPages;

  Future<void> _fetchProposals({bool isLoadMore = false}) async {
    if (_isLoadingMore) return;

    if (isLoadMore) {
      _isLoadingMore = true;
    } else {
      _isLoading = true;
      _currentPage = 1;
    }
    notifyListeners();
    try {
      final response = await _useCase.getReceivedProposals(
        status: _currentFilter,
        page: _currentPage,
      );
      if (isLoadMore) {
        _proposals.addAll(response.items);
      } else {
        _proposals = response.items;
      }
      _totalPages = response.totalPages;
    } catch (e) {
      debugPrint('Error fetching sent proposals: $e');
    } finally {
      if (isLoadMore) {
        _isLoadingMore = false;
      } else {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  void setFilter(String filterKey) {
    // Map에 키가 존재하는지 확인하는 방어 코드 추가
    if (_currentFilter != filterKey && filterOptions.containsKey(filterKey)) {
      _currentFilter = filterKey;
      _fetchProposals();
    }
  }

  void fetchNextPage() {
    if (hasMore && !_isLoadingMore) {
      _currentPage++;
      _fetchProposals(isLoadMore: true);
    }
  }
}
