import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';

class RepCounterDisplay extends StatefulWidget {
  final int repCount;

  const RepCounterDisplay({super.key, required this.repCount});

  @override
  State<RepCounterDisplay> createState() => _RepCounterDisplayState();
}

class _RepCounterDisplayState extends State<RepCounterDisplay> {
  int _previousCount = 0;

  @override
  Widget build(BuildContext context) {
    final increased = widget.repCount > _previousCount;
    _previousCount = widget.repCount;

    return Animate(
      effects: increased
          ? [
              ScaleEffect(
                begin: const Offset(1.3, 1.3),
                end: const Offset(1.0, 1.0),
                duration: 300.ms,
                curve: Curves.easeOutBack,
              ),
            ]
          : [],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${widget.repCount}',
            style: const TextStyle(
              fontSize: 96,
              fontWeight: FontWeight.bold,
              color: AppColors.accent,
              shadows: [
                Shadow(
                  color: AppColors.accent,
                  blurRadius: 20,
                ),
              ],
            ),
          ),
          const Text(
            'reps',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.textSecondary,
              letterSpacing: 4,
            ),
          ),
        ],
      ),
    );
  }
}
