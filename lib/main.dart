import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://rcymhgeizrgirekjoldt.supabase.co',
    publishableKey: 'sb_publishable_f2XxTENlsP0fLKWAKa0kuA_sfmxbah1',
  );

  runApp(
    const ProviderScope(
      child: RepChampApp(),
    ),
  );
}
