import 'package:livee/domain/models/user.dart';
import 'package:livee/domain/repositories/auth_repository.dart';

class AuthUseCase {
  final AuthRepository _repository;

  AuthUseCase(this._repository);

  Future<User> login(String email, String password, String role) async {
    return _repository.login(email, password, role);
  }

  // 회원가입을 처리
  Future<User> signup({
    required String name,
    required String email,
    required String password,
    required String role,
    String? phone,
    // 쇼호스트 정보
    String? nickname,
    String? snsLink,
    String? introduction,
    // 브랜드 정보
    String? brandName,
    String? companyName,
    String? businessNumber,
  }) async {
    return _repository.signup(
      name: name,
      email: email,
      password: password,
      role: role,
      phone: phone,
      nickname: nickname,
      snsLink: snsLink,
      introduction: introduction,
      brandName: brandName,
      companyName: companyName,
      businessNumber: businessNumber,
    );
  }

  Future<void> logout() async {
    return _repository.logout();
  }

  Future<String?> getAuthToken() async {
    return _repository.getAuthToken();
  }

  Future<String?> getUserRole() async {
    return _repository.getUserRole();
  }
}
