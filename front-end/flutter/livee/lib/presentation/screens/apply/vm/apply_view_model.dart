// lib/presentation/screens/main/vm/apply_view_model.dart

import 'package:flutter/material.dart';
import 'package:livee/data/core/api_error_parser.dart';
import 'package:livee/domain/models/portfolio.dart';
import 'package:livee/domain/repositories/portfolio_repository.dart';
import 'package:livee/domain/usecases/application_use_case.dart';
import 'package:livee/service_locator.dart';

/// '지원하기' 바텀 시트의 상태와 비즈니스 로직을 관리하는 ViewModel
class ApplyViewModel with ChangeNotifier {
  // 의존성 주입
  final PortfolioRepository _portfolioRepository =
      locator<PortfolioRepository>();
  final ApplicationUseCase _applicationUseCase = locator<ApplicationUseCase>();

  // 상태 변수
  bool _isLoading = true;
  List<Portfolio> _userPortfolios = [];
  String? _errorMessage;
  String? _selectedPortfolioId;

  // Getter
  bool get isLoading => _isLoading;
  List<Portfolio> get userPortfolios => _userPortfolios;
  String? get errorMessage => _errorMessage;
  String? get selectedPortfolioId => _selectedPortfolioId;

  // 생성자
  ApplyViewModel() {
    _loadMyPortfolios(); // ViewModel 생성 시 포트폴리오 목록 로딩
  }

  /// '내 포트폴리오 목록' API를 호출하여 데이터를 불러오는 메소드
  Future<void> _loadMyPortfolios() async {
    _isLoading = true;
    notifyListeners();
    try {
      _userPortfolios = await _portfolioRepository.getMyPortfolioList();
      // 목록이 있으면 첫 번째 포트폴리오를 기본으로 선택
      if (_userPortfolios.isNotEmpty) {
        _selectedPortfolioId = _userPortfolios.first.id;
      }
    } catch (e) {
      _errorMessage = '포트폴리오를 불러오는 데 실패했습니다.';
      debugPrint(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 사용자가 선택한 포트폴리오 ID를 업데이트하는 메소드
  void selectPortfolio(String? portfolioId) {
    if (_selectedPortfolioId != portfolioId) {
      _selectedPortfolioId = portfolioId;
      notifyListeners();
    }
  }

  /// '지원 보내기' 로직을 처리하는 메소드
  Future<String?> submitApplication(String campaignId, String message) async {
    if (_selectedPortfolioId == null) {
      return '포트폴리오를 선택해주세요.'; // 에러 메시지를 직접 반환
    }

    try {
      await _applicationUseCase.applyToCampaign(
        campaignId: campaignId,
        portfolioId: _selectedPortfolioId!,
        message: message,
      );
      debugPrint('지원 완료! ...');
      return null; // 성공 시 null 반환
    } catch (e) {
      final errorMessage = parseApiError(e);
      debugPrint(errorMessage);
      return errorMessage; // 실패 시 파싱된 에러 메시지를 반환
    }
  }
}
