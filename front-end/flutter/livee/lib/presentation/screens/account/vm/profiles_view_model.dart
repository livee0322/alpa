import 'package:flutter/material.dart';

/// '프로필 설정' 화면의 상태와 비즈니스 로직을 관리
class ProfilesViewModel with ChangeNotifier {
  // --- 상태 변수 ---

  // 수정 모드 여부
  bool _isEditing = false;
  bool get isEditing => _isEditing;

  // 로딩 상태
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // 프로필 정보 컨트롤러
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  // --- 알림 설정 값 ---
  // 채널
  bool useKakaoAlert = false;
  bool useSiteAlert = false;

  // 공고/계약 (카카오톡)
  bool newCampaignKakao = false;
  bool proposalKakao = false;
  bool applicationResultKakao = false;
  bool contractConfirmationKakao = false;
  bool contractChangeKakao = false;

  // 공고/계약 (라이비)
  bool newCampaignLivee = false;
  bool proposalLivee = false;
  bool applicationResultLivee = false;
  bool contractConfirmationLivee = false;
  bool contractChangeLivee = false;

  // 일정/촬영 (카카오톡)
  bool reminderBeforeDayKakao = false;
  bool reminderBeforeHourKakao = false;
  bool scheduleChangeKakao = false;

  // 일정/촬영 (라이비)
  bool reminderBeforeDayLivee = false;
  bool reminderBeforeHourLivee = false;
  bool scheduleChangeLivee = false;

  // 메시지/소통 (카카오톡 & 라이비)
  bool newMessageKakao = false;
  bool newMessageLivee = false;

  // 운영자 공지 (카카오톡 & 라이비)
  bool adminNoticeKakao = false;
  bool adminNoticeLivee = false;

  // 정산/금전 (카카오톡 & 라이비)
  bool paymentCompleteKakao = false;
  bool paymentCompleteLivee = false;

  // --- 생성자 ---
  ProfilesViewModel() {
    loadProfile(); // ViewModel 생성 시 기존 프로필 정보를 불러오기
  }

  /// 서버에서 현재 사용자의 프로필 및 알림 설정
  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();

    // TODO: API 연동 - 서버에서 사용자 정보 로딩
    // --- 임시 목업 데이터 ---
    await Future.delayed(const Duration(milliseconds: 500)); // 로딩 시뮬레이션
    nameController.text = "김라이비";
    phoneController.text = "01012345678";
    useKakaoAlert = true;
    useSiteAlert = true;
    newCampaignLivee = true;
    proposalKakao = true;
    // ... (모든 설정 값 초기화)
    // --- --------------- ---
    _isLoading = false;
    notifyListeners(); // UI 갱신
  }

  /// '수정'/'저장' 버튼 클릭 시 호출되는 메소드
  Future<void> toggleEditMode() async {
    if (_isEditing) {
      // '저장' 모드일 때
      await saveProfile();
    }
    // 모드를 전환합니다 (수정 -> 보기, 보기 -> 수정).
    _isEditing = !_isEditing;
    notifyListeners();
  }

  /// 변경된 프로필 정보를 서버에 저장하는 메소드
  Future<void> saveProfile() async {
    _isLoading = true;
    notifyListeners();
    // TODO: API 연동 - 변경된 프로필 정보 및 알림 설정을 서버에 전송
    await Future.delayed(const Duration(seconds: 1)); // 저장 시뮬레이션
    print('--- 저장될 데이터 ---');
    print('이름: ${nameController.text}');
    print('전화번호: ${phoneController.text}');
    print('카카오톡 채널 알림: $useKakaoAlert');
    print('사이트 내 알림: $useSiteAlert');
    print('신규 공고(라이비): $newCampaignLivee');
    // ... (모든 설정 값 출력)
    print('--------------------');
    _isLoading = false;
    // notifyListeners()는 toggleEditMode에서 호출되므로 여기서는 생략
  }

  // 각 알림 설정 스위치의 값을 변경하는 메소드들
  void setBoolValue(Function(bool) setter, bool value) {
    if (!_isEditing) return; // 수정 모드가 아닐 때는 변경 불가
    setter(value);
    notifyListeners();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}
