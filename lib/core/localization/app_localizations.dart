import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  Map<String, String>? _translations;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'), Locale('tr'), Locale('es'), Locale('fr'),
    Locale('de'), Locale('ru'), Locale('pt'), Locale('ar'), Locale('zh'),
  ];

  Future<void> load() async {
    final code = locale.languageCode;
    try {
      final jsonStr = await rootBundle.loadString('assets/lang/$code.json');
      _translations = Map<String, String>.from(json.decode(jsonStr) as Map);
    } catch (_) {
      _translations = {};
    }
  }

  String? tr(String key) => _translations?[key];

  String translate(String key, {String? fallback}) {
    return _translations?[key] ?? fallback ?? key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales.any((l) => l.languageCode == locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
