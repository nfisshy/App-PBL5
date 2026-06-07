import 'package:photomanager/features/auth/domain/auth_repository.dart';
import 'package:photomanager/features/auth/domain/auth_user.dart';

class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthUser?> call({
    required String email,
    required String password,
  }) {
    return _repository.login(
      email: email,
      password: password,
    );
  }
}
