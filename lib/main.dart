import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'providers/streak_provider.dart';
import 'screens/offline/offline_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://rcymhgeizrgirekjoldt.supabase.co',
    publishableKey: 'sb_publishable_f2XxTENlsP0fLKWAKa0kuA_sfmxbah1',
  );

  runApp(
    ProviderScope(
      child: _StreakInitializer(child: const OfflineScreen(child: RepChampApp())),
    ),
  );
}

class _StreakInitializer extends ConsumerStatefulWidget {
  final Widget child;
  const _StreakInitializer({required this.child});

  @override
  ConsumerState<_StreakInitializer> createState() => _StreakInitializerState();
}

class _StreakInitializerState extends ConsumerState<_StreakInitializer> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(streakProvider.notifier).checkAndUpdate();
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
