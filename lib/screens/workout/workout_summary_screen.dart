import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common/primary_button.dart';

class WorkoutSummaryScreen extends StatelessWidget {
  const WorkoutSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    final repCount = extra?['rep_count'] as int? ?? 0;
    final exerciseType = extra?['exercise_type'] as String? ?? 'push_up';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'WORKOUT\nCOMPLETE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 48),
              Text(
                exerciseType.replaceAll('_', ' ').toUpperCase(),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '$repCount',
                style: const TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'TOTAL REPS',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 64),
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
