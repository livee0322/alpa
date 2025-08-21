import 'package:flutter/widgets.dart';
import 'package:livee/domain/models/campaign.dart';
import 'package:livee/domain/usecases/campaign_use_case.dart';

class RecruitListProvider with ChangeNotifier {
  final CampaignUseCase _campaignUseCase;

  RecruitListProvider(this._campaignUseCase);

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
      _allRecruits =
          await _campaignUseCase.getAllCampaigns(type: 'recruit', limit: 100);
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
        filtered.retainWhere((c) {
          final date = c.recruit?.date != null
              ? DateTime.tryParse(c.recruit!.date!)
              : null;
          return date != null &&
              date.isAfter(today.subtract(const Duration(days: 1)));
        });
        filtered.sort((a, b) =>
            (DateTime.tryParse(a.recruit!.date!) ?? DateTime(0))
                .compareTo(DateTime.tryParse(b.recruit!.date!) ?? DateTime(0)));
        break;
      case 'mukbang':
        filtered.retainWhere((c) =>
            '${c.title} ${c.recruit?.description} ${c.recruit?.category}'
                .toLowerCase()
                .contains(RegExp(r'먹방|food|mukbang')));
        break;
      case 'beauty':
        filtered.retainWhere((c) =>
            '${c.title} ${c.recruit?.description} ${c.recruit?.category}'
                .toLowerCase()
                .contains(RegExp(r'뷰티|beauty|메이크업|코스메틱')));
        break;
      case 'pay':
        filtered.sort((a, b) {
          final payA = _extractPay(a.recruit?.pay);
          final payB = _extractPay(b.recruit?.pay);
          return payB.compareTo(payA);
        });
        break;
    }

    _filteredRecruits = filtered;
    notifyListeners();
  }

  // '30만원' 같은 문자열에서 숫자 값 추출
  int _extractPay(String? payString) {
    if (payString == null) return 0;
    var numString = payString.replaceAll(RegExp(r'[^0-9]'), '');
    var pay = int.tryParse(numString) ?? 0;
    if (payString.contains('만원')) {
      pay *= 10000;
    }
    return pay;
  }
}
