import 'package:flutter/material.dart';
import '../../models/achievement_model.dart';

class AchievementBadge extends StatelessWidget {
  final Achievement achievement;
  final double size;

  const AchievementBadge({
    super.key,
    required this.achievement,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    final unlocked = achievement.unlocked;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: unlocked
            ? const Color(0xFF6CFF80).withAlpha(26)
            : const Color(0xFF353534).withAlpha(128),
        border: Border.all(
          color: unlocked
              ? const Color(0xFF6CFF80)
              : const Color(0xFF353534),
          width: 2,
        ),
        boxShadow: unlocked
            ? [
                BoxShadow(
                  color: const Color(0xFF39FF6A).withAlpha(77),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _iconFor(achievement.id),
            color: unlocked
                ? const Color(0xFF6CFF80)
                : const Color(0xFF859581),
            size: size * 0.4,
          ),
          if (!unlocked)
            Container(
              width: size * 0.15,
              height: size * 0.15,
              decoration: BoxDecoration(
                color: const Color(0xFFBACBB6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }

  IconData _iconFor(AchievementId id) {
    switch (id) {
      case AchievementId.firstRep:
        return Icons.fitness_center_rounded;
      case AchievementId.club100:
        return Icons.looks_one_rounded;
      case AchievementId.club1000:
        return Icons.looks_two_rounded;
      case AchievementId.streak7:
        return Icons.local_fire_department_rounded;
      case AchievementId.streak30:
        return Icons.whatshot_rounded;
      case AchievementId.firstWin:
        return Icons.emoji_events_rounded;
      case AchievementId.noPainNoGain:
        return Icons.directions_run_rounded;
      case AchievementId.earlyBird:
        return Icons.wb_sunny_rounded;
      case AchievementId.nightOwl:
        return Icons.nightlight_round_rounded;
      case AchievementId.comebackKing:
        return Icons.replay_rounded;
      case AchievementId.perfectForm:
        return Icons.check_circle_rounded;
      case AchievementId.speedDemon:
        return Icons.bolt_rounded;
      case AchievementId.duelist:
        return Icons.sports_kabaddi_rounded;
      case AchievementId.veteran:
        return Icons.military_tech_rounded;
    }
  }
}

class AchievementCard extends StatelessWidget {
  final Achievement achievement;

  const AchievementCard({super.key, required this.achievement});

  @override
  Widget build(BuildContext context) {
    final unlocked = achievement.unlocked;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: unlocked
            ? const Color(0xFF6CFF80).withAlpha(13)
            : Colors.white.withAlpha(8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: unlocked
              ? const Color(0xFF6CFF80).withAlpha(77)
              : const Color(0xFF353534),
        ),
      ),
      child: Row(
        children: [
          AchievementBadge(achievement: achievement),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: TextStyle(
                    fontFamily: 'SpaceMono',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: unlocked
                        ? const Color(0xFFE5E2E1)
                        : const Color(0xFF859581),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: TextStyle(
                    fontSize: 11,
                    color: unlocked
                        ? const Color(0xFFBACBB6)
                        : const Color(0xFF859581).withAlpha(153),
                  ),
                ),
              ],
            ),
          ),
          if (achievement.isSecret && !unlocked)
            Icon(Icons.help_outline_rounded,
                color: const Color(0xFF859581), size: 18),
        ],
      ),
    );
  }
}
