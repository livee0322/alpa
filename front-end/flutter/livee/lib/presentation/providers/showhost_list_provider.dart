import 'package:flutter/material.dart';
import 'package:livee/domain/models/portfolio.dart';
import 'package:livee/domain/repositories/portfolio_repository.dart';
import 'package:livee/service_locator.dart';

// '쇼호스트 목록' 화면의 상태를 관리하는 Provider
class ShowhostListProvider with ChangeNotifier {
  // locator를 통해 의존성을 직접 주입
  final PortfolioRepository _repository = locator<PortfolioRepository>();

  // 생성자
  ShowhostListProvider();

  bool _isLoading = false;
  List<Portfolio> _allShowhosts = [];
  List<Portfolio> _filteredShowhosts = [];

  bool get isLoading => _isLoading;
  List<Portfolio> get filteredShowhosts => _filteredShowhosts;

  // API를 통해 모든 쇼호스트 목록을 불러옵니다.
  Future<void> fetchShowhosts() async {
    _isLoading = true;
    notifyListeners();
    try {
      _allShowhosts = await _repository.getAllPublicPortfolios();
      _filteredShowhosts = _allShowhosts; // 초기에는 필터 없이 전체 목록 표시
    } catch (e) {
      // TODO: 에러 처리
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 선택된 필터에 따라 쇼호스트 목록을 필터링합니다.
  void applyFilter({String? category, String? fee}) {
    _filteredShowhosts = _allShowhosts.where((host) {
      final categoryMatch = category == null || category.isEmpty || host.category == category;
      // TODO: 출연료(fee) 필터 로직 추가
      return categoryMatch;
    }).toList();
    notifyListeners();
  }
}
