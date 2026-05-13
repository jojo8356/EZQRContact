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

  static const String _kPrefKey = 'use_vcard4';
  static const String _kReciprocalKey = 'reciprocal_exchange';

  static bool _useVCard4 = false;
  static bool _reciprocalExchange = false;

  /// True quand l'utilisateur a explicitement opt-in au format vCard 4.0.
  static bool get useVCard4 => _useVCard4;

  /// True quand l'échange réciproque automatique est activé (story 5-4).
  static bool get reciprocalExchange => _reciprocalExchange;

  /// Charge les préférences depuis `SharedPreferences`. À appeler une fois
  /// au démarrage de l'app dans `main()`.
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _useVCard4 = prefs.getBool(_kPrefKey) ?? false;
    _reciprocalExchange = prefs.getBool(_kReciprocalKey) ?? false;
  }

  /// Met à jour la pref `use_vcard4` et persiste immédiatement.
  // ignore: avoid_positional_boolean_parameters — simple flag setter
  static Future<void> setUseVCard4(bool value) async {
    _useVCard4 = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kPrefKey, value);
  }

  /// Met à jour la pref `reciprocal_exchange` et persiste immédiatement.
  // ignore: avoid_positional_boolean_parameters — simple flag setter
  static Future<void> setReciprocalExchange(bool value) async {
    _reciprocalExchange = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kReciprocalKey, value);
  }
}
