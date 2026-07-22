import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/workout/exercise_select_screen.dart';
import 'screens/workout/solo_workout_screen.dart';
import 'screens/workout/workout_summary_screen.dart';
import 'screens/duel/duel_lobby_screen.dart';
import 'screens/duel/duel_screen.dart';
import 'screens/duel/duel_result_screen.dart';
import 'screens/challenge/challenge_screen.dart';
import 'screens/friends/friends_screen.dart';
import 'screens/leaderboard/leaderboard_screen.dart';
import 'screens/profile/profile_screen.dart';

class _AuthGuard extends ConsumerWidget {
  final Widget child;

  const _AuthGuard({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    if (!isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/login');
      });
      return const Scaffold(
        backgroundColor: Color(0xFF131313),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF6CFF80)),
        ),
      );
    }

    return child;
  }
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (_, __) => const SignupScreen()),
    GoRoute(
      path: '/home',
      builder: (_, __) => const _AuthGuard(child: HomeScreen()),
    ),
    GoRoute(
      path: '/workout/select',
      builder: (_, __) => const _AuthGuard(child: ExerciseSelectScreen()),
    ),
    GoRoute(
      path: '/workout/solo',
      builder: (_, __) => const _AuthGuard(child: SoloWorkoutScreen()),
    ),
    GoRoute(
      path: '/workout/summary',
      builder: (_, __) => const _AuthGuard(child: WorkoutSummaryScreen()),
    ),
    GoRoute(
      path: '/duel/lobby',
      builder: (_, __) => const _AuthGuard(child: DuelLobbyScreen()),
    ),
    GoRoute(
      path: '/duel/active',
      builder: (_, __) => const _AuthGuard(child: DuelScreen()),
    ),
    GoRoute(
      path: '/duel/result',
      builder: (_, __) => const _AuthGuard(child: DuelResultScreen()),
    ),
    GoRoute(
      path: '/challenges',
      builder: (_, __) => const _AuthGuard(child: ChallengeScreen()),
    ),
    GoRoute(
      path: '/friends',
      builder: (_, __) => const _AuthGuard(child: FriendsScreen()),
    ),
    GoRoute(
      path: '/leaderboard',
      builder: (_, __) => const _AuthGuard(child: LeaderboardScreen()),
    ),
    GoRoute(
      path: '/profile',
      builder: (_, __) => const _AuthGuard(child: ProfileScreen()),
    ),
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
