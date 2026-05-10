import 'package:drift/drift.dart';
import 'package:drift_sqflite/drift_sqflite.dart';

import 'package:qr_code_app/data/db/tables/events.dart';
import 'package:qr_code_app/data/db/tables/simple_qrs.dart';
import 'package:qr_code_app/data/db/tables/vcards.dart';

part 'database.g.dart';

@DriftDatabase(tables: [SimpleQRs, VCards, Events])
class QRDatabaseV2 extends _$QRDatabaseV2 {
  QRDatabaseV2()
      : super(
          SqfliteQueryExecutor.inDatabaseFolder(
            path: 'qr_app.db',
            singleInstance: true,
          ),
        );

  @override
  int get schemaVersion => 1;
}
