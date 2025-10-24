import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:qr_code_app/tools/tools.dart';

/// Singleton pour stocker les traductions et notifier l'UI
class LangProvider {
  static final LangProvider _instance = LangProvider._internal();
  static Map<String, dynamic>? _translations;
  static String _currentLang = 'en';

  // 🔹 Notifier pour prévenir l'UI
  static final ValueNotifier<String> notifier = ValueNotifier(_currentLang);

  LangProvider._internal();

  factory LangProvider() => _instance;

  /// Initialise la langue depuis les fichiers JSON
  static Future<void> init({String? lang}) async {
    _currentLang = lang ?? PlatformDispatcher.instance.locale.languageCode;
    await _loadTranslations(_currentLang);
    notifier.value = _currentLang; // notifier l'UI
  }

  /// 🔹 Récupère une traduction
  static get(String key) {
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
