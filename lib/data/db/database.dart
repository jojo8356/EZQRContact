import 'package:drift/drift.dart';
import 'package:drift_sqflite/drift_sqflite.dart';

import 'package:qr_code_app/data/db/tables/events.dart';
import 'package:qr_code_app/data/db/tables/simple_qrs.dart';
import 'package:qr_code_app/data/db/tables/vcards.dart';

part 'database.g.dart';

@DriftDatabase(tables: [SimpleQRs, VCards, Events])
class QRDatabaseV2 extends _$QRDatabaseV2 {
  /// Production constructor, opens (or creates) qr_app.db via sqflite.
  QRDatabaseV2()
      : super(
          SqfliteQueryExecutor.inDatabaseFolder(
            path: 'qr_app.db',
            singleInstance: true,
          ),
        );

  /// Test-only constructor. Inject any [QueryExecutor], typically
  /// `NativeDatabase.memory()` from `package:drift/native.dart` for an
  /// in-memory SQLite database isolated per test.
  QRDatabaseV2.forTesting(super.executor);

  @override
  int get schemaVersion => 1;
}
