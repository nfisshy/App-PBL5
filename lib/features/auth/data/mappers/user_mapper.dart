import 'package:photomanager/features/auth/data/dtos/user_dto.dart';
import 'package:photomanager/features/auth/domain/auth_user.dart';

extension UserDtoMapper on UserDto {
  AuthUser toDomain() => AuthUser(email: email, username: username);
}

extension AuthUserMapper on AuthUser {
  UserDto toDto() => UserDto(email: email, username: username);
}
