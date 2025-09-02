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
  List<Campaign> _allRecruits = [];
  List<Campaign> _filteredRecruits = [];
  String _activeFilter = 'deadline'; // 기본 필터

  // Getter
  bool get isLoading => _isLoading;
  List<Campaign> get filteredRecruits => _filteredRecruits;
  String get activeFilter => _activeFilter;

  // 모든 '쇼호스트 모집' 공고를 서버에서 불러오기
  Future<void> fetchRecruits() async {
    _isLoading = true;
    notifyListeners();
    try {
      // type='recruit'인 캠페인을 100개까지 넉넉하게 불러오기
      _allRecruits = await _campaignUseCase.getAllCampaigns(type: 'recruit', limit: 100);
      // 초기 필터('deadline')를 적용
      applyFilter(_activeFilter);
    } catch (e) {
      debugPrint('Error fetching recruits: $e');
      // TODO: 사용자에게 에러 메시지 표시
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 지정된 필터 키에 따라 공고 목록을 필터링
  void applyFilter(String filterKey) {
    _activeFilter = filterKey;
    List<Campaign> filtered = List.from(_allRecruits); // 원본 리스트 복사

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 필터 로직
    switch (filterKey) {
      case 'deadline':
        // 마감일(closeAt) 기준으로 필터링 및 정렬
        filtered.retainWhere((c) {
          final date = c.closeAt != null ? DateTime.tryParse(c.closeAt!) : null;
          return date != null && date.isAfter(today.subtract(const Duration(days: 1)));
        });
        filtered.sort((a, b) => (DateTime.tryParse(a.closeAt!) ?? DateTime(9999))
            .compareTo(DateTime.tryParse(b.closeAt!) ?? DateTime(9999)));
        break;
      case 'mukbang':
        // 제목, 설명, 카테고리에 '먹방' 관련 키워드가 있는지 확인
        filtered.retainWhere(
            (c) => '${c.title} ${c.descriptionHTML} ${c.category}'.toLowerCase().contains(RegExp(r'먹방|food|mukbang')));
        break;
      case 'beauty':
        filtered.retainWhere((c) =>
            '${c.title} ${c.descriptionHTML} ${c.category}'.toLowerCase().contains(RegExp(r'뷰티|beauty|메이크업|코스메틱')));
        break;
      case 'pay':
        // 출연료(fee) 기준으로 내림차순 정렬
        filtered.sort((a, b) {
          final payA = a.fee ?? 0;
          final payB = b.fee ?? 0;
          return payB.compareTo(payA);
        });
        break;
    }

    _filteredRecruits = filtered;
    notifyListeners();
  }
}
