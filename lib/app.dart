import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'providers/settings_provider.dart';
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
import 'screens/profile/profile_settings_screen.dart';

final _publicRoutes = <String>{'/login', '/signup'};

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    final session = Supabase.instance.client.auth.currentSession;
    final isLoggedIn = session != null;
    final location = state.uri.toString();

    if (isLoggedIn && _publicRoutes.contains(location)) return '/home';
    if (!isLoggedIn && !_publicRoutes.contains(location)) return '/login';
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (_, __) => const SignupScreen()),
    GoRoute(
      path: '/home',
      builder: (_, __) => const HomeScreen(),
    ),
    GoRoute(
      path: '/workout/select',
      builder: (_, __) => const ExerciseSelectScreen(),
    ),
    GoRoute(
      path: '/workout/solo',
      builder: (_, __) => const SoloWorkoutScreen(),
    ),
    GoRoute(
      path: '/workout/summary',
      builder: (_, __) => const WorkoutSummaryScreen(),
    ),
    GoRoute(
      path: '/duel/lobby',
      builder: (_, __) => const DuelLobbyScreen(),
    ),
    GoRoute(
      path: '/duel/active',
      builder: (_, __) => const DuelScreen(),
    ),
    GoRoute(
      path: '/duel/result',
      builder: (_, __) => const DuelResultScreen(),
    ),
    GoRoute(
      path: '/challenges',
      builder: (_, __) => const ChallengeScreen(),
    ),
    GoRoute(
      path: '/friends',
      builder: (_, __) => const FriendsScreen(),
    ),
    GoRoute(
      path: '/leaderboard',
      builder: (_, __) => const LeaderboardScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (_, __) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/profile/settings',
      builder: (_, __) => const ProfileSettingsScreen(),
    ),
  ],
);

class RepChampApp extends ConsumerWidget {
  const RepChampApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return MaterialApp.router(
      title: 'RepChamp',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode,
      locale: settings.locale,
      supportedLocales: const [
        Locale('en'), Locale('tr'), Locale('az'), Locale('ar'),
        Locale('cs'), Locale('de'), Locale('el'), Locale('es'),
        Locale('fr'), Locale('hi'), Locale('id'), Locale('it'),
        Locale('ja'), Locale('ko'), Locale('nl'), Locale('pl'),
        Locale('pt'), Locale('ro'), Locale('ru'), Locale('sv'),
        Locale('uk'), Locale('zh'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
