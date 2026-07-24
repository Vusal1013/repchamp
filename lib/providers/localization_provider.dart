import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/local/localization_service.dart';
import 'settings_provider.dart';

final localeLoadedProvider = FutureProvider<void>((ref) async {
  final locale = ref.watch(settingsProvider.select((s) => s.locale));
  await LocalizationService.load(locale.languageCode);
});

final stringsProvider = Provider<Map<String, String>>((ref) {
  ref.watch(localeLoadedProvider);
  final locale = ref.read(settingsProvider).locale;
  return LocalizationService.getAll(locale.languageCode);
});
