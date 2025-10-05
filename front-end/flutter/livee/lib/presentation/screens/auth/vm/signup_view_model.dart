import 'package:flutter/material.dart';
import 'package:livee/data/core/api_error_parser.dart';
import 'package:livee/presentation/providers/auth_provider.dart';
import 'package:livee/presentation/common/custom_toast.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;

// SignupScreen의 상태와 비즈니스 로직을 관리
class SignupViewModel with ChangeNotifier {
  final BuildContext context;
  late final AuthProvider _authProvider;

  SignupViewModel(this.context) {
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
  }

  final formKey = GlobalKey<FormState>();

  // 공통 정보 컨트롤러
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmController = TextEditingController();
  final phoneController = TextEditingController();

  // 쇼호스트 전용 컨트롤러
  final nicknameController = TextEditingController();
  final snsLinkController = TextEditingController();
  final introController = TextEditingController();

  // 브랜드 전용 컨트롤러
  final brandNameController = TextEditingController();
  final companyNameController = TextEditingController();
  final businessNumberController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _selectedRole = 'showhost';
  String get selectedRole => _selectedRole;

  // 약관 동의 내부 상태 변수
  bool _serviceTermsConsent = false;
  bool _privacyPolicyConsent = false;
  bool _ageConsent = false;
  bool _marketingConsent = false;
  bool _thirdPartyConsent = false; //

  // UI에서 ViewModel의 상태 값을 읽을 수 있도록 public getter를 추가
  bool get serviceTermsConsent => _serviceTermsConsent;
  bool get privacyPolicyConsent => _privacyPolicyConsent;
  bool get ageConsent => _ageConsent;
  bool get marketingConsent => _marketingConsent;
  bool get thirdPartyConsent => _thirdPartyConsent;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setSelectedRole(String role) {
    _selectedRole = role;
    notifyListeners();
  }

  // 약관 동의 상태를 변경하는 메소드들
  void setServiceTermsConsent(bool? value) {
    _serviceTermsConsent = value ?? false;
    notifyListeners();
  }

  void setPrivacyPolicyConsent(bool? value) {
    _privacyPolicyConsent = value ?? false;
    notifyListeners();
  }

  void setAgeConsent(bool? value) {
    _ageConsent = value ?? false;
    notifyListeners();
  }

  void setMarketingConsent(bool? value) {
    _marketingConsent = value ?? false;
    notifyListeners();
  }

  void setThirdPartyConsent(bool? value) {
    _thirdPartyConsent = value ?? false;
    notifyListeners();
  }

  // 회원가입
  Future<void> signup() async {
    // Form 위젯의 유효성 검사를 통과하지 못하면 함수를 종료
    if (!formKey.currentState!.validate()) return;

    // 필수 약관 동의 여부를 역할 구분 없이 공통으로 확인
    if (!_serviceTermsConsent || !_privacyPolicyConsent || !_ageConsent) {
      showCustomToast(context, '필수 약관에 모두 동의해주세요.', type: ToastType.error);
      return;
    }

    _setLoading(true);
    try {
      // AuthProvider를 통해 실제 회원가입 API를 호출
      await _authProvider.signup(
        name: nameController.text,
        email: emailController.text,
        password: passwordController.text,
        role: _selectedRole,
        phone: phoneController.text,
        // 쇼호스트 정보
        nickname: nicknameController.text,
        snsLink: snsLinkController.text,
        introduction: introController.text,
        // 브랜드 정보
        brandName: brandNameController.text,
        companyName: companyNameController.text,
        businessNumber: businessNumberController.text,
      );

      // 성공 시 토스트 메시지를 보여주고 이전 페이지로 이동
      showCustomToast(context, '회원가입이 완료되었습니다.', type: ToastType.success);
      html.window.history.go(-1);
    } catch (e) {
      // 실패 시 에러 메시지를 파싱하여 토스트 보여주기
      showCustomToast(context, parseApiError(e), type: ToastType.error);
    } finally {
      // 성공/실패 여부와 관계없이 로딩 상태를 종료
      _setLoading(false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    passwordConfirmController.dispose();
    phoneController.dispose();
    nicknameController.dispose();
    snsLinkController.dispose();
    introController.dispose();
    brandNameController.dispose();
    companyNameController.dispose();
    businessNumberController.dispose();
    super.dispose();
  }
}
