import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/duel_provider.dart';
import '../services/supabase/dashboard_service.dart';

final dashboardServiceProvider = Provider<DashboardService>((ref) => DashboardService());

final dailyStatsProvider = FutureProvider<DailyStats?>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;
  return ref.read(dashboardServiceProvider).getDailyStats(userId);
});

final weeklyBreakdownProvider = FutureProvider<WeeklyBreakdown>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return const WeeklyBreakdown(dailyXp: [0, 0, 0, 0, 0, 0, 0]);
  return ref.read(dashboardServiceProvider).getWeeklyBreakdown(userId);
});

final recentActivityProvider = FutureProvider<List<RecentActivityItem>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];
  return ref.read(dashboardServiceProvider).getRecentActivity(userId);
});
