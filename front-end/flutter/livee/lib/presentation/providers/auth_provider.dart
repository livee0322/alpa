import 'package:flutter/material.dart';
import 'package:livee/domain/models/user.dart';
import 'package:livee/domain/usecases/auth_use_case.dart';

class AuthProvider with ChangeNotifier {
  final AuthUseCase _authUseCase;

  bool _isLoggedIn = false;
  User? _user;
  String? _role;

  AuthProvider(this._authUseCase) {
    _checkInitialLoginStatus();
  }

  bool get isLoggedIn => _isLoggedIn;
  User? get user => _user;
  String? get role => _role;

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

  Future<void> login(String email, String password) async {
    try {
      final loggedInUser = await _authUseCase.login(email, password);
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
