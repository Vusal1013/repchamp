class StreakDay {
  final DateTime date;
  final int reps;
  final int xpEarned;

  const StreakDay({required this.date, this.reps = 0, this.xpEarned = 0});
}

class StreakService {
  int calculateStreak(List<DateTime> workoutDays) {
    if (workoutDays.isEmpty) return 0;

    final sorted = workoutDays.map((d) => DateTime(d.year, d.month, d.day)).toSet().toList()
      ..sort((a, b) => b.compareTo(a));

    int streak = 1;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    if (sorted.first != todayDate && sorted.first != todayDate.subtract(const Duration(days: 1))) {
      return 0;
    }

    for (int i = 0; i < sorted.length - 1; i++) {
      final diff = sorted[i].difference(sorted[i + 1]).inDays;
      if (diff == 1) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  List<StreakDay> getCurrentWeekDays(List<StreakDay> allDays) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    return allDays.where((d) {
      final date = DateTime(d.date.year, d.date.month, d.date.day);
      return !date.isBefore(weekStart) && !date.isAfter(weekEnd);
    }).toList();
  }

  int getWorkoutCountThisWeek(List<DateTime> workoutDays) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    return workoutDays.where((d) => !d.isBefore(weekStart)).length;
  }

  bool isWorkoutToday(List<DateTime> workoutDays) {
    final today = DateTime.now();
    return workoutDays.any((d) =>
        d.year == today.year && d.month == today.month && d.day == today.day);
  }
}
