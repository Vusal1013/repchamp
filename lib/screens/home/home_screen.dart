import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common/primary_button.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              const Text(
                'REPCHAMP',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                  letterSpacing: 8,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Fitness Duel',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  letterSpacing: 4,
                ),
              ),
              const Spacer(flex: 2),
              PrimaryButton(
                label: 'SOLO WORKOUT',
                onPressed: () => context.push('/workout/solo', extra: 'push_up'),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'DUEL',
                onPressed: () => context.push('/duel/lobby'),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'LEADERBOARD',
                onPressed: () => context.push('/leaderboard'),
                color: AppColors.surface,
              ),
              const Spacer(flex: 1),
              Center(
                child: IconButton(
                  onPressed: () => context.push('/profile'),
                  icon: const Icon(Icons.person_outline, color: AppColors.textSecondary),
                  iconSize: 32,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
