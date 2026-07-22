import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/weekly_challenge_model.dart';
import '../../providers/challenge_provider.dart';
import '../../widgets/common/fit_duel_bottom_nav.dart';

class ChallengeScreen extends ConsumerWidget {
  const ChallengeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengesAsync = ref.watch(challengeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF131313),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: challengesAsync.when(
                data: (challenges) => _buildBody(challenges),
                loading: () => const Center(
                  child: CircularProgressIndicator(color: Color(0xFF6CFF80)),
                ),
                error: (_, __) => const Center(
                  child: Text('Failed to load challenges',
                    style: TextStyle(color: Color(0xFFFFB4AB))),
                ),
              ),
            ),
            const FitDuelBottomNav(activeTab: NavTab.duel),
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
            'WEEKLY CHALLENGES',
            style: TextStyle(
              fontFamily: 'ArchivoNarrow',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.01,
              color: const Color(0xFF6CFF80),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF201F1F),
              borderRadius: BorderRadius.circular(9999),
              border: Border.all(color: const Color(0xFF353534)),
            ),
            child: Text(
              '12🔥',
              style: TextStyle(
                fontFamily: 'SpaceMono',
                fontSize: 12,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF6CFF80),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(List<WeeklyChallenge> challenges) {
    if (challenges.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emoji_events_rounded, size: 64, color: Color(0xFF353534)),
            SizedBox(height: 16),
            Text('No active challenges',
              style: TextStyle(color: Color(0xFFBACBB6), fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      itemCount: challenges.length,
      itemBuilder: (_, i) => _ChallengeCard(challenge: challenges[i]),
    );
  }
}

class _ChallengeCard extends ConsumerWidget {
  final WeeklyChallenge challenge;
  const _ChallengeCard({required this.challenge});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = 'local';
    final progress = challenge.progress[userId] ?? 0;
    final fraction = (progress / challenge.targetValue).clamp(0.0, 1.0);

    IconData icon;
    switch (challenge.type) {
      case ChallengeType.repGoal:
        icon = Icons.fitness_center_rounded;
      case ChallengeType.timeTrial:
        icon = Icons.timer_outlined;
      case ChallengeType.streakDays:
        icon = Icons.local_fire_department_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: challenge.completed
            ? const Color(0xFF6CFF80).withAlpha(13)
            : const Color(0xFF201F1F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: challenge.completed
              ? const Color(0xFF6CFF80).withAlpha(80)
              : const Color(0xFF353534),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: challenge.completed
                      ? const Color(0xFF6CFF80).withAlpha(26)
                      : const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon,
                  color: challenge.completed
                      ? const Color(0xFF6CFF80)
                      : const Color(0xFFBACBB6),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge.title.toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'SpaceMono',
                        fontSize: 14,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                        color: challenge.completed
                            ? const Color(0xFF6CFF80)
                            : const Color(0xFFE5E2E1),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      challenge.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFBACBB6),
                      ),
                    ),
                  ],
                ),
              ),
              if (challenge.completed)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6CFF80),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'DONE',
                    style: TextStyle(
                      fontFamily: 'SpaceMono',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF00390F),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(9999),
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFF353534),
                borderRadius: BorderRadius.circular(9999),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: fraction,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: challenge.completed
                          ? [const Color(0xFF6CFF80), const Color(0xFF00E556)]
                          : [const Color(0xFF568DFF), const Color(0xFF6CFF80)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF39FF6A).withAlpha(77),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$progress / ${challenge.targetValue}',
                style: TextStyle(
                  fontFamily: 'SpaceMono',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: challenge.completed
                      ? const Color(0xFF6CFF80)
                      : const Color(0xFFBACBB6),
                ),
              ),
              Text(
                '+${challenge.xpReward} XP',
                style: const TextStyle(
                  fontFamily: 'SpaceMono',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6CFF80),
                ),
              ),
            ],
          ),
          if (!challenge.completed) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF6CFF80),
                  side: BorderSide(color: const Color(0xFF6CFF80).withAlpha(128)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'START CHALLENGE',
                  style: TextStyle(
                    fontFamily: 'SpaceMono',
                    fontSize: 12,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
