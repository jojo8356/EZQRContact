import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:qr_code_app/tools/perf.dart';
import 'package:qr_code_app/tools/tools.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Singleton pour stocker les traductions et notifier l'UI.
///
/// L'ordre de priorité pour la langue active est :
///   1. paramètre explicite `lang` passé à [init]
///   2. valeur persistée dans `SharedPreferences[_kPrefKey]`
///   3. locale du device via [PlatformDispatcher]
class LangProvider {

  /// Returns the singleton instance.
  factory() => _instance;

  new _internal();
  static final LangProvider _instance = LangProvider._internal();
  static Map<String, dynamic>? _translations;
  static String _currentLang = 'en';

  /// Clé `SharedPreferences` qui stocke l'override manuel de la langue.
  /// Absente → auto-détection device. Présente → respecter le choix user.
  static const String _kPrefKey = 'lang_override';

  /// Langue de secours si le bundle ne contient pas le pack demandé.
  static const String _kFallbackLang = 'en';

  /// Notifier listeners can subscribe to in order to rebuild on language
  /// changes. Holds the active language code (e.g. `'en'`, `'fr'`).
  static final ValueNotifier<String> notifier = ValueNotifier(_currentLang);

  /// Initialise la langue depuis les fichiers JSON.
  static Future<void> init({String? lang}) async {
    var resolved = lang;
    if (resolved == null) {
      final prefs = await SharedPreferences.getInstance();
      resolved = prefs.getString(_kPrefKey)
          ?? WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    }
    _currentLang = resolved;
    await _loadTranslations(_currentLang);
    notifier.value = _currentLang;
  }

  /// 🔹 Récupère une traduction (typée String)
  static String getString(String key) {
    final value = _translations?[key];
    if (value is String) {
      return value;
    }
    return key;
  }

  /// 🔹 Récupère une section de traductions (typée Map)
  static Map<String, dynamic> getMap(String key) {
    final value = _translations?[key];
    if (value is Map<String, dynamic>) {
      return value;
    }
    return <String, dynamic>{};
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
    if (node is String) {
      return node;
    }
    return path;
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
    if (node is Map<String, dynamic>) {
      return node;
    }
    return <String, dynamic>{};
  }

  /// 🔹 Récupère une traduction (legacy, retourne dynamic)
  static dynamic get(String key) {
    return _translations?[key] ?? key;
  }

  /// 🔹 Récupère toutes les traductions
  static Future<List<String>> getAll() async {
    final files = await Perf.measure(
      'lang.getAll (AssetManifest)',
      () => getJsonFiles('assets/langs'),
    );
    return files.map((f) => f.replaceAll('.json', '')).toList();
  }

  /// 🔹 Change la langue, recharge les traductions, persiste l'override.
  static Future<void> changeLanguage(String lang) async {
    _currentLang = lang;
    await _loadTranslations(lang);
    final prefs = await SharedPreferences.getInstance();
    // Persist _currentLang (not the arg) — _loadTranslations may have
    // overridden it to the fallback if lang was not a bundled locale.
    await prefs.setString(_kPrefKey, _currentLang);
    notifier.value = _currentLang;
  }

  /// Supprime tout override manuel et rebascule sur la locale device.
  static Future<void> resetToDeviceLocale() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kPrefKey);
    _currentLang =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    await _loadTranslations(_currentLang);
    notifier.value = _currentLang;
  }

  /// 🔹 Méthode privée pour charger un fichier JSON.
  ///
  /// Si le pack demandé n'est pas bundlé (ex. locale device `de` ou pref
  /// corrompue `zz`), fallback silencieux sur [_kFallbackLang] pour éviter
  /// un crash au démarrage.
  static Future<void> _loadTranslations(String lang) async {
    Perf.start('lang.loadTranslations ($lang)');
    var code = lang;
    final bundled = await getJsonFiles('assets/langs');
    final names = <String>{
      for (final file in bundled) file.replaceAll('.json', ''),
    };
    if (!names.contains(code)) {
      debugPrint(
        'LangProvider: assets/langs/$code.json is not bundled, '
        'falling back to $_kFallbackLang',
      );
      code = _kFallbackLang;
      _currentLang = _kFallbackLang;
    }
    final jsonString = await rootBundle.loadString('assets/langs/$code.json');
    _translations = json.decode(jsonString) as Map<String, dynamic>;
    Perf.end('lang.loadTranslations ($lang)');
  }

  /// 🔹 Optionnel : récupérer la langue actuelle
  static String currentLanguage() => _currentLang;
}
