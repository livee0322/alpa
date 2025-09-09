import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/domain/models/campaign.dart';
import 'package:livee/domain/usecases/campaign_use_case.dart';
import 'package:livee/presentation/providers/auth_provider.dart';
import 'package:livee/presentation/widgets/common_prompt_dialog.dart';
import 'package:livee/presentation/widgets/custom_toast.dart';
import 'package:livee/service_locator.dart';
import 'package:provider/provider.dart';

// CampaignDetailScreen의 상태와 비즈니스 로직을 모두 관리하는 ViewModel
class CampaignDetailViewModel with ChangeNotifier {
  // MARK: 의존성 주입 및 초기화
  final CampaignUseCase _campaignUseCase = locator<CampaignUseCase>();
  final String campaignId;
  final BuildContext context;
  late final AuthProvider _authProvider;

  /// 생성자: ViewModel이 생성될 때 BuildContext와 campaignId를 받아와 데이터 로딩을 시작합니다.
  CampaignDetailViewModel(this.context, {required this.campaignId}) {
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _loadCampaign();
  }

  // MARK: 상태 변수

  /// 로딩 상태 변수
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  /// 불러온 캠페인 데이터를 저장하는 변수
  Campaign? _campaign;
  Campaign? get campaign => _campaign;

  /// 에러 메시지를 저장하는 변수
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // MARK:  기능 함수

  /// 로딩 상태를 변경하고 UI에 변경사항을 알림
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// 서버에서 캠페인 상세 데이터를 불러오기
  Future<void> _loadCampaign() async {
    _setLoading(true);
    try {
      final campaignData = await _campaignUseCase.getCampaignById(campaignId);
      _campaign = campaignData;
    } catch (e) {
      _errorMessage = '공고 정보를 불러오거나 볼 수 있는 권한이 없습니다.';
    } finally {
      _setLoading(false);
    }
  }

  /// '지원하기' 버튼 클릭 로직을 처리
  void handleApply() async {
    if (!_authProvider.isLoggedIn) {
      // 비회원일 경우: 로그인 유도 팝업

      final result = await showCommonPromptDialog(
        context: context,
        title: '로그인이 필요합니다',
        content: '회원 전용 서비스입니다.\n로그인 하시겠습니까?',
        confirmText: '로그인',
      );
      if (result == true && context.mounted) {
        GoRouter.of(context).go('/login');
      }
    } else if (_authProvider.role == 'showhost') {
      // 쇼호스트일 경우: 성공 토스트 및 홈으로 이동
      // TODO: 실제 지원 API 연동 필요
      showCustomToast(context, '성공적으로 지원되었습니다.', type: ToastType.success);
      // history를 모두 지우고 홈으로 이동
      GoRouter.of(context).go('/');
    }
  }
}
