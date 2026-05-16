class Profile {
  final String id;
  final String username;
  final String? avatarUrl;
  final DateTime? updatedAt;

  Profile({
    required this.id,
    required this.username,
    this.avatarUrl,
    this.updatedAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      username: json['username'] ?? 'Usuario',
      avatarUrl: json['avatar_url'],
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'avatar_url': avatarUrl,
  };
}
