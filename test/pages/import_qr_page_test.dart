import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_code_app/components/btn.animated.dart';
import 'package:qr_code_app/pages/import_qr_page.dart';
import 'package:qr_code_app/providers/lang_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await LangProvider.init(lang: 'en');
  });

  group('QrFromImagePage — rendering', () {
    testWidgets('page renders without throwing inside MaterialApp',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: QrFromImagePage()),
      );
      await tester.pumpAndSettle();
      expect(find.byType(QrFromImagePage), findsOneWidget);
    });

    testWidgets('AnimatedSubmitButton is present in the widget tree',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: QrFromImagePage()),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AnimatedSubmitButton), findsOneWidget);
    });

    testWidgets('button is enabled by default (_processing starts false)',
        (tester) async {
      // pickAndDecodeImage is gated by _processing; when false the button's
      // onPressed is non-null (enabled). We verify the initial UI state
      // without invoking the platform image picker.
      await tester.pumpWidget(
        const MaterialApp(home: QrFromImagePage()),
      );
      await tester.pumpAndSettle();

      final btn = tester.widget<AnimatedSubmitButton>(
        find.byType(AnimatedSubmitButton),
      );
      expect(btn.onPressed, isNotNull);
    });
  });
}
