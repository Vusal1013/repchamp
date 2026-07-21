import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class DuelProgressBar extends StatelessWidget {
  final int myReps;
  final int opponentReps;
  final String myUsername;
  final String opponentUsername;

  const DuelProgressBar({
    super.key,
    required this.myReps,
    required this.opponentReps,
    required this.myUsername,
    required this.opponentUsername,
  });

  @override
  Widget build(BuildContext context) {
    final total = (myReps + opponentReps).clamp(1, double.maxFinite.toInt());
    final myFraction = myReps / total;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$myUsername: $myReps',
              style: const TextStyle(
                color: AppColors.accent,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$opponentUsername: $opponentReps',
              style: const TextStyle(
                color: AppColors.accentBlue,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 12,
            child: Row(
              children: [
                Flexible(
                  flex: (myFraction * 100).round().clamp(1, 100),
                  child: Container(color: AppColors.accent),
                ),
                Flexible(
                  flex: ((1 - myFraction) * 100).round().clamp(1, 100),
                  child: Container(color: AppColors.accentBlue),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
