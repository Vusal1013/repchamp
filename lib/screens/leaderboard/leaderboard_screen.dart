import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../services/supabase/leaderboard_service.dart';

final leaderboardProvider = FutureProvider<List<LeaderboardEntry>>((ref) async {
  final service = LeaderboardService();
  return service.getLeaderboard(limit: 20);
});

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboard = ref.watch(leaderboardProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('LEADERBOARD'),
        backgroundColor: AppColors.background,
        foregroundColor: Colors.white,
      ),
      body: leaderboard.when(
        data: (entries) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: entries.length,
          itemBuilder: (_, i) => _LeaderboardTile(
            rank: i + 1,
            entry: entries[i],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(
          child: Text('Failed to load leaderboard',
              style: TextStyle(color: Colors.redAccent)),
        ),
      ),
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  final int rank;
  final LeaderboardEntry entry;

  const _LeaderboardTile({required this.rank, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: rank <= 3 ? AppColors.accent : AppColors.surface,
          child: Text(
            '$rank',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: rank <= 3 ? AppColors.background : Colors.white,
            ),
          ),
        ),
        title: Text(
          entry.username,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'Level ${entry.level} · ${entry.totalSessions} sessions',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        trailing: Text(
          '${entry.totalReps}',
          style: const TextStyle(
            color: AppColors.accent,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
