class LoginRequestDto {
  const LoginRequestDto({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  factory LoginRequestDto.fromJson(Map<String, Object?> json) {
    return LoginRequestDto(
      email: json['email'] as String? ?? '',
      password: json['password'] as String? ?? '',
    );
  }

  Map<String, Object?> toJson() => {
        'email': email,
        'password': password,
      };
}
