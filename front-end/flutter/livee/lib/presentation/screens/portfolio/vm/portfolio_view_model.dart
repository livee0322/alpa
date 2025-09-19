import 'package:flutter/material.dart';
import 'package:livee/domain/models/portfolio.dart';
import 'package:livee/domain/repositories/portfolio_repository.dart';
import 'package:livee/service_locator.dart';

/// '포트폴리오' 목록 화면의 상태와 로직을 관리하는 ViewModel
class PortfolioViewModel with ChangeNotifier {
  final PortfolioRepository _portfolioRepository = locator<PortfolioRepository>();

  PortfolioViewModel() {
    fetchPortfolios(); // ViewModel 생성 시 데이터를 불러옵니다.
  }

  // --- 상태 변수 ---
  bool _isLoading = true;
  List<Portfolio> _portfolios = [];
  String _searchQuery = '';
  String _sortBy = '최신순';

  // --- Getter ---
  bool get isLoading => _isLoading;
  List<Portfolio> get portfolios => _portfolios;

  /// 서버에서 전체 공개 포트폴리오 목록을 불러오는 메소드
  Future<void> fetchPortfolios() async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: 백엔드 API에 검색(searchQuery) 및 정렬(sortBy) 기능이 추가되면 파라미터로 전달해야 합니다.
      _portfolios = await _portfolioRepository.getAllPublicPortfolios();
    } catch (e) {
      debugPrint('Error fetching portfolios: $e');
      _portfolios = []; // 에러 발생 시 목록을 비웁니다.
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 검색어를 업데이트하고 목록을 다시 불러오는 메소드
  void search(String query) {
    _searchQuery = query;
    fetchPortfolios();
    notifyListeners();
  }

  /// 정렬 기준을 업데이트하고 목록을 다시 불러오는 메소드
  void setSortBy(String? sortValue) {
    if (sortValue != null) {
      _sortBy = sortValue;
      fetchPortfolios();
      notifyListeners();
    }
  }
}
