import 'package:flutter/material.dart';
import 'package:livee/domain/models/proposal.dart';
import 'package:livee/domain/usecases/proposal_use_case.dart';
import 'package:livee/service_locator.dart';

class SentProposalsViewModel with ChangeNotifier {
  final ProposalUseCase _useCase = locator<ProposalUseCase>();

  SentProposalsViewModel() {
    _fetchProposals();
  }

  bool _isLoading = true;
  bool _isLoadingMore = false;
  List<Proposal> _proposals = [];
  String _currentFilter = 'all';
  int _currentPage = 1;
  int _totalPages = 1;

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
      final response = await _useCase.getSentProposals(
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

  void setFilter(String filter) {
    if (_currentFilter != filter) {
      _currentFilter = filter;
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
