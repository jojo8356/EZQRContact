import 'package:drift/native.dart';
import 'package:qr_code_app/data/db/database.dart';

/// Opens an isolated in-memory [QRDatabase] for a single test.
///
/// Never writes `qr_app.db`. Caller must `await db.close()` in tearDown.
QRDatabase openTestDb() {
  return QRDatabase.forTesting(NativeDatabase.memory());
}
