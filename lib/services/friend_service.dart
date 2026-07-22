import '../models/friend_model.dart';

class FriendService {
  final List<FriendRelation> _friends = [];
  final List<FriendRequest> _requests = [];
  final List<FriendUser> _searchResults = [];

  List<FriendRelation> get friends => _friends;
  List<FriendRequest> get pendingRequests =>
      _requests.where((r) => r.status == FriendStatus.pending).toList();

  void sendRequest(String fromUserId, String toUserId, {String? fromUsername}) {
    _requests.add(FriendRequest(
      id: 'req_${DateTime.now().millisecondsSinceEpoch}',
      fromUserId: fromUserId,
      toUserId: toUserId,
      fromUsername: fromUsername,
      createdAt: DateTime.now(),
    ));
  }

  bool acceptRequest(String requestId) {
    final req = _requests.firstWhere(
      (r) => r.id == requestId,
      orElse: () => FriendRequest(
        id: '', fromUserId: '', toUserId: '', createdAt: DateTime.now(),
      ),
    );
    if (req.id.isEmpty) return false;

    final idx = _requests.indexOf(req);
    _requests[idx] = FriendRequest(
      id: req.id,
      fromUserId: req.fromUserId,
      toUserId: req.toUserId,
      fromUsername: req.fromUsername,
      createdAt: req.createdAt,
      status: FriendStatus.accepted,
    );

    _friends.add(FriendRelation(
      user: FriendUser(
        id: req.fromUserId,
        username: req.fromUsername ?? 'Player',
      ),
      status: FriendStatus.accepted,
      since: DateTime.now(),
    ));
    return true;
  }

  void rejectRequest(String requestId) {
    _requests.removeWhere((r) => r.id == requestId);
  }

  void removeFriend(String userId) {
    _friends.removeWhere((r) => r.user.id == userId);
  }

  List<FriendUser> search(String query) {
    return _searchResults
        .where((u) => u.username.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  void addSearchResult(FriendUser user) {
    _searchResults.add(user);
  }
}
