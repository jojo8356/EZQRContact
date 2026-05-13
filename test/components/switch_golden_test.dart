import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('switch — OFF vs ON thumb size', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          switchTheme: SwitchThemeData(
            thumbIcon: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const Icon(Icons.check, size: 16);
              }
              return const Icon(Icons.close, size: 16);
            }),
          ),
        ),
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  value: false,
                  onChanged: (_) {},
                  title: const Text('Format vCard 4.0  (OFF)'),
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  value: true,
                  onChanged: (_) {},
                  title: const Text('Format vCard 4.0  (ON)'),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pump();

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/switch_off_vs_on.png'),
    );
  });
}
