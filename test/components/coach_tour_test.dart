import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_code_app/components/action_tile.dart';
import 'package:qr_code_app/components/coach_tour.dart';
import 'package:qr_code_app/components/navbar.dart';
import 'package:qr_code_app/pages/actions_list_page.dart';
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

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    CoachTour.takeReplayRequest();
    darkProv.forceSetDarkMode(false);
  });

  tearDown(() => darkProv.forceSetDarkMode(false));

  test('home tour has three steps', () {
    expect(homeCoachSteps(), hasLength(3));
  });

  test('markDone persists', () async {
    expect(await CoachTour.isDone(), isFalse);
    await CoachTour.markDone();
    expect(await CoachTour.isDone(), isTrue);
  });

  test('takeReplayRequest is one-shot', () {
    expect(CoachTour.takeReplayRequest(), isFalse);
    CoachTour.requestReplay();
    expect(CoachTour.takeReplayRequest(), isTrue);
    expect(CoachTour.takeReplayRequest(), isFalse);
  });

  testWidgets('first Home visit shows one step, Skip, progress', (
    tester,
  ) async {
    await _pumpHome(tester);

    expect(find.byKey(const Key('coach-tour')), findsOneWidget);
    expect(find.text('Your card'), findsOneWidget);
    expect(find.text('1 / 3'), findsOneWidget);
    expect(find.byKey(const Key('coach-skip')), findsOneWidget);
    expect(find.byKey(const Key('coach-next')), findsOneWidget);

    // Live UI stays underneath (not a slideshow of every control).
    expect(find.byType(ActionTile), findsNWidgets(5));
    expect(find.byType(Navbar), findsOneWidget);
  });

  testWidgets('Next walks three steps then Got it closes', (tester) async {
    await _pumpHome(tester);

    expect(find.text('Your card'), findsOneWidget);
    await tester.tap(find.byKey(const Key('coach-next')));
    await tester.pump();

    expect(find.text('Your card'), findsNothing);
    expect(find.text('Scan'), findsOneWidget);
    expect(find.text('2 / 3'), findsOneWidget);
    expect(find.byKey(const Key('coach-skip')), findsOneWidget);

    await tester.tap(find.byKey(const Key('coach-next')));
    await tester.pump();

    expect(find.text('Scan'), findsNothing);
    expect(
      find.textContaining('Hold one more than 2 seconds'),
      findsOneWidget,
    );
    expect(find.text('3 / 3'), findsOneWidget);
    expect(find.text('Got it'), findsOneWidget);

    await tester.tap(find.byKey(const Key('coach-next')));
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const Key('coach-tour')), findsNothing);
    expect(await CoachTour.isDone(), isTrue);
  });

  testWidgets('Skip dismisses and does not show again', (tester) async {
    await _pumpHome(tester);
    expect(find.byKey(const Key('coach-tour')), findsOneWidget);

    await tester.tap(find.byKey(const Key('coach-skip')));
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const Key('coach-tour')), findsNothing);
    expect(await CoachTour.isDone(), isTrue);

    await tester.pumpWidget(encreApp(home: const OptionsListPage()));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('coach-tour')), findsNothing);
  });

  testWidgets('done flag skips auto-start', (tester) async {
    SharedPreferences.setMockInitialValues({coachTourDoneKey: true});
    await _pumpHome(tester);
    expect(find.byKey(const Key('coach-tour')), findsNothing);
  });

  testWidgets('Settings replay starts the tour even if done', (tester) async {
    SharedPreferences.setMockInitialValues({coachTourDoneKey: true});
    CoachTour.requestReplay();
    await _pumpHome(tester);
    expect(find.byKey(const Key('coach-tour')), findsOneWidget);
    expect(find.text('Your card'), findsOneWidget);
  });
}

Future<void> _pumpHome(WidgetTester tester) async {
  await tester.pumpWidget(encreApp(home: const OptionsListPage()));
  await tester.pump();
  await tester.pump();
  await tester.pump();
}
