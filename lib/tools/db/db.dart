import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_code_app/tools/contacts.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:collection/collection.dart';

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
            path TEXT,
            clone INTEGER
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
      final isCloned = await isClone(id); // ✅ Appel sur QRDatabase

      if (path != null && File(path).existsSync() && !isCloned) {
        File(path).deleteSync(); // Supprime le fichier uniquement si pas clone
      }
    }

    await db.delete('VCard', where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> isClone(int id) async {
    final db = await database;

    final result = await db.query(
      'VCard',
      columns: ['clone'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isNotEmpty) {
      final cloneValue = result.first['clone'];
      return cloneValue == 1;
    }

    throw Exception("VCard avec id $id introuvable");
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

  Future<String?> getPathFromSimpleQR(int id) async {
    final db = await database;
    final result = await db.query(
      'SimpleQR',
      columns: ['path'],
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return result.first['path'] as String?;
    }
    return null;
  }

  Future<String?> getPathFromVCard(int id) async {
    final db = await database;
    final result = await db.query(
      'VCard',
      columns: ['path'],
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return result.first['path'] as String?;
    }
    return null;
  }

  Future<Map<String, dynamic>?> getVCardById(int id) async {
    final db = await database;

    final results = await db.query(
      'VCard',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  Future<Map<String, dynamic>?> verifContact({
    String? nom,
    String? prenom,
  }) async {
    final db = await database;

    if (nom == null && prenom == null) return null;

    String where = '';
    List<String> whereArgs = [];

    if (nom != null && prenom != null) {
      where = 'nom = ? AND prenom = ?';
      whereArgs = [nom, prenom];
    } else if (nom != null) {
      where = 'nom = ?';
      whereArgs = [nom];
    } else if (prenom != null) {
      where = 'prenom = ?';
      whereArgs = [prenom];
    }

    final results = await db.query(
      'VCard',
      where: where,
      whereArgs: whereArgs,
      limit: 1,
    );

    if (results.isNotEmpty) {
      return results.first;
    }

    return null;
  }

  Future<void> modifContact(newContact) async {
    final db = await database;

    final nom = newContact['nom'] as String?;
    final prenom = newContact['prenom'] as String?;

    if (nom == null || prenom == null) {
      throw Exception("Nom et prénom obligatoires pour sauvegarder un contact");
    }
    final existing = await verifContact(nom: nom, prenom: prenom);
    if (existing != null) {
      final updatedContact = Map<String, dynamic>.from(existing);
      updatedContact['id']++;
      newContact.forEach((key, value) {
        if (value != null && value.toString().isNotEmpty) {
          final oldValue = existing[key];
          if (oldValue == null || oldValue.toString().isEmpty) {
            updatedContact[key] = value;
          }
        }
      });

      await db.update(
        'VCard',
        updatedContact,
        where: 'id = ?',
        whereArgs: [existing['id']],
      );
    }
  }

  Future<int?> getLastVCardId() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT id FROM VCard ORDER BY id DESC LIMIT 1',
    );
    if (result.isNotEmpty) {
      return result.first['id'] as int?;
    }
    return 0;
  }

  Future<int> cloneVCard(int id) async {
    final db = QRDatabase();

    // Récupérer la VCard existante
    final original = await db.getVCardById(id);
    if (original == null) {
      throw Exception("VCard avec id $id introuvable");
    }

    final cloned = Map<String, dynamic>.from(original);
    cloned.remove('id');
    cloned['clone'] = 1; // 🔥 Spécial clone

    // Insérer la copie
    final newId = await db.insertVCard(cloned);

    // Générer le chemin
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$newId.jpg';
    await db.updateVCardPath(newId, path);

    return newId;
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
  final db = QRDatabase();
  final id = await db.insertSimpleQR(txt, null);
  final directory = await getApplicationDocumentsDirectory();
  final path = '${directory.path}/$id.jpg';
  await db.updateSimpleQRPath(id, path);
  return id;
}

Future<int> createVCard(Map<String, dynamic> vcardData) async {
  final db = QRDatabase();
  vcardData['clone'] = '0';
  final id = await db.insertVCard(vcardData);
  final directory = await getApplicationDocumentsDirectory();
  final path = '${directory.path}/$id.jpg';
  await db.updateVCardPath(id, path);
  return id;
}

Future<int> createContact(vcardData) async {
  await addContactToPhone(vcardData);
  return await createVCard(vcardData);
}

Future<bool> compare2VCard(dynamic vcard1, dynamic vcard2) async {
  final map1 = Map<String, dynamic>.from(vcard1)..remove('id');
  final map2 = Map<String, dynamic>.from(vcard2)..remove('id');

  return const MapEquality().equals(map1, map2);
}
