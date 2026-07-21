import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/user_profile_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/primary_button.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('PROFILE'),
        backgroundColor: AppColors.background,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () async {
              await ref.read(authServiceProvider).signOut();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) {
            return const Center(
              child: Text('Profile not found',
                  style: TextStyle(color: Colors.redAccent)),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.surface,
                  child: Icon(Icons.person, size: 48, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                Text(
                  profile.username,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Level ${profile.level}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 32),
                _StatCard(label: 'XP', value: '${profile.xp}'),
                const SizedBox(height: 12),
                _StatCard(label: 'STREAK', value: '${profile.streak} days'),
                const SizedBox(height: 12),
                _StatCard(
                  label: 'MEMBER SINCE',
                  value: '${profile.createdAt.day}/${profile.createdAt.month}/${profile.createdAt.year}',
                ),
                const Spacer(),
                PrimaryButton(
                  label: 'BACK TO HOME',
                  onPressed: () => context.go('/home'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(
          child: Text('Failed to load profile',
              style: TextStyle(color: Colors.redAccent)),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              letterSpacing: 2,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
