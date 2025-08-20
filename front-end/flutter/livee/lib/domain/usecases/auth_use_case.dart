import 'package:livee/domain/models/user.dart';
import 'package:livee/domain/repositories/auth_repository.dart';

class AuthUseCase {
  final AuthRepository _repository;

  AuthUseCase(this._repository);

  Future<User> login(String email, String password) async {
    return _repository.login(email, password);
  }

  Future<User> signup(String name, String email, String password, String role) async {
    return _repository.signup(name, email, password, role);
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
