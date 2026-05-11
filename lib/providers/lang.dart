import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:qr_code_app/tools/tools.dart';

/// Singleton pour stocker les traductions et notifier l'UI
class LangProvider {

  /// Returns the singleton instance.
  factory LangProvider() => _instance;

  LangProvider._internal();
  static final LangProvider _instance = LangProvider._internal();
  static Map<String, dynamic>? _translations;
  static String _currentLang = 'en';

  /// Notifier listeners can subscribe to in order to rebuild on language
  /// changes. Holds the active language code (e.g. `'en'`, `'fr'`).
  static final ValueNotifier<String> notifier = ValueNotifier(_currentLang);

  /// Initialise la langue depuis les fichiers JSON
  static Future<void> init({String? lang}) async {
    _currentLang = lang ?? PlatformDispatcher.instance.locale.languageCode;
    await _loadTranslations(_currentLang);
    notifier.value = _currentLang; // notifier l'UI
  }

  /// 🔹 Récupère une traduction (typée String)
  static String getString(String key) {
    final value = _translations?[key];
    return value is String ? value : key;
  }

  /// 🔹 Récupère une section de traductions (typée Map)
  static Map<String, dynamic> getMap(String key) {
    final value = _translations?[key];
    return value is Map<String, dynamic> ? value : <String, dynamic>{};
  }

  /// 🔹 Récupère une traduction via un chemin pointé "a.b.c"
  static String t(String path) {
    final parts = path.split('.');
    dynamic node = _translations;
    for (final p in parts) {
      if (node is Map) {
        node = node[p];
      } else {
        return path;
      }
    }
    return node is String ? node : path;
  }

  /// 🔹 Récupère une section imbriquée via un chemin pointé "a.b.c".
  /// Retourne `<String, dynamic>{}` si une clé du chemin est absente —
  /// évite les chains de cast `(getMap('a')['b'] as Map<...>)['c'] as Map`
  /// qui throw quand une locale est partiellement traduite.
  static Map<String, dynamic> section(String path) {
    final parts = path.split('.');
    dynamic node = _translations;
    for (final p in parts) {
      if (node is Map) {
        node = node[p];
      } else {
        return <String, dynamic>{};
      }
    }
    return node is Map<String, dynamic> ? node : <String, dynamic>{};
  }

  /// 🔹 Récupère une traduction (legacy, retourne dynamic)
  static dynamic get(String key) {
    return _translations?[key] ?? key;
  }

  /// 🔹 Récupère toutes les traductions
  static Future<List<String>> getAll() async {
    final files = await getJsonFiles('assets/langs');
    return files.map((f) => f.replaceAll('.json', '')).toList();
  }

  /// 🔹 Change la langue et recharge les traductions
  static Future<void> changeLanguage(String lang) async {
    _currentLang = lang;
    await _loadTranslations(lang);
    notifier.value = _currentLang; // notifier l'UI
  }

  /// 🔹 Méthode privée pour charger un fichier JSON
  static Future<void> _loadTranslations(String lang) async {
    final fileLang = 'assets/langs/$lang.json';
    final jsonString = await rootBundle.loadString(fileLang);
    _translations = json.decode(jsonString) as Map<String, dynamic>;
  }

  /// 🔹 Optionnel : récupérer la langue actuelle
  static String currentLanguage() => _currentLang;
}
