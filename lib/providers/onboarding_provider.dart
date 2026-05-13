import 'package:shared_preferences/shared_preferences.dart';

/// Checks and manages the onboarding completion state.
abstract class OnboardingProvider {
  static const _key = 'onboarding_done';

  /// Returns true when the user has already completed onboarding.
  static Future<bool> isDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  /// Marks onboarding as completed.
  static Future<void> markDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}
