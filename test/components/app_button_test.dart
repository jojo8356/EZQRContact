import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_code_app/components/app_button.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:qr_code_app/theme/tokens.dart';

import '../helpers/encre.dart';

void main() {
  const cuivre = Color(0xFFC45C26);
  const onCuivre = Color(0xFFFFF8F0);
  const ligne = Color(0xFFDDD4C6);
  const marine = Color(0xFF1F3D4D);

  setUp(() => darkProv.forceSetDarkMode(false));
  tearDown(() => darkProv.forceSetDarkMode(false));

  Material fill(WidgetTester tester) {
    return tester.widget<Material>(
      find.descendant(
        of: find.byType(AppButton),
        matching: find.byType(Material),
      ),
    );
  }

  group('AppButton.primary — DA §9.1', () {
    testWidgets('copper fill, on-button label, r-md, height 52', (
      tester,
    ) async {
      await tester.pumpWidget(
        encreApp(
          home: const Scaffold(
            body: AppButton.primary(label: 'Créer ma carte', onPressed: null),
          ),
        ),
      );

      expect(tester.getSize(find.byType(AppButton)).height, AppTokens.buttonH);

      final material = fill(tester);
      expect(material.color, cuivre);
      final shape = material.shape! as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(AppTokens.rMd));

      final text = tester.widget<Text>(find.text('Créer ma carte'));
      expect(text.style?.color, onCuivre);
    });

    testWidgets('press scale is 0.98, never a 1.1 punch', (tester) async {
      await tester.pumpWidget(
        encreApp(
          home: Scaffold(
            body: AppButton.primary(label: 'Scanner', onPressed: () {}),
          ),
        ),
      );

      final gesture = await tester.press(find.byType(AppButton));
      await tester.pump();
      final scale = tester.widget<AnimatedScale>(find.byType(AnimatedScale));
      expect(scale.scale, AppTokens.pressScale);
      expect(scale.duration, AppTokens.tMicro);
      await gesture.up();
    });
  });

  group('AppButton.secondary — DA §9.2', () {
    testWidgets('transparent fill, hairline border, ink label', (tester) async {
      await tester.pumpWidget(
        encreApp(
          home: const Scaffold(
            body: AppButton.secondary(label: 'Plus tard', onPressed: null),
          ),
        ),
      );

      final material = fill(tester);
      expect(material.color, Colors.transparent);
      final shape = material.shape! as RoundedRectangleBorder;
      expect(shape.side.color, ligne);
      expect(shape.borderRadius, BorderRadius.circular(AppTokens.rMd));
    });
  });

  group('AppButton.ghost — DA §9.3', () {
    testWidgets('no chrome, navy label', (tester) async {
      await tester.pumpWidget(
        encreApp(
          home: const Scaffold(
            body: AppButton.ghost(label: 'Collection', onPressed: null),
          ),
        ),
      );

      final material = fill(tester);
      expect(material.color, Colors.transparent);
      final shape = material.shape! as RoundedRectangleBorder;
      expect(shape.side, BorderSide.none);

      final text = tester.widget<Text>(find.text('Collection'));
      expect(text.style?.color, marine);
    });
  });
}
