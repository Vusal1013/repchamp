import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/duel_model.dart';
import '../services/supabase/duel_service.dart';
import 'auth_provider.dart';

final duelServiceProvider = Provider<DuelService>((ref) => DuelService());

final duelRoomIdProvider = StateProvider<String?>((ref) => null);

final duelPlayersStreamProvider = StreamProvider<List<DuelPlayer>>((ref) {
  final roomId = ref.watch(duelRoomIdProvider);
  if (roomId == null) return const Stream.empty();

  final service = ref.watch(duelServiceProvider);
  return service.listenToDuelPlayers(roomId);
});

final duelRoomStreamProvider = StreamProvider<DuelRoom?>((ref) {
  final roomId = ref.watch(duelRoomIdProvider);
  if (roomId == null) return const Stream.empty();

  final service = ref.watch(duelServiceProvider);
  return service.listenToDuelRoom(roomId).map((room) => room);
});

final opponentPlayerProvider = Provider<DuelPlayer?>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  final players = ref.watch(duelPlayersStreamProvider).value ?? [];
  return players.where((p) => p.userId != userId).firstOrNull;
});

final myDuelPlayerProvider = Provider<DuelPlayer?>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  final players = ref.watch(duelPlayersStreamProvider).value ?? [];
  return players.where((p) => p.userId == userId).firstOrNull;
});

final currentUserIdProvider = Provider<String?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.currentUser?.id;
});
