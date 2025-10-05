import 'package:flutter/widgets.dart';
import 'package:livee/domain/models/campaign.dart';
import 'package:livee/domain/usecases/campaign_use_case.dart';
import 'package:livee/service_locator.dart';

/// '모집 공고 목록' 화면의 상태와 비즈니스 로직
class CampaignsViewModel with ChangeNotifier {
  final CampaignUseCase _campaignUseCase = locator<CampaignUseCase>();

  // --- 상태 변수 ---
  bool _isLoading = false;
  List<Campaign> _campaigns = [];

  String _searchQuery = '';
  String _sortBy = 'latest'; // 'latest', 'deadline'
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalCampaigns = 0;

  // --- Getter ---
  bool get isLoading => _isLoading;
  List<Campaign> get campaigns => _campaigns;
  int get totalCampaigns => _totalCampaigns;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  String get sortBy => _sortBy;

  /// 생성자: ViewModel이 생성될 때 첫 페이지 데이터를 불러오기
  CampaignsViewModel() {
    fetchCampaigns(isNewSearch: true);
  }

  /// 모든 '쇼호스트 모집' 공고를 서버에서 불러오기
  Future<void> fetchCampaigns({bool isNewSearch = false}) async {
    if (isNewSearch) {
      _currentPage = 1;
    }
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _campaignUseCase.getAllCampaigns(
        type: 'recruit',
        limit: 10,
        page: _currentPage,
        search: _searchQuery,
        sort: _sortBy,
      );

      _campaigns = response.items;
      _totalCampaigns = response.totalItems;
      _totalPages = response.totalPages;
      _currentPage = response.currentPage;
    } catch (e) {
      debugPrint('Error fetching recruits: $e');
      _campaigns = [];
      _totalCampaigns = 0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 검색을 실행하고 API를 재호출합
  void search(String query) {
    _searchQuery = query;
    fetchCampaigns(isNewSearch: true);
  }

  /// 정렬 기준을 변경하고 API를 재호출
  void setSortBy(String sort) {
    _sortBy = sort;
    fetchCampaigns(isNewSearch: true);
  }

  /// 페이지를 이동하고 API를 재호출
  void goToPage(int page) {
    if (page > 0 && page <= _totalPages && page != _currentPage) {
      _currentPage = page;
      fetchCampaigns();
    }
  }
}
