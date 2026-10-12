import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// House rule: display `return`s are widget trees only.
///
/// Algorithms live above the return (locals / if-else) or inside a
/// dedicated component. Immediately-invoked closures `() { ... }()`
/// in pages, components, modals, theme and `main.dart` are forbidden.
///
/// Allowed in the tree: widgets, components, collection-if of widgets,
/// event callbacks (`onTap: () { ... }`, not invoked).
void main() {
  test('display sources contain no IIFE () { ... }()', () {
    final hits = <String>[];
    const roots = [
      'lib/pages',
      'lib/components',
      'lib/modals',
      'lib/theme',
      'lib/main.dart',
    ];
    for (final root in roots) {
      final entity = FileSystemEntity.typeSync(root);
      if (entity == FileSystemEntityType.file) {
        hits.addAll(_scanFile(File(root)));
        continue;
      }
      if (entity != FileSystemEntityType.directory) continue;
      for (final file in Directory(root).listSync(recursive: true)) {
        if (file is! File || !file.path.endsWith('.dart')) continue;
        hits.addAll(_scanFile(file));
      }
    }
    expect(
      hits,
      isEmpty,
      reason:
          'IIFE () { ... }() in display code is forbidden. '
          'Hoist the algorithm above the return, or extract a component.\n'
          '${hits.join('\n')}',
    );
  });
}

List<String> _scanFile(File file) {
  final src = file.readAsStringSync();
  final hits = <String>[];
  final lines = src.split('\n');
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    final trimmed = line.trimLeft();
    if (trimmed.startsWith('//') || trimmed.startsWith('*')) continue;
    if (line.contains('}()')) {
      final rel = file.path.replaceFirst('${Directory.current.path}/', '');
      hits.add('$rel:${i + 1}');
    }
  }
  return hits;
}
