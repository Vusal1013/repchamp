class UserProfile {
  final String id;
  final String username;
  final String? avatarUrl;
  final int level;
  final int xp;
  final int streak;
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    required this.username,
    this.avatarUrl,
    this.level = 1,
    this.xp = 0,
    this.streak = 0,
    required this.createdAt,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      username: map['username'] as String,
      avatarUrl: map['avatar_url'] as String?,
      level: map['level'] as int? ?? 1,
      xp: map['xp'] as int? ?? 0,
      streak: map['streak'] as int? ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'avatar_url': avatarUrl,
      'level': level,
      'xp': xp,
      'streak': streak,
    };
  }

  UserProfile copyWith({
    String? username,
    String? avatarUrl,
    int? level,
    int? xp,
    int? streak,
  }) {
    return UserProfile(
      id: id,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      streak: streak ?? this.streak,
      createdAt: createdAt,
    );
  }
}
