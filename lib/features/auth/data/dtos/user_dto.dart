class UserDto {
  const UserDto({
    required this.email,
    required this.username,
  });

  final String email;
  final String username;

  factory UserDto.fromJson(Map<String, Object?> json) {
    return UserDto(
      email: json['email'] as String? ?? '',
      username: json['username'] as String? ?? '',
    );
  }

  Map<String, Object?> toJson() => {
        'email': email,
        'username': username,
      };
}
