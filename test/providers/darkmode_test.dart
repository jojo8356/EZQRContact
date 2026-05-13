import 'package:flutter_test/flutter_test.dart';
import 'package:qr_code_app/providers/darkmode.dart';

void main() {
  // Required so that Ticker.start() can access SchedulerBinding.instance.
  TestWidgetsFlutterBinding.ensureInitialized();

  final provider = DarkModeProvider();

  setUp(() {
    provider.setDarkMode(false);
  });

  group('DarkModeProvider — initial state', () {
    test('isDarkMode is false by default', () {
      expect(provider.isDarkMode, isFalse);
    });
  });

  group('DarkModeProvider — toggle', () {
    test('toggle() flips false to true', () {
      provider.toggle();
      expect(provider.isDarkMode, isTrue);
    });

    test('toggle() twice returns to false', () {
      provider
        ..toggle()
        ..toggle();
      expect(provider.isDarkMode, isFalse);
    });

    test('toggle() calls notifyListeners', () {
      var notified = false;
      void listener() => notified = true;
      provider.addListener(listener);
      addTearDown(() => provider.removeListener(listener));

      provider.toggle();
      expect(notified, isTrue);
    });
  });

  group('DarkModeProvider — setDarkMode', () {
    test('setDarkMode(true) sets isDarkMode to true', () {
      provider.setDarkMode(true);
      expect(provider.isDarkMode, isTrue);
    });

    test('setDarkMode(false) sets isDarkMode to false', () {
      provider
        ..setDarkMode(true)
        ..setDarkMode(false);
      expect(provider.isDarkMode, isFalse);
    });

    test('setDarkMode(true) calls notifyListeners', () {
      var notified = false;
      void listener() => notified = true;
      provider.addListener(listener);
      addTearDown(() => provider.removeListener(listener));

      provider.setDarkMode(true);
      expect(notified, isTrue);
    });
  });
}
