import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photomanager/features/auth/data/mock_auth_repository.dart';
import 'package:photomanager/features/auth/domain/auth_repository.dart';
import 'package:photomanager/features/auth/domain/auth_user.dart';
import 'package:photomanager/features/auth/domain/login_use_case.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return MockAuthRepository();
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref.watch(loginUseCaseProvider));
});

class AuthState {
  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  final AuthUser? user;
  final bool isLoading;
  final String? errorMessage;
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._loginUseCase) : super(const AuthState());

  final LoginUseCase _loginUseCase;

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = const AuthState(isLoading: true);

    try {
      final user = await _loginUseCase(
        email: email,
        password: password,
      );

      if (user == null) {
        state = const AuthState(
          errorMessage: 'Invalid email or password.',
        );
        return false;
      }

      state = AuthState(user: user);
      return true;
    } on Exception {
      state = const AuthState(
        errorMessage: 'Unable to sign in. Please try again.',
      );
      return false;
    }
  }

  void clearError() {
    state = AuthState(user: state.user);
  }
}
