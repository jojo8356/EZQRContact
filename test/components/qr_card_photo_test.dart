import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_code_app/components/qr_card.dart';
import 'package:qr_code_app/data/db/database.dart';
import 'package:qr_code_app/providers/lang_provider.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:qr_code_app/tools/contacts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/encre.dart';
import '../helpers/test_db.dart';

/// 1×1 PNG — same bytes a device contact photo would carry.
const _tinyPng = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x02, 0x00, 0x00, 0x00, 0x90, 0x77, 0x53, 0xDE, 0x00, 0x00, 0x00,
  0x0C, 0x49, 0x44, 0x41, 0x54, 0x08, 0xD7, 0x63, 0xF8, 0xCF, 0xC0, 0x00,
  0x00, 0x00, 0x03, 0x00, 0x01, 0x00, 0x05, 0xFE, 0xD4, 0xEF, 0x00, 0x00,
  0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
];

Contact _deviceContactWithPhoto() {
  return Contact(
    id: 'os-42',
    displayName: 'Marie Dupont',
    name: const Name(first: 'Marie', last: 'Dupont'),
    photo: Photo(fullSize: Uint8List.fromList(_tinyPng)),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late QRDatabase db;
  late Directory tempDir;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await LangProvider.init(lang: 'en');
  });

  setUp(() async {
    darkProv.forceSetDarkMode(false);
    db = openTestDb();
    tempDir = await Directory.systemTemp.createTemp('qr_photo_import_');
  });

  tearDown(() async {
    darkProv.forceSetDarkMode(false);
    await db.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  testWidgets(
    'importing a device contact with a photo shows it on the card',
    (tester) async {
      final device = _deviceContactWithPhoto();
      final maps = PhoneContacts.toMapList([device]);
      expect(maps, hasLength(1));
      expect(
        (maps.first['photo'] as String).startsWith('data:image/png;base64,'),
        isTrue,
      );

      final ids = await createVCardsBatch(
        maps,
        db: db,
        baseDir: tempDir.path,
      );
      expect(ids, hasLength(1));

      final stored = await db.getVCardById(ids.first);
      expect(stored, isNotNull);
      final photo = stored!['photo'] as String;
      expect(photo.startsWith('data:image/png;base64,'), isTrue);
      final bytes = base64Decode(
        photo.substring('data:image/png;base64,'.length),
      );
      expect(bytes, _tinyPng);

      await tester.pumpWidget(
        encreApp(
          home: Scaffold(
            body: QRCard(
              isVCard: true,
              data: stored,
              onRefresh: () async {},
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Marie Dupont'), findsOneWidget);
      expect(find.byIcon(Icons.person_rounded), findsNothing);
      expect(find.byType(Image), findsOneWidget);
      final image = tester.widget<Image>(find.byType(Image));
      expect(image.image, isA<MemoryImage>());
      final mem = image.image as MemoryImage;
      expect(mem.bytes, Uint8List.fromList(_tinyPng));
    },
  );

  testWidgets(
    'a vCard without a photo still shows the person well',
    (tester) async {
      await tester.pumpWidget(
        encreApp(
          home: Scaffold(
            body: QRCard(
              isVCard: true,
              data: const {
                'id': 1,
                'prenom': 'Jean',
                'nom': 'Martin',
                'photo': '',
              },
              onRefresh: () async {},
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.person_rounded), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    },
  );
}
