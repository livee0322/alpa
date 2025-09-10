import 'package:flutter/material.dart';
import 'package:livee/domain/models/user.dart';
import 'package:livee/domain/usecases/auth_use_case.dart';
import 'package:livee/service_locator.dart';

class AuthProvider with ChangeNotifier {
  // locator를 통해 의존성을 직접 주입
  final AuthUseCase _authUseCase = locator<AuthUseCase>();

  bool _isLoggedIn = false;
  User? _user;
  String? _role;

  // 생성자
  AuthProvider() {
    _checkInitialLoginStatus();
  }

  bool get isLoggedIn => _isLoggedIn;
  User? get user => _user;
  String? get role => _role;

  // 현재 사용자의 역할에 따라 버튼 텍스트를 반환하는 getter
  String get recruitButtonText {
    // 로그아웃 상태이거나 역할 정보가 없으면 '지원하기'
    if (!_isLoggedIn || _role == null) {
      return '지원하기';
    }
    // 역할에 따라 텍스트 분기
    switch (_role) {
      case 'showhost':
        return '지원하기';
      case 'brand':
        return '지원현황';
      default:
        return '지원하기'; // 비회원 및 기타 역할
    }
  }

  Future<void> _checkInitialLoginStatus() async {
    final token = await _authUseCase.getAuthToken();
    if (token != null) {
      _isLoggedIn = true;
      _role = await _authUseCase.getUserRole();
      // TODO: 서버에서 사용자 정보(이름, 이메일 등)를 가져오는 로직 추가
      _user = User(name: '사용자', role: _role);
    }
    notifyListeners();
  }

  Future<void> login(String email, String password, String role) async {
    try {
      final loggedInUser = await _authUseCase.login(email, password, role);
      _user = loggedInUser;
      _role = loggedInUser.role;
      _isLoggedIn = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Login failed: $e');
      rethrow;
    }
  }

  Future<void> signup(String name, String email, String password, String role) async {
    try {
      await _authUseCase.signup(name, email, password, role);
    } catch (e) {
      debugPrint('Signup failed: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    await _authUseCase.logout();
    _isLoggedIn = false;
    _user = null;
    _role = null;
    notifyListeners();
  }
}
