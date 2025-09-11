import 'package:flutter/material.dart';
import 'package:livee/domain/models/campaign.dart';
import 'package:livee/domain/models/paginated_response.dart';
import 'package:livee/domain/models/portfolio.dart';
import 'package:livee/domain/repositories/portfolio_repository.dart';
import 'package:livee/domain/usecases/campaign_use_case.dart';
import 'package:livee/service_locator.dart';

/// 메인 화면의 상태와 비즈니스 로직을 관리하는 ViewModel
class MainViewModel with ChangeNotifier {
  // 의존성 주입
  final CampaignUseCase _campaignUseCase = locator<CampaignUseCase>();
  final PortfolioRepository _portfolioRepository = locator<PortfolioRepository>();

  // 상태 변수
  bool _isLoading = true;
  List<Campaign> _schedules = [];
  List<Campaign> _recruits = [];
  List<Portfolio> _featuredShowhosts = [];
  String? _errorMessage;

  // Getter
  bool get isLoading => _isLoading;
  List<Campaign> get schedules => _schedules;
  List<Campaign> get recruits => _recruits;
  List<Portfolio> get featuredShowhosts => _featuredShowhosts;
  String? get errorMessage => _errorMessage;

  // 생성자
  MainViewModel() {
    loadData(); // ViewModel 생성 시 데이터 로딩 시작
  }

  /// 페이지에 필요한 모든 데이터를 한 번에 불러오는 메소드
  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 여러 API를 동시에 호출하여 성능 향상
      final results = await Future.wait([
        _campaignUseCase.getAllCampaigns(type: 'product', limit: 6),
        _campaignUseCase.getAllCampaigns(type: 'recruit', limit: 10),
        _portfolioRepository.getPublicPortfolios(limit: 5),
        // NewsRepository는 현재 목업 데이터를 사용하므로 동시 호출에서 제외
      ]);

      _schedules = (results[0] as PaginatedResponse<Campaign>).items;
      _recruits = (results[1] as PaginatedResponse<Campaign>).items;
      _featuredShowhosts = results[2] as List<Portfolio>;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners(); // UI에 데이터 로딩 완료를 알림
    }
  }
}
