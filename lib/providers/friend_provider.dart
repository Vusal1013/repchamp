import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/friend_model.dart';
import '../services/friend_service.dart';
import 'auth_provider.dart';

final friendServiceProvider = Provider<FriendService>((ref) => FriendService());

final friendListProvider = Provider<List<FriendRelation>>((ref) {
  return ref.watch(friendServiceProvider).friends;
});

final pendingRequestsProvider = Provider<List<FriendRequest>>((ref) {
  return ref.watch(friendServiceProvider).pendingRequests;
});

final friendSearchResultsProvider = StateProvider<List<FriendUser>>((ref) => []);

class FriendNotifier extends StateNotifier<AsyncValue<void>> {
  final FriendService _service;
  final Ref _ref;

  FriendNotifier(this._service, this._ref) : super(const AsyncValue.data(null));

  void sendRequest(String toUserId) {
    final userId = _ref.read(currentUserProvider)?.id ?? 'local';
    _service.sendRequest(userId, toUserId);
    state = const AsyncValue.data(null);
  }

  void acceptRequest(String requestId) {
    _service.acceptRequest(requestId);
    state = const AsyncValue.data(null);
  }

  void rejectRequest(String requestId) {
    _service.rejectRequest(requestId);
    state = const AsyncValue.data(null);
  }

  void removeFriend(String userId) {
    _service.removeFriend(userId);
    state = const AsyncValue.data(null);
  }

  void search(String query) {
    final results = _service.search(query);
    _ref.read(friendSearchResultsProvider.notifier).state = results;
  }
}

final friendProvider = StateNotifierProvider<FriendNotifier, AsyncValue<void>>((ref) {
  return FriendNotifier(ref.watch(friendServiceProvider), ref);
});
