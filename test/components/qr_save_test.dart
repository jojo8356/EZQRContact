import 'package:flutter_test/flutter_test.dart';
import 'package:qr_code_app/components/qr_save.dart';
import 'package:qr_code_app/providers/lang_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await LangProvider.init(lang: 'en');
  });

  group('saveQrCode — QR validation', () {
    test('payload exceeding QR max capacity throws Exception', () async {
      final oversized = 'x' * 3000;
      await expectLater(
        () => saveQrCode(oversized, 1),
        throwsA(isA<Exception>()),
      );
    });

    test('thrown message for oversized payload is a non-empty string',
        () async {
      final oversized = 'x' * 3000;
      try {
        await saveQrCode(oversized, 1);
        fail('Expected an exception to be thrown');
      } on Exception catch (e) {
        expect(e.toString(), isNotEmpty);
      }
    });

    test('valid short payload passes QR validation', () async {
      // saveQrCode will pass validation but then fail when attempting to
      // access the file system (MissingPluginException / PathProviderException
      // in the unit-test environment). An error containing 'invalid qr' would
      // mean validation itself failed — that must not happen for 'hello'.
      try {
        await saveQrCode('hello', 1);
        // Reaching here means both validation and FS succeeded, which is fine.
      } on Exception catch (e) {
        // A MissingPluginException or PathNotFoundException means validation
        // passed but the FS layer is unavailable in unit tests. Acceptable.
        // A QR-validation failure would contain the 'invalid qr' literal.
        expect(e.toString(), isNot(contains('invalid qr')));
      }
    });
  });
}
