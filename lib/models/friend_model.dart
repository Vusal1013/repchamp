enum FriendStatus { pending, accepted, blocked }

class FriendUser {
  final String id;
  final String username;
  final String? avatarUrl;
  final int level;
  final int totalReps;
  final bool isOnline;

  const FriendUser({
    required this.id,
    required this.username,
    this.avatarUrl,
    this.level = 1,
    this.totalReps = 0,
    this.isOnline = false,
  });
}

class FriendRequest {
  final String id;
  final String fromUserId;
  final String toUserId;
  final String? fromUsername;
  final DateTime createdAt;
  final FriendStatus status;

  const FriendRequest({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    this.fromUsername,
    required this.createdAt,
    this.status = FriendStatus.pending,
  });
}

class FriendRelation {
  final FriendUser user;
  final FriendStatus status;
  final DateTime? since;

  const FriendRelation({
    required this.user,
    required this.status,
    this.since,
  });
}
