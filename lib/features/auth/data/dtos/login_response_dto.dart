import 'package:photomanager/features/auth/data/dtos/user_dto.dart';

class LoginResponseDto {
  const LoginResponseDto({required this.user});

  final UserDto user;

  factory LoginResponseDto.fromJson(Map<String, Object?> json) {
    final userJson = json['user'];
    return LoginResponseDto(
      user: UserDto.fromJson(
        userJson is Map<String, Object?> ? userJson : json,
      ),
    );
  }

  Map<String, Object?> toJson() => {'user': user.toJson()};
}
