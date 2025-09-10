import 'package:flutter/widgets.dart';
import 'package:livee/domain/models/campaign.dart';
import 'package:livee/domain/usecases/campaign_use_case.dart';
import 'package:livee/service_locator.dart';

class RecruitListProvider with ChangeNotifier {
  // locator를 통해 의존성을 직접 주입
  final CampaignUseCase _campaignUseCase = locator<CampaignUseCase>();

  // 생성자
  RecruitListProvider();

  bool _isLoading = false;
  List<Campaign> _filteredRecruits = [];

  //  검색, 정렬, 페이지네이션을 위한 상태 변수
  String _searchQuery = '';
  String _sortBy = 'latest'; // 'latest', 'deadline'
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalRecruits = 0;

  // Getter
  bool get isLoading => _isLoading;
  List<Campaign> get filteredRecruits => _filteredRecruits;
  int get totalRecruits => _totalRecruits;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  String get sortBy => _sortBy;

  // 모든 '쇼호스트 모집' 공고를 서버에서 불러오기
  Future<void> fetchRecruits({bool isNewSearch = false}) async {
    if (isNewSearch) {
      _currentPage = 1;
    }
    _isLoading = true;
    notifyListeners();
    try {
      // UseCase를 통해 새로운 API 호출
      final response = await _campaignUseCase.getAllCampaigns(
        type: 'recruit',
        limit: 10,
        page: _currentPage,
        search: _searchQuery,
        sort: _sortBy,
      );

      // API 응답 결과를 상태 변수에 반영
      _filteredRecruits = response.items;
      _totalRecruits = response.totalItems;
      _totalPages = response.totalPages;
      _currentPage = response.currentPage;
    } catch (e) {
      debugPrint('Error fetching recruits: $e');
      _filteredRecruits = []; // 에러 발생 시 목록을 비웁니다.
      _totalRecruits = 0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 검색 실행 시 검색어를 상태에 저장하고 API 재호출
  void search(String query) {
    _searchQuery = query;
    fetchRecruits(isNewSearch: true);
  }

  // 정렬 기준 변경 시 상태를 저장하고 API 재호출
  void setSortBy(String sort) {
    _sortBy = sort;
    fetchRecruits(isNewSearch: true);
  }

  // 페이지 이동 시 페이지 번호를 변경하고 API 재호출
  void goToPage(int page) {
    if (page > 0 && page <= _totalPages && page != _currentPage) {
      _currentPage = page;
      fetchRecruits();
    }
  }
}
