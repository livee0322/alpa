import 'package:flutter/material.dart';
import 'package:livee/data/core/api_error_parser.dart';
import 'package:livee/presentation/providers/auth_provider.dart';
import 'package:livee/presentation/widgets/custom_toast.dart';
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

  // UI에서 ViewModel의 상태 값을 읽을 수 있도록 public getter를 추가
  bool get serviceTermsConsent => _serviceTermsConsent;
  bool get privacyPolicyConsent => _privacyPolicyConsent;
  bool get ageConsent => _ageConsent;
  bool get marketingConsent => _marketingConsent;

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

  // 회원가입 로직을 처리
  Future<void> signup() async {
    if (!formKey.currentState!.validate()) return;

    if (_selectedRole == 'brand' && (!_serviceTermsConsent || !_privacyPolicyConsent)) {
      showCustomToast(context, '서비스 이용약관과 개인정보처리방침에 동의해주세요.', type: ToastType.error);
      return;
    }
    if (!_ageConsent) {
      showCustomToast(context, '만 14세 이상 필수 항목에 동의해주세요.', type: ToastType.error);
      return;
    }

    _setLoading(true);
    try {
      await _authProvider.signup(
        name: nameController.text,
        email: emailController.text,
        password: passwordController.text,
        role: _selectedRole,
        phone: phoneController.text,
        nickname: nicknameController.text,
        snsLink: snsLinkController.text,
        introduction: introController.text,
        brandName: brandNameController.text,
        companyName: companyNameController.text,
        businessNumber: businessNumberController.text,
      );

      showCustomToast(context, '회원가입이 완료되었습니다.', type: ToastType.success);
      html.window.history.go(-1);
    } catch (e) {
      showCustomToast(context, parseApiError(e), type: ToastType.error);
    } finally {
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
