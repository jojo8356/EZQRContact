import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_code_app/components/app_button.dart';
import 'package:qr_code_app/components/paper_card.dart';
import 'package:qr_code_app/pages/import_qr_page.dart';
import 'package:qr_code_app/providers/lang_provider.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/encre.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await LangProvider.init(lang: 'en');
  });

  setUp(() => darkProv.forceSetDarkMode(false));
  tearDown(() => darkProv.forceSetDarkMode(false));

  group('QrFromImagePage — rendering', () {
    testWidgets('page renders without throwing inside MaterialApp',
        (tester) async {
      await tester.pumpWidget(encreApp(home: const QrFromImagePage()));
      await tester.pumpAndSettle();
      expect(find.byType(QrFromImagePage), findsOneWidget);
    });

    testWidgets('ENCRE paper card + primary copper AppButton', (tester) async {
      await tester.pumpWidget(encreApp(home: const QrFromImagePage()));
      await tester.pumpAndSettle();
      expect(find.byType(PaperCard), findsOneWidget);
      expect(find.byType(AppButton), findsOneWidget);

      final btn = tester.widget<AppButton>(find.byType(AppButton));
      expect(btn.variant, AppButtonVariant.primary);
      expect(btn.onPressed, isNotNull);

      final material = tester.widget<Material>(
        find.descendant(
          of: find.byType(AppButton),
          matching: find.byType(Material),
        ),
      );
      expect(material.color, const Color(0xFFC45C26));
    });
  });
}
