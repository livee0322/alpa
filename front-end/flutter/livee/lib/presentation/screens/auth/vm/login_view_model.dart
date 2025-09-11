import 'package:flutter/material.dart';
import 'package:livee/data/core/api_error_parser.dart';
import 'package:livee/presentation/providers/auth_provider.dart';
import 'package:livee/presentation/widgets/custom_toast.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;

// LoginScreen의 상태와 비즈니스 로직을 모두 관리하는 ViewModel
class LoginViewModel with ChangeNotifier {
  // MARK: 의존성 주입 및 초기화
  final BuildContext context;
  late final AuthProvider _authProvider;

  /// 생성자: ViewModel이 생성될 때 BuildContext를 받아와 Provider에 접근할 수 있도록 준비
  LoginViewModel(this.context) {
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
  }

  // MARK: 상태 변수

  /// UI의 Form 위젯과 연결된 GlobalKey
  final formKey = GlobalKey<FormState>();

  /// 텍스트 입력 필드 컨트롤러
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  /// 로딩 상태 변수
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// 역할 선택 상태 변수 ('brand' 또는 'showhost')
  String _selectedRole = 'brand';
  String get selectedRole => _selectedRole;

  // MARK: 기능 함수

  /// 로딩 상태를 변경하고 UI에 변경사항을 알림
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// 사용자가 선택한 역할을 업데이트하고 UI에 변경사항을 알림
  void setSelectedRole(String role) {
    _selectedRole = role;
    notifyListeners();
  }

  /// 로그인을 시도하는 메인 로직
  Future<void> login() async {
    // Form의 유효성 검사를 통과하지 못하면 함수를 종료
    if (!formKey.currentState!.validate()) return;

    _setLoading(true);
    try {
      // AuthProvider를 통해 실제 로그인 로직을 실행
      await _authProvider.login(
        emailController.text,
        passwordController.text,
        _selectedRole,
      );
      // 성공 시 이전 페이지로 돌아가기
      html.window.history.go(-1);
    } catch (e) {
      // 실패 시 에러 토스트 메시지를 보여주기
      showCustomToast(
        context,
        parseApiError(e),
        type: ToastType.error,
      );
    } finally {
      // 성공/실패 여부와 관계없이 로딩 상태를 종료
      if (context.mounted) {
        _setLoading(false);
      }
    }
  }

  /// ViewModel이 소멸될 때 모든 컨트롤러의 리소스를 해제
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
