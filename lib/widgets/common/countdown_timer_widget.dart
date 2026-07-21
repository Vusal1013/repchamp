import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class CountdownTimerWidget extends StatefulWidget {
  final int durationSeconds;
  final VoidCallback onTimerEnd;

  const CountdownTimerWidget({
    super.key,
    required this.durationSeconds,
    required this.onTimerEnd,
  });

  @override
  State<CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
  late int _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.durationSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining <= 1) {
        timer.cancel();
        widget.onTimerEnd();
        return;
      }
      setState(() => _remaining--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWarning = _remaining <= 10;

    return Text(
      _formatTime(_remaining),
      style: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: isWarning ? Colors.redAccent : Colors.white,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
