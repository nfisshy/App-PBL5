import 'package:photomanager/features/auth/domain/auth_user.dart';

abstract interface class AuthRepository {
  Future<AuthUser?> login({
    required String email,
    required String password,
  });
}
