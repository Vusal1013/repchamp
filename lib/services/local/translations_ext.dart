import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/localization_provider.dart';
import '../local/localization_service.dart';

extension TranslateRef on WidgetRef {
  String tr(String key, {String? fallback}) {
    final strings = this.watch(stringsProvider);
    return strings[key] ?? fallback ?? key;
  }
}

extension TranslateCtx on BuildContext {
  String tr(String key, {String? fallback}) {
    return LocalizationService.get('en', key, fallback: fallback);
  }
}
