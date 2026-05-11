import 'package:shared_preferences/shared_preferences.dart';

/// Singleton statique exposant les préférences de génération vCard.
///
/// La seule pref pour l'instant est [useVCard4] (`false` par défaut) qui
/// permet de forcer la génération en vCard 4.0 plutôt que 3.0. Le défaut
/// 3.0 est aligné avec la story 2.1 : `vCard 3.0` reste le format le plus
/// compatible (iOS Contacts, Google Contacts, Outlook).
class VCardSettingsProvider {

  /// Returns the singleton instance.
  factory VCardSettingsProvider() => _instance;

  VCardSettingsProvider._internal();
  static final VCardSettingsProvider _instance =
      VCardSettingsProvider._internal();

  /// Clé `SharedPreferences` qui stocke le toggle vCard 4.0.
  /// Absente → 3.0 (défaut). Présente et `true` → 4.0.
  static const String _kPrefKey = 'use_vcard4';

  static bool _useVCard4 = false;

  /// True quand l'utilisateur a explicitement opt-in au format vCard 4.0.
  /// Lecture synchrone après [init].
  static bool get useVCard4 => _useVCard4;

  /// Charge l'état depuis `SharedPreferences`. Doit être appelé une fois au
  /// démarrage de l'app (typiquement dans `main()`, à côté de
  /// `LangProvider.init()`). Aucun side-effect réseau ou disque autre que
  /// `SharedPreferences.getInstance()`.
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _useVCard4 = prefs.getBool(_kPrefKey) ?? false;
  }

  /// Met à jour la pref `use_vcard4` et persiste immédiatement. Le getter
  /// [useVCard4] reflète la nouvelle valeur sans attendre un redémarrage.
  // ignore: avoid_positional_boolean_parameters
  static Future<void> setUseVCard4(bool value) async {
    _useVCard4 = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kPrefKey, value);
  }
}
