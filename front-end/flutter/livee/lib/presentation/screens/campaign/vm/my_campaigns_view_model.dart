import 'package:flutter/material.dart';
import 'package:livee/domain/models/campaign.dart';
import 'package:livee/domain/usecases/campaign_use_case.dart';
import 'package:livee/service_locator.dart';

/// '내 공고 목록' 화면의 상태와 비즈니스 로직
class MyCampaignsViewModel with ChangeNotifier {
  final CampaignUseCase _campaignUseCase = locator<CampaignUseCase>();

  // --- 상태 변수 ---
  bool _isLoading = true;
  List<Campaign> _campaigns = [];
  String? _errorMessage;

  // --- Getter ---
  bool get isLoading => _isLoading;
  List<Campaign> get campaigns => _campaigns;
  String? get errorMessage => _errorMessage;

  // 생성자: ViewModel이 생성될 때 데이터를 불러옴
  MyCampaignsViewModel() {
    fetchMyCampaigns();
  }

  /// 내가 등록한 공고 목록 조회
  Future<void> fetchMyCampaigns() async {
    _isLoading = true;
    notifyListeners(); // 로딩 시작을 UI에 알림
    try {
      _campaigns = await _campaignUseCase.getMyCampaigns();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = '공고를 불러오는 데 실패했습니다: $e';
      _campaigns = [];
    } finally {
      _isLoading = false;
      notifyListeners(); // 로딩 종료 및 결과(성공/실패)를 UI에 알림
    }
  }

  /// 특정 공고를 삭제
  Future<bool> deleteCampaign(String campaignId) async {
    try {
      await _campaignUseCase.deleteCampaign(campaignId);
      // 삭제 성공 후 목록을 다시 불러와서 UI를 갱신
      await fetchMyCampaigns();
      return true;
    } catch (e) {
      debugPrint('공고 삭제 실패: $e');
      // 실패 시 UI에 직접적인 에러 메시지 표시보다는 bool 값으로 실패 여부만 반환
      return false;
    }
  }
}
