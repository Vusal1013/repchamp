import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/exercise_type.dart';
import '../../widgets/common/fit_duel_bottom_nav.dart';

class ExerciseSelectScreen extends StatelessWidget {
  final bool isDuel;

  const ExerciseSelectScreen({super.key, this.isDuel = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131313),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDuel),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isDuel ? 'CHOOSE YOUR DUEL' : 'CHOOSE EXERCISE',
                      style: TextStyle(
                        fontFamily: 'ArchivoNarrow',
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.01,
                        color: const Color(0xFFE5E2E1),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isDuel
                          ? 'Select an exercise to challenge your opponent'
                          : 'Pick an exercise to start your workout',
                      style: TextStyle(
                        fontFamily: 'SpaceMono',
                        fontSize: 12,
                        letterSpacing: 1.2,
                        color: const Color(0xFFBACBB6),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: ExerciseType.values.length,
                        itemBuilder: (_, i) => _exerciseCard(
                          context,
                          ExerciseType.values[i],
                          isDuel,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const FitDuelBottomNav(activeTab: NavTab.home),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDuel) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF131313),
        border: Border(bottom: BorderSide(color: Color(0xFF353534))),
      ),
      child: Row(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF6CFF80), width: 2),
                ),
                clipBehavior: Clip.antiAlias,
                child: const Icon(Icons.person, size: 22, color: Color(0xFF6CFF80)),
              ),
              const SizedBox(width: 12),
              Text(
                'FITDUEL',
                style: TextStyle(
                  fontFamily: 'ArchivoNarrow',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.01,
                  color: const Color(0xFF6CFF80),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '12🔥',
            style: TextStyle(
              fontFamily: 'SpaceMono',
              fontSize: 12,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF6CFF80),
            ),
          ),
        ],
      ),
    );
  }

  Widget _exerciseCard(BuildContext context, ExerciseType type, bool isDuel) {
    return GestureDetector(
      onTap: () {
        if (isDuel) {
          context.push('/duel/lobby', extra: {'exercise': type.databaseValue});
        } else {
          context.push('/workout/solo', extra: {'exercise': type.databaseValue});
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF201F1F),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF353534)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _iconFor(type),
              color: const Color(0xFF6CFF80),
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              type.displayName.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'SpaceMono',
                fontSize: 12,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFE5E2E1),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              type.isTimeBased ? 'HOLD' : 'REPS',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 2,
                color: const Color(0xFFBACBB6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(ExerciseType type) {
    switch (type) {
      case ExerciseType.pushUp:
        return Icons.self_improvement_rounded;
      case ExerciseType.squat:
        return Icons.accessibility_new_rounded;
      case ExerciseType.crunch:
        return Icons.fitness_center_rounded;
      case ExerciseType.pullUp:
        return Icons.arrow_upward_rounded;
      case ExerciseType.plank:
        return Icons.air_rounded;
      case ExerciseType.lunge:
        return Icons.directions_walk_rounded;
      case ExerciseType.shoulderPress:
        return Icons.pan_tool_rounded;
    }
  }
}
