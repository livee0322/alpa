import 'package:flutter/material.dart';
import 'package:livee/domain/models/portfolio.dart';
import 'package:livee/domain/repositories/portfolio_repository.dart';
import 'package:livee/service_locator.dart';

/// '내 포트폴리오' 화면의 상태와 비즈니스 로직을 관리하는 ViewModel
class MyPortfoliosViewModel with ChangeNotifier {
  // 의존성 주입
  final PortfolioRepository _portfolioRepository = locator<PortfolioRepository>();

  // 상태 변수
  bool _isLoading = true;
  List<Portfolio> _portfolios = [];
  String? _errorMessage;

  // Getter
  bool get isLoading => _isLoading;
  List<Portfolio> get portfolios => _portfolios;
  String? get errorMessage => _errorMessage;

  // 생성자
  MyPortfoliosViewModel() {
    loadPortfolios(); // ViewModel이 생성될 때 포트폴리오 목록을 불러옴
  }

  /// 내 포트폴리오 목록을 서버에서 불러오는 메소드
  Future<void> loadPortfolios() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // 로딩 시작을 UI에 알림

    try {
      _portfolios = await _portfolioRepository.getMyPortfolioList();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners(); // 로딩 종료 및 결과(성공/실패)를 UI에 알림
    }
  }

  /// 특정 포트폴리오를 삭제하는 메소드
  Future<bool> deletePortfolio(String id) async {
    try {
      await _portfolioRepository.deletePortfolio(id);
      await loadPortfolios(); // 삭제 성공 후 목록을 다시 불러옴
      return true; // 성공 여부를 반환
    } catch (e) {
      debugPrint('포트폴리오 삭제 실패: $e');
      return false; // 실패 여부를 반환
    }
  }
}
