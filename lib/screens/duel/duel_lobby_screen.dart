import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/duel_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/duel_model.dart';
import '../../widgets/common/primary_button.dart';

class DuelLobbyScreen extends ConsumerStatefulWidget {
  const DuelLobbyScreen({super.key});

  @override
  ConsumerState<DuelLobbyScreen> createState() => _DuelLobbyScreenState();
}

class _DuelLobbyScreenState extends ConsumerState<DuelLobbyScreen> {
  final _exerciseType = 'push_up';

  Future<void> _createRoom() async {
    final service = ref.read(duelServiceProvider);
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    final roomId = await service.createDuelRoom(_exerciseType);
    await service.joinDuelRoom(roomId, userId);
    ref.read(duelRoomIdProvider.notifier).state = roomId;

    if (mounted) context.push('/duel/active', extra: roomId);
  }

  Future<void> _joinRoom(String roomId) async {
    final service = ref.read(duelServiceProvider);
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    await service.joinDuelRoom(roomId, userId);
    ref.read(duelRoomIdProvider.notifier).state = roomId;

    if (mounted) context.push('/duel/active', extra: roomId);
  }

  @override
  Widget build(BuildContext context) {
    final availableRooms = ref.watch(availableRoomsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('DUEL LOBBY'),
        backgroundColor: AppColors.background,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PrimaryButton(
              label: 'CREATE ROOM',
              onPressed: _createRoom,
            ),
            const SizedBox(height: 32),
            const Text(
              'AVAILABLE ROOMS',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: availableRooms.when(
                data: (rooms) {
                  if (rooms.isEmpty) {
                    return const Center(
                      child: Text(
                        'No rooms available.\nCreate one!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: rooms.length,
                    itemBuilder: (_, i) => _RoomTile(
                      room: rooms[i],
                      onJoin: () => _joinRoom(rooms[i].id),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Center(
                  child: Text('Error loading rooms',
                      style: TextStyle(color: Colors.redAccent)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoomTile extends StatelessWidget {
  final DuelRoom room;
  final VoidCallback onJoin;

  const _RoomTile({required this.room, required this.onJoin});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(
          room.exerciseType.replaceAll('_', ' ').toUpperCase(),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${room.durationSeconds}s · waiting',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        trailing: PrimaryButton(
          label: 'JOIN',
          onPressed: onJoin,
        ),
      ),
    );
  }
}

final availableRoomsProvider = FutureProvider<List<DuelRoom>>((ref) async {
  final service = ref.watch(duelServiceProvider);
  return service.getAvailableRooms();
});
