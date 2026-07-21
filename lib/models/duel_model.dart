class DuelRoom {
  final String id;
  final String status;
  final String exerciseType;
  final int durationSeconds;
  final DateTime? startTime;
  final String? winnerId;
  final DateTime createdAt;

  const DuelRoom({
    required this.id,
    required this.status,
    required this.exerciseType,
    this.durationSeconds = 60,
    this.startTime,
    this.winnerId,
    required this.createdAt,
  });

  factory DuelRoom.fromMap(Map<String, dynamic> map) {
    return DuelRoom(
      id: map['id'] as String,
      status: map['status'] as String,
      exerciseType: map['exercise_type'] as String,
      durationSeconds: map['duration_seconds'] as int? ?? 60,
      startTime: map['start_time'] != null
          ? DateTime.parse(map['start_time'] as String)
          : null,
      winnerId: map['winner_id'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

class DuelPlayer {
  final String id;
  final String roomId;
  final String userId;
  final int reps;
  final bool ready;
  final DateTime joinedAt;
  final String? username;
  final String? avatarUrl;

  const DuelPlayer({
    required this.id,
    required this.roomId,
    required this.userId,
    this.reps = 0,
    this.ready = false,
    required this.joinedAt,
    this.username,
    this.avatarUrl,
  });

  factory DuelPlayer.fromMap(Map<String, dynamic> map) {
    return DuelPlayer(
      id: map['id'] as String,
      roomId: map['room_id'] as String,
      userId: map['user_id'] as String,
      reps: map['reps'] as int? ?? 0,
      ready: map['ready'] as bool? ?? false,
      joinedAt: DateTime.parse(map['joined_at'] as String),
      username: map['username'] as String?,
      avatarUrl: map['avatar_url'] as String?,
    );
  }
}
