import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'providers/streak_provider.dart';
import 'screens/offline/offline_screen.dart';
import 'services/local/localization_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Supabase.initialize(
      url: 'https://rcymhgeizrgirekjoldt.supabase.co',
      publishableKey: 'sb_publishable_f2XxTENlsP0fLKWAKa0kuA_sfmxbah1',
    );
  } catch (_) {
    // No internet — app will show OfflineScreen
  }

  try {
    await Future.wait([
      LocalizationService.load('en'),
      LocalizationService.load('az'),
      LocalizationService.load('tr'),
      LocalizationService.load('ar'),
      LocalizationService.load('cs'),
      LocalizationService.load('de'),
      LocalizationService.load('el'),
      LocalizationService.load('es'),
      LocalizationService.load('fr'),
      LocalizationService.load('hi'),
      LocalizationService.load('id'),
      LocalizationService.load('it'),
      LocalizationService.load('ja'),
      LocalizationService.load('ko'),
      LocalizationService.load('nl'),
      LocalizationService.load('pl'),
      LocalizationService.load('pt'),
      LocalizationService.load('ro'),
      LocalizationService.load('ru'),
      LocalizationService.load('sv'),
      LocalizationService.load('uk'),
      LocalizationService.load('zh'),
    ]);
  } catch (_) {}

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
