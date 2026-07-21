import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/duel_provider.dart';
import '../../widgets/common/primary_button.dart';

class DuelResultScreen extends ConsumerWidget {
  const DuelResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    final winnerId = extra?['winner_id'] as String?;
    final myReps = extra?['my_reps'] as int? ?? 0;
    final userId = ref.watch(currentUserIdProvider);
    final isWinner = userId == winnerId;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isWinner ? Icons.emoji_events : Icons.sentiment_neutral,
                size: 80,
                color: isWinner ? AppColors.accent : AppColors.textSecondary,
              ),
              const SizedBox(height: 24),
              Text(
                isWinner ? 'YOU WIN!' : 'YOU LOSE',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: isWinner ? AppColors.accent : Colors.redAccent,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                '$myReps',
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'REPS',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 48),
              PrimaryButton(
                label: 'BACK TO HOME',
                onPressed: () => context.go('/home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
