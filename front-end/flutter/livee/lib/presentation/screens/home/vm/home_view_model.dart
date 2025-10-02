import 'package:flutter/material.dart';
import 'package:livee/domain/models/campaign.dart';
import 'package:livee/domain/models/clip.dart';
import 'package:livee/domain/models/model.dart';
import 'package:livee/domain/models/news.dart';
import 'package:livee/domain/models/paginated_response.dart';
import 'package:livee/domain/models/portfolio.dart';
import 'package:livee/domain/repositories/portfolio_repository.dart';
import 'package:livee/domain/usecases/campaign_use_case.dart';
import 'package:livee/domain/usecases/clip_use_case.dart';
import 'package:livee/domain/usecases/model_use_case.dart';
import 'package:livee/domain/usecases/news_use_case.dart';
import 'package:livee/service_locator.dart';

/// 홈 화면의 상태와 비즈니스 로직을 관리하는 ViewModel
class HomeViewModel with ChangeNotifier {
  // 의존성 주입
  final CampaignUseCase _campaignUseCase = locator<CampaignUseCase>();
  final PortfolioRepository _portfolioRepository =
      locator<PortfolioRepository>();
  final ModelUseCase _modelUseCase = locator<ModelUseCase>();
  final NewsUseCase _newsUseCase = locator<NewsUseCase>();
  final ClipUseCase _clipUseCase = locator<ClipUseCase>();

  // 상태 변수
  bool _isLoading = true;
  List<Campaign> _schedules = [];
  List<Campaign> _recruits = [];
  List<Portfolio> _featuredShowhosts = [];
  List<Model> _conceptModels = [];
  List<News> _news = [];
  List<Clip> _hotClips = [];
  String? _errorMessage;

  // Getter
  bool get isLoading => _isLoading;
  List<Campaign> get schedules => _schedules;
  List<Campaign> get recruits => _recruits;
  List<Portfolio> get featuredShowhosts => _featuredShowhosts;
  List<Model> get conceptModels => _conceptModels;
  List<News> get news => _news;
  List<Clip> get hotClips => _hotClips;
  String? get errorMessage => _errorMessage;

  // 생성자
  HomeViewModel() {
    loadData(); // ViewModel 생성 시 데이터 로딩 시작
  }

  // 페이지에 필요한 모든 데이터를 한 번에 불러오는 메소드
  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 여러 API를 동시에 호출하여 성능 향상
      final results = await Future.wait([
        _campaignUseCase.getAllCampaigns(type: 'recruit', limit: 6),
        _campaignUseCase.getAllCampaigns(type: 'recruit', limit: 10),
        _portfolioRepository.getPublicPortfolios(limit: 2),
        _modelUseCase.getAllModels(limit: 5),
        _newsUseCase.getNewsList(limit: 2),
        _clipUseCase.getClips(),
        // NewsRepository는 현재 목업 데이터를 사용하므로 동시 호출에서 제외
      ]);

      _schedules = (results[0] as PaginatedResponse<Campaign>).items;
      _recruits = (results[1] as PaginatedResponse<Campaign>).items;
      _featuredShowhosts = results[2] as List<Portfolio>;
      _conceptModels = (results[3] as PaginatedResponse<Model>).items;
      _news = (results[4] as PaginatedResponse<News>).items;
      _hotClips = (results[5] as List<Clip>).take(3).toList();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners(); // UI에 데이터 로딩 완료를 알림
    }
  }
}
