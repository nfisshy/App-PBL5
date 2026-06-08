class ContactDto {
  const ContactDto({
    required this.username,
    required this.displayName,
  });

  final String username;
  final String displayName;

  factory ContactDto.fromJson(Map<String, Object?> json) {
    return ContactDto(
      username: json['username'] as String? ?? '',
      displayName: json['display_name'] as String? ??
          json['displayName'] as String? ??
          '',
    );
  }

  Map<String, Object?> toJson() => {
        'username': username,
        'display_name': displayName,
      };
}
