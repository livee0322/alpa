import 'package:flutter/material.dart';
import 'package:livee/presentation/providers/auth_provider.dart';
import 'package:livee/presentation/widgets/custom_toast.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;

// SignupScreen의 상태와 비즈니스 로직을 모두 관리하는 ViewModel
class SignupViewModel with ChangeNotifier {
  // --- 의존성 주입 및 초기화 ---
  final BuildContext context;
  late final AuthProvider _authProvider;

  /// 생성자: ViewModel이 생성될 때 BuildContext를 받아와 Provider에 접근할 수 있도록 준비
  SignupViewModel(this.context) {
    // listen: false로 설정하여, UI 리빌드를 유발하지 않고 AuthProvider의 기능만 사용
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
  }

  // MARK: 상태 변수

  /// UI의 Form 위젯과 연결된 GlobalKey
  final formKey = GlobalKey<FormState>();

  /// 텍스트 입력 필드 컨트롤러
  final nicknameController = TextEditingController();
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

  /// 회원가입을 시도하는 메인 로직
  Future<void> signup() async {
    // Form의 유효성 검사를 통과하지 못하면 함수를 종료
    if (!formKey.currentState!.validate()) return;

    _setLoading(true);
    try {
      // AuthProvider를 통해 실제 회원가입 로직을 실행
      await _authProvider.signup(
        nicknameController.text,
        emailController.text,
        passwordController.text,
        _selectedRole,
      );

      // 성공 시 토스트 메시지를 보여주고 이전 페이지로 돌아가기
      showCustomToast(context, '회원가입이 완료되었습니다.', type: ToastType.success);
      html.window.history.go(-1);
    } catch (e) {
      // 실패 시 에러 토스트 메시지를 보여주기
      showCustomToast(
        context,
        e.toString().replaceFirst('Exception: ', ''),
        type: ToastType.error,
      );
    } finally {
      // 성공/실패 여부와 관계없이 로딩 상태를 종료
      _setLoading(false);
    }
  }

  /// ViewModel이 소멸될 때 모든 컨트롤러의 리소스를 해제
  @override
  void dispose() {
    nicknameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
