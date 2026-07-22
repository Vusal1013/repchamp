import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/duel_model.dart';
import '../models/exercise_type.dart';
import 'duel_provider.dart';

enum MatchmakingState { idle, searching, found, countdown, ready }

class DuelMatchmakingState {
  final MatchmakingState state;
  final String? roomId;
  final DuelPlayer? opponent;
  final String? error;
  final int countdown;

  const DuelMatchmakingState({
    this.state = MatchmakingState.idle,
    this.roomId,
    this.opponent,
    this.error,
    this.countdown = 4,
  });

  DuelMatchmakingState copyWith({
    MatchmakingState? state,
    String? roomId,
    DuelPlayer? opponent,
    String? error,
    int? countdown,
  }) {
    return DuelMatchmakingState(
      state: state ?? this.state,
      roomId: roomId ?? this.roomId,
      opponent: opponent ?? this.opponent,
      error: error ?? this.error,
      countdown: countdown ?? this.countdown,
    );
  }
}

class DuelMatchmakingNotifier extends StateNotifier<DuelMatchmakingState> {
  final Ref _ref;

  DuelMatchmakingNotifier(this._ref) : super(const DuelMatchmakingState());

  Future<void> startSearching(ExerciseType exercise) async {
    state = state.copyWith(state: MatchmakingState.searching, error: null);

    try {
      final duelService = _ref.read(duelServiceProvider);
      final userId = _ref.read(currentUserIdProvider);

      if (userId == null) {
        state = state.copyWith(error: 'Not authenticated');
        return;
      }

      final roomId = await duelService.createDuelRoom(exercise.databaseValue);
      await duelService.joinDuelRoom(roomId, userId);

      _ref.read(duelRoomIdProvider.notifier).state = roomId;
      state = state.copyWith(roomId: roomId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> joinRoom(String roomId) async {
    state = state.copyWith(state: MatchmakingState.searching, error: null);

    try {
      final duelService = _ref.read(duelServiceProvider);
      final userId = _ref.read(currentUserIdProvider);

      if (userId == null) {
        state = state.copyWith(error: 'Not authenticated');
        return;
      }

      await duelService.joinDuelRoom(roomId, userId);
      _ref.read(duelRoomIdProvider.notifier).state = roomId;
      state = state.copyWith(roomId: roomId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void onOpponentFound(DuelPlayer opponent) {
    state = state.copyWith(
      state: MatchmakingState.found,
      opponent: opponent,
    );
  }

  Future<void> startCountdown() async {
    final roomId = state.roomId;
    if (roomId == null) return;

    try {
      final duelService = _ref.read(duelServiceProvider);
      final userId = _ref.read(currentUserIdProvider);

      if (userId == null) return;

      await duelService.setPlayerReady(roomId, userId);
    } catch (_) {}

    state = state.copyWith(state: MatchmakingState.countdown, countdown: 4);
  }

  void tickCountdown() {
    final current = state.countdown;
    if (current <= 1) {
      state = state.copyWith(state: MatchmakingState.ready, countdown: 0);
    } else {
      state = state.copyWith(countdown: current - 1);
    }
  }

  void reset() {
    _ref.read(duelRoomIdProvider.notifier).state = null;
    state = const DuelMatchmakingState();
  }
}

final duelMatchmakingProvider =
    StateNotifierProvider<DuelMatchmakingNotifier, DuelMatchmakingState>((ref) {
  return DuelMatchmakingNotifier(ref);
});
