import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Global test harness. Flutter runs this before every file under `test/`.
///
/// - sqflite FFI so `getDatabasesPath()` works on desktop (no Android/iOS
///   plugin). Migration backup then no-ops quietly instead of throwing.
/// - Data tests open an in-memory DB via `openTestDb()`. Multiple
///   `QRDatabase` instances in one process are expected and silenced.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  await testMain();
}
