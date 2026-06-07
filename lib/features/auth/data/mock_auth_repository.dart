import 'package:photomanager/features/auth/domain/auth_repository.dart';
import 'package:photomanager/features/auth/domain/auth_user.dart';

class MockAuthRepository implements AuthRepository {
  static const _validEmail = 'admin@test.com';
  static const _validPassword = '123456';

  @override
  Future<AuthUser?> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    if (email.trim().toLowerCase() != _validEmail ||
        password != _validPassword) {
      return null;
    }

    return const AuthUser(
      email: _validEmail,
      username: 'Admin',
    );
  }
}
