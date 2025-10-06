import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/domain/models/campaign.dart';
import 'package:livee/domain/usecases/campaign_use_case.dart';
import 'package:livee/presentation/common/vm/detail_view_model_base.dart';
import 'package:livee/presentation/providers/auth_provider.dart';
import 'package:livee/presentation/common/common_prompt_dialog.dart';
import 'package:livee/presentation/common/custom_toast.dart';
import 'package:livee/service_locator.dart';
import 'package:provider/provider.dart';

// CampaignDetailScreen의 상태와 비즈니스 로직을 모두 관리
class CampaignDetailViewModel extends DetailViewModelBase<Campaign> {
  // MARK: 의존성 주입 및 초기화
  final CampaignUseCase _campaignUseCase = locator<CampaignUseCase>();
  final BuildContext context;
  late final AuthProvider _authProvider;

  /// 생성자: ViewModel이 생성될 때 BuildContext와 campaignId를 받아와 데이터 로딩을 시작
  CampaignDetailViewModel(this.context, {required String campaignId}) {
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    // [수정] 부모 클래스의 loadItem 메소드를 호출
    loadItem(campaignId);
  }

  /// 서버에서 캠페인 상세 데이터를 불러오기
  @override
  Future<Campaign> fetchItem(String id) {
    return _campaignUseCase.getCampaignById(id);
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
      if (result == true && context.mounted) context.go('/login');
    } else if (_authProvider.role == 'showhost') {
      // 쇼호스트일 경우: 성공 토스트 및 홈으로 이동
      // TODO: 실제 지원 API 연동 필요
      showCustomToast(context, '성공적으로 지원되었습니다.', type: ToastType.success);
      // history를 모두 지우고 홈으로 이동
      context.go('/');
    }
  }
}
