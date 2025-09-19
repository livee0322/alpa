import 'package:flutter/material.dart';
import 'package:livee/domain/models/portfolio.dart';
import 'package:livee/domain/repositories/portfolio_repository.dart';
import 'package:livee/service_locator.dart';

/// '포트폴리오 상세' 페이지의 상태와 로직을 관리하는 ViewModel
class PortfolioDetailViewModel with ChangeNotifier {
  final PortfolioRepository _portfolioRepository = locator<PortfolioRepository>();
  final String portfolioId;

  PortfolioDetailViewModel({required this.portfolioId}) {
    fetchPortfolioDetail();
  }

  bool _isLoading = true;
  Portfolio? _portfolio;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  Portfolio? get portfolio => _portfolio;
  String? get errorMessage => _errorMessage;

  Future<void> fetchPortfolioDetail() async {
    _isLoading = true;
    notifyListeners();
    try {
      _portfolio = await _portfolioRepository.getPortfolioById(portfolioId);
    } catch (e) {
      _errorMessage = '포트폴리오 정보를 불러오는 데 실패했습니다.';
      debugPrint(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
