import 'dart:convert';
import 'package:flutter/services.dart';

class LocalizationService {
  static final Map<String, Map<String, String>> _cache = {};

  static Future<void> load(String locale) async {
    if (_cache.containsKey(locale)) return;
    try {
      final json = await rootBundle.loadString('assets/lang/$locale.json');
      final map = jsonDecode(json) as Map<String, dynamic>;
      _cache[locale] = map.map((k, v) => MapEntry(k, v.toString()));
    } catch (_) {
      if (!_cache.containsKey('en')) {
        final json = await rootBundle.loadString('assets/lang/en.json');
        final map = jsonDecode(json) as Map<String, dynamic>;
        _cache['en'] = map.map((k, v) => MapEntry(k, v.toString()));
      }
      _cache[locale] = _cache['en']!;
    }
  }

  static String get(String locale, String key, {String? fallback}) {
    return _cache[locale]?[key] ?? fallback ?? key;
  }

  static Map<String, String> getAll(String locale) {
    return _cache[locale] ?? {};
  }
}
