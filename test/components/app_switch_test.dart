import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_code_app/components/app_switch.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:qr_code_app/theme/app_theme.dart';
import 'package:qr_code_app/theme/tokens.dart';

import '../helpers/encre.dart';

void main() {
  const cuivre = Color(0xFFC45C26);
  const sable = Color(0xFFEBE4D8);

  setUp(() => darkProv.forceSetDarkMode(false));
  tearDown(() => darkProv.forceSetDarkMode(false));

  testWidgets('AppSwitch is 52×32 — DA §9.9', (tester) async {
    await tester.pumpWidget(
      encreApp(
        home: const Scaffold(
          body: AppSwitch(value: false, onChanged: null),
        ),
      ),
    );
    expect(tester.getSize(find.byType(AppSwitch)), const Size(52, 32));
  });

  testWidgets('off shows close, on shows check', (tester) async {
    await tester.pumpWidget(
      encreApp(
        home: const Scaffold(
          body: Column(
            children: [
              AppSwitch(value: false, onChanged: null),
              AppSwitch(value: true, onChanged: null),
            ],
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('on track uses copper, off track uses sable', (tester) async {
    await tester.pumpWidget(
      encreApp(
        home: const Scaffold(
          body: Column(
            children: [
              AppSwitch(key: Key('off'), value: false, onChanged: null),
              AppSwitch(key: Key('on'), value: true, onChanged: null),
            ],
          ),
        ),
      ),
    );

    DecoratedBox boxOf(Key key) {
      return tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byKey(key),
          matching: find.byType(DecoratedBox),
        ),
      );
    }

    final offDeco = boxOf(const Key('off')).decoration as BoxDecoration;
    final onDeco = boxOf(const Key('on')).decoration as BoxDecoration;
    expect(offDeco.color, sable);
    expect(onDeco.color, cuivre);
  });

  testWidgets('tap notifies onChanged', (tester) async {
    final value = ValueNotifier<bool>(false);
    addTearDown(value.dispose);

    await tester.pumpWidget(
      encreApp(
        home: Scaffold(
          body: ValueListenableBuilder<bool>(
            valueListenable: value,
            builder: (context, on, _) {
              return AppSwitch(
                value: on,
                onChanged: (next) => value.value = next,
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byType(AppSwitch));
    await tester.pump();
    expect(value.value, isTrue);
  });

  testWidgets('default duration is t-med (300 ms)', (tester) async {
    await tester.pumpWidget(
      encreApp(
        home: const Scaffold(
          body: AppSwitch(value: false, onChanged: null),
        ),
      ),
    );
    final sw = tester.widget<AppSwitch>(find.byType(AppSwitch));
    expect(sw.duration, AppTokens.tMed);
  });

  test('ENCRE theme switch track is copper when selected', () {
    final theme = buildAppTheme(colors: currentColors, isDark: false);
    final onColor = theme.switchTheme.trackColor!.resolve({
      WidgetState.selected,
    });
    expect(onColor, cuivre);
  });
}
