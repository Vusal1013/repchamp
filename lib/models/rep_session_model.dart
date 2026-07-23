class RepSession {
  final String? id;
  final String userId;
  final String exerciseType;
  final int repCount;
  final int? durationSeconds;
  final int xpEarned;
  final DateTime? createdAt;

  const RepSession({
    this.id,
    required this.userId,
    required this.exerciseType,
    required this.repCount,
    this.durationSeconds,
    this.xpEarned = 0,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'exercise_type': exerciseType,
      'rep_count': repCount,
      'duration_seconds': durationSeconds,
      'xp_earned': xpEarned,
    };
  }
}
