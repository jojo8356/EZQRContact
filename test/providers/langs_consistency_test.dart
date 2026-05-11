import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Lang assets consistency', () {
    test('fr.json and en.json have identical leaf-path sets (AC-5)', () async {
      final fr = await _loadJson('fr');
      final en = await _loadJson('en');

      final frPaths = _leafPaths(fr);
      final enPaths = _leafPaths(en);

      final missingInEn = frPaths.difference(enPaths);
      final missingInFr = enPaths.difference(frPaths);

      expect(
        missingInEn,
        isEmpty,
        reason: 'Paths in fr.json but missing in en.json: $missingInEn',
      );
      expect(
        missingInFr,
        isEmpty,
        reason: 'Paths in en.json but missing in fr.json: $missingInFr',
      );
    });

    test(
      'Every LangProvider key used in lib/ exists in both JSONs (AC-6)',
      () async {
        final fr = await _loadJson('fr');
        final en = await _loadJson('en');

        final usages = _collectLangUsages(Directory('lib'));
        final missing = <String>[];

        for (final usage in usages) {
          if (!_resolves(fr, usage.path, leafKind: usage.kind)) {
            missing.add('${usage.location}: "${usage.path}" missing in fr');
          }
          if (!_resolves(en, usage.path, leafKind: usage.kind)) {
            missing.add('${usage.location}: "${usage.path}" missing in en');
          }
        }

        expect(
          missing,
          isEmpty,
          reason: 'Orphan i18n keys:\n${missing.join('\n')}',
        );
      },
    );
  });
}

Future<Map<String, dynamic>> _loadJson(String lang) async {
  final raw = await rootBundle.loadString('assets/langs/$lang.json');
  return json.decode(raw) as Map<String, dynamic>;
}

Set<String> _leafPaths(Map<String, dynamic> map, [String prefix = '']) {
  final result = <String>{};
  map.forEach((key, value) {
    final path = prefix.isEmpty ? key : '$prefix.$key';
    if (value is Map<String, dynamic>) {
      result.addAll(_leafPaths(value, path));
    } else {
      result.add(path);
    }
  });
  return result;
}

/// Kind of node a usage path should resolve to.
/// - `string`: must terminate on a String (e.g. `t()`, `getString()`)
/// - `map`: must terminate on a Map (e.g. `getMap()`, `section()`)
enum _Kind { string, map }

class _Usage {
  _Usage(this.path, this.kind, this.location);
  final String path;
  final _Kind kind;
  final String location;
}

/// Walks every `.dart` file under [root] and extracts explicit
/// `LangProvider.<method>('arg')` call sites. Local-variable accesses like
/// `final lang = LangProvider.getMap('x'); lang['y']` are NOT analyzed —
/// AST-free regex covers the top-level path only, which is enough for
/// orphan detection (a missing top-level path means every `lang[*]` access
/// fails too).
List<_Usage> _collectLangUsages(Directory root) {
  final results = <_Usage>[];
  // method → kind expected at the resolved path
  final methodKind = <String, _Kind>{
    't': _Kind.string,
    'getString': _Kind.string,
    'getMap': _Kind.map,
    'section': _Kind.map,
    'get': _Kind.string,
  };
  final pattern = RegExp(
    r'''LangProvider\.(t|getString|getMap|section|get)\(\s*['"]([^'"]+)['"]\s*\)''',
  );

  for (final entity in root.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    final content = entity.readAsStringSync();
    final lines = content.split('\n');
    for (var i = 0; i < lines.length; i++) {
      for (final match in pattern.allMatches(lines[i])) {
        final method = match.group(1)!;
        final path = match.group(2)!;
        final kind = methodKind[method]!;
        results.add(_Usage(path, kind, '${entity.path}:${i + 1}'));
      }
    }
  }
  return results;
}

bool _resolves(
  Map<String, dynamic> map,
  String path, {
  required _Kind leafKind,
}) {
  final parts = path.split('.');
  dynamic node = map;
  for (final p in parts) {
    if (node is Map<String, dynamic>) {
      if (!node.containsKey(p)) return false;
      node = node[p];
    } else {
      return false;
    }
  }
  return switch (leafKind) {
    _Kind.string => node is String,
    _Kind.map => node is Map<String, dynamic>,
  };
}
