import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/friend_model.dart';
import '../../providers/friend_provider.dart';
import '../../providers/localization_provider.dart';
import '../../services/local/translations_ext.dart';
import '../../widgets/common/fit_duel_bottom_nav.dart';

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final friends = ref.watch(friendListProvider);
    final requests = ref.watch(pendingRequestsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF131313),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabs(),
            Expanded(
              child: _selectedTab == 0
                  ? _buildFriendsList(friends)
                  : _selectedTab == 1
                      ? _buildPendingRequests(requests)
                      : _buildAddFriend(),
            ),
            const FitDuelBottomNav(activeTab: NavTab.profile),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF131313),
        border: Border(bottom: BorderSide(color: Color(0xFF353534))),
      ),
      child: Row(
        children: [
          Text(
            ref.tr('friends_title'),
            style: const TextStyle(
              fontFamily: 'ArchivoNarrow',
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.01,
              color: Color(0xFF6CFF80),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    final labels = [ref.tr('friends_title'), ref.tr('pending_requests'), ref.tr('add_friend')];
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF201F1F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(3, (i) {
          final isActive = _selectedTab == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF6CFF80).withAlpha(51)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: isActive
                      ? Border.all(color: const Color(0xFF6CFF80).withAlpha(77))
                      : null,
                ),
                child: Text(
                  labels[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'SpaceMono',
                    fontSize: 12,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                    color: isActive
                        ? const Color(0xFF007226)
                        : const Color(0xFFBACBB6),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFriendsList(List<FriendRelation> friends) {
    if (friends.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.people_outline_rounded, size: 64, color: Color(0xFF353534)),
            const SizedBox(height: 16),
            Text(ref.tr('no_friends'),
              style: const TextStyle(color: Color(0xFFBACBB6), fontSize: 16)),
            const SizedBox(height: 8),
            Text(ref.tr('add_friends_to_compare'),
              style: TextStyle(color: Color(0xFF859581), fontSize: 12)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: friends.length,
      itemBuilder: (_, i) => _FriendTile(friend: friends[i]),
    );
  }

  Widget _buildPendingRequests(List<FriendRequest> requests) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_rounded, size: 64, color: Color(0xFF353534)),
            const SizedBox(height: 16),
            Text(ref.tr('no_pending_requests'),
              style: const TextStyle(color: Color(0xFFBACBB6), fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: requests.length,
      itemBuilder: (_, i) => _RequestTile(request: requests[i]),
    );
  }

  Widget _buildAddFriend() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF201F1F),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF353534)),
            ),
            child: TextField(
              style: const TextStyle(color: Color(0xFFE5E2E1)),
              decoration: InputDecoration(
                hintText: ref.tr('search_by_username'),
                hintStyle: const TextStyle(color: Color(0xFF859581)),
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF859581)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                border: InputBorder.none,
              ),
              onChanged: (query) {
                if (query.length >= 3) {
                  ref.read(friendProvider.notifier).search(query);
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Consumer(builder: (_, ref2, __) {
              final results = ref2.watch(friendSearchResultsProvider);
              if (results.isEmpty) {
                return const Center(
                  child: Text('Search for players by username',
                    style: TextStyle(color: Color(0xFF859581))),
                );
              }
              return ListView.builder(
                itemCount: results.length,
                itemBuilder: (_, i) => _SearchResultTile(user: results[i]),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _FriendTile extends StatelessWidget {
  final FriendRelation friend;
  const _FriendTile({required this.friend});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF201F1F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF353534)),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF353534)),
                ),
                child: const Icon(Icons.person, size: 28, color: Color(0xFFBACBB6)),
              ),
              if (friend.user.isOnline)
                Positioned(
                  bottom: 0, right: 0,
                  child: Container(
                    width: 14, height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF6CFF80),
                      border: Border.all(color: const Color(0xFF131313), width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  friend.user.username.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'SpaceMono',
                    fontSize: 12,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFE5E2E1),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'LVL ${friend.user.level} \u2022 ${friend.user.totalReps} total reps',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFFBACBB6),
                  ),
                ),
              ],
            ),
          ),
          Text(
            friend.user.isOnline ? 'ONLINE' : 'OFFLINE',
            style: TextStyle(
              fontFamily: 'SpaceMono',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: friend.user.isOnline
                  ? const Color(0xFF6CFF80)
                  : const Color(0xFF859581),
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestTile extends ConsumerWidget {
  final FriendRequest request;
  const _RequestTile({required this.request});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF201F1F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF6CFF80).withAlpha(40)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF2A2A2A),
            ),
            child: const Icon(Icons.person, size: 28, color: Color(0xFFBACBB6)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              request.fromUsername?.toUpperCase() ?? 'UNKNOWN',
              style: const TextStyle(
                fontFamily: 'SpaceMono',
                fontSize: 12,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w700,
                color: Color(0xFFE5E2E1),
              ),
            ),
          ),
          TextButton(
            onPressed: () => ref.read(friendProvider.notifier).acceptRequest(request.id),
            child: const Text('ACCEPT',
              style: TextStyle(
                fontFamily: 'SpaceMono',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6CFF80),
              ),
            ),
          ),
          TextButton(
            onPressed: () => ref.read(friendProvider.notifier).rejectRequest(request.id),
            child: const Text('X',
              style: TextStyle(
                fontFamily: 'SpaceMono',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFFFFB4AB),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResultTile extends ConsumerWidget {
  final FriendUser user;
  const _SearchResultTile({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF201F1F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF353534)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF2A2A2A),
            ),
            child: const Icon(Icons.person, size: 28, color: Color(0xFFBACBB6)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              user.username.toUpperCase(),
              style: const TextStyle(
                fontFamily: 'SpaceMono',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFFE5E2E1),
              ),
            ),
          ),
          SizedBox(
            width: 100,
            child: ElevatedButton(
              onPressed: () => ref.read(friendProvider.notifier).sendRequest(user.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6CFF80),
                foregroundColor: const Color(0xFF00390F),
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text(
                'ADD',
                style: TextStyle(
                  fontFamily: 'SpaceMono',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
