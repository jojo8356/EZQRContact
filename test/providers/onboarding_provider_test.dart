import 'package:flutter_test/flutter_test.dart';
import 'package:qr_code_app/providers/onboarding_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('isDone returns false when key not set', () async {
    expect(await OnboardingProvider.isDone(), isFalse);
  });

  test('isDone returns true after markDone', () async {
    await OnboardingProvider.markDone();
    expect(await OnboardingProvider.isDone(), isTrue);
  });

  test('isDone returns true when key is already set', () async {
    SharedPreferences.setMockInitialValues({'onboarding_done': true});
    expect(await OnboardingProvider.isDone(), isTrue);
  });
}
