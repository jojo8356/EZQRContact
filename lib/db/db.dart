import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class QRDatabase {
  // Singleton
  static final QRDatabase _instance = QRDatabase._internal();
  factory QRDatabase() => _instance;
  QRDatabase._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'qr_app.db'),
      version: 1,
      onCreate: (db, version) async {
        // Table SimpleQR
        await db.execute('''
          CREATE TABLE SimpleQR(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            text TEXT NOT NULL,
            path TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE VCard(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nom TEXT,
            prenom TEXT,
            nom2 TEXT,
            prefixe TEXT,
            suffixe TEXT,
            org TEXT,
            job TEXT,
            photo TEXT,
            tel_work TEXT,
            tel_home TEXT,
            adr_work TEXT,
            adr_home TEXT,
            email TEXT,
            rev TEXT,
            path TEXT
          )
        ''');
      },
    );
  }

  // Exemple d'insert dans SimpleQR
  Future<int> insertSimpleQR(String text, String? path) async {
    final db = await database;
    return db.insert('SimpleQR', {'text': text, 'path': path});
  }

  // Exemple d'insert dans VCard
  Future<int> insertVCard(Map<String, dynamic> data) async {
    final db = await database;
    return db.insert('VCard', data);
  }

  Future<List<Map<String, dynamic>>> getAllSimpleQR() async {
    final db = await database;
    return db.query('SimpleQR', orderBy: 'id DESC');
  }

  Future<List<Map<String, dynamic>>> getAllVCards() async {
    final db = await database;
    return db.query('VCard', orderBy: 'id DESC');
  }

  Future<void> deleteSimpleQR(int id) async {
    final db = await database;
    final result = await db.query('SimpleQR', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      final path = result.first['path'] as String?;
      if (path != null && File(path).existsSync()) {
        File(path).deleteSync(); // supprime le fichier QR
      }
    }
    await db.delete('SimpleQR', where: 'id = ?', whereArgs: [id]);
  }

  // Supprimer VCard
  Future<void> deleteVCard(int id) async {
    final db = await database;
    final result = await db.query('VCard', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      final path = result.first['path'] as String?;
      if (path != null && File(path).existsSync()) {
        File(path).deleteSync(); // supprime le fichier QR
      }
    }
    await db.delete('VCard', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateVCardPath(int id, String path) async {
    final db = await database;
    return db.update('VCard', {'path': path}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateSimpleQRPath(int id, String path) async {
    if (kDebugMode) {
      print(path);
    }
    final db = await database;
    await db.update(
      'simpleQR',
      {'path': path},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

Future<void> deleteQR(bool isVCard, int id) async {
  if (isVCard) {
    await QRDatabase().deleteVCard(id);
  } else {
    await QRDatabase().deleteSimpleQR(id);
  }
}

Future<int> createSimpleQR(String txt) async {
  final id = await QRDatabase().insertSimpleQR(txt, null);
  final directory = await getApplicationDocumentsDirectory();
  final path = '${directory.path}/$id.png';
  await QRDatabase().updateSimpleQRPath(id, path);
  return id;
}

Future<int> createVCard(vcardData) async {
  final id = await QRDatabase().insertVCard(vcardData);
  final directory = await getApplicationDocumentsDirectory();
  final path = '${directory.path}/$id.png';
  await QRDatabase().updateVCardPath(id, path);
  return id;
}
