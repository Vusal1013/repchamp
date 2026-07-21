import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/workout/solo_workout_screen.dart';
import 'screens/workout/workout_summary_screen.dart';
import 'screens/duel/duel_lobby_screen.dart';
import 'screens/duel/duel_screen.dart';
import 'screens/duel/duel_result_screen.dart';
import 'screens/leaderboard/leaderboard_screen.dart';
import 'screens/profile/profile_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (_, __) => const SignupScreen()),
    GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/workout/solo', builder: (_, __) => const SoloWorkoutScreen()),
    GoRoute(path: '/workout/summary', builder: (_, __) => const WorkoutSummaryScreen()),
    GoRoute(path: '/duel/lobby', builder: (_, __) => const DuelLobbyScreen()),
    GoRoute(path: '/duel/active', builder: (_, __) => const DuelScreen()),
    GoRoute(path: '/duel/result', builder: (_, __) => const DuelResultScreen()),
    GoRoute(path: '/leaderboard', builder: (_, __) => const LeaderboardScreen()),
    GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
  ],
);

class RepChampApp extends StatelessWidget {
  const RepChampApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'RepChamp',
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
