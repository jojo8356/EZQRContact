import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// House rule: no `cond ? a : b` ternary operators in Dart sources.
///
/// Dart has no native `no_ternary` lint. This test is the enforcement.
/// Null-aware `??` / `?.` / `?[` and nullable types (`String?`) are
/// allowed — they are not ternaries.
void main() {
  test('Dart sources contain no ternary operators', () {
    final root = Directory.current;
    final hits = <String>[];
    for (final entity in root.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      if (_shouldSkip(entity.path)) continue;
      hits.addAll(_scanFile(entity));
    }
    expect(
      hits,
      isEmpty,
      reason: 'Ternary operators are forbidden. Use if/else.\n'
          '${hits.join('\n')}',
    );
  });
}

bool _shouldSkip(String path) {
  const skip = [
    '/.dart_tool/',
    '/build/',
    '/.git/',
    '/node_modules/',
  ];
  for (final s in skip) {
    if (path.contains(s)) return true;
  }
  if (path.endsWith('.g.dart')) return true;
  // This file documents the pattern it forbids.
  if (path.endsWith('no_ternary_test.dart')) return true;
  return false;
}

List<String> _scanFile(File file) {
  final src = file.readAsStringSync();
  final cleaned = _stripStringsAndComments(src);
  final hits = <String>[];
  var i = 0;
  final n = cleaned.length;
  while (i < n) {
    if (cleaned[i] != '?') {
      i += 1;
      continue;
    }
    final prev = i > 0 ? cleaned[i - 1] : '';
    final next = i + 1 < n ? cleaned[i + 1] : '';
    if (prev == '?' || next == '?' || next == '.' || next == '[') {
      i += 1;
      continue;
    }

    final colon = _findTernaryColon(cleaned, i + 1);
    if (colon == null) {
      i += 1;
      continue;
    }

    if (_looksLikeNullableType(cleaned, i)) {
      i += 1;
      continue;
    }

    final line = cleaned.substring(0, i).split('\n').length;
    final rel = file.path.replaceFirst('${Directory.current.path}/', '');
    hits.add('$rel:$line');
    i = colon + 1;
  }
  return hits;
}

/// Returns the index of the ternary `:` matching a `?` at [start], or null.
int? _findTernaryColon(String text, int start) {
  var depth = 0;
  for (var j = start; j < text.length; j++) {
    final ch = text[j];
    if (ch == '(' || ch == '[' || ch == '{') {
      depth += 1;
    } else if (ch == ')' || ch == ']' || ch == '}') {
      if (depth == 0) return null;
      depth -= 1;
    } else if (depth == 0 && (ch == ';' || ch == ',')) {
      return null;
    } else if (depth == 0 && ch == '?' ) {
      return null;
    } else if (depth == 0 && ch == ':') {
      return j;
    }
  }
  return null;
}

bool _looksLikeNullableType(String text, int qIndex) {
  var k = qIndex + 1;
  while (k < text.length && (text[k] == ' ' || text[k] == '\t')) {
    k += 1;
  }
  if (k < text.length && text[k] == '\n') {
    return false;
  }
  final rest = text.substring(k, k + (text.length - k).clamp(0, 80));
  final typeDecl = RegExp(
    r'^[A-Za-z_][A-Za-z0-9_]*\s+[A-Za-z_]',
  );
  if (typeDecl.hasMatch(rest)) return true;
  final typeEnd = RegExp(
    r'^[A-Za-z_][A-Za-z0-9_]*\s*[,\)>;=\]]',
  );
  if (typeEnd.hasMatch(rest)) return true;
  if (rest.startsWith(')')) return true;
  // `foo ? bar : baz` has an expression then colon — not a type.
  return false;
}

String _stripStringsAndComments(String src) {
  final out = StringBuffer();
  var i = 0;
  final n = src.length;
  while (i < n) {
    if (i + 1 < n && src[i] == '/' && src[i + 1] == '/') {
      while (i < n && src[i] != '\n') {
        out.write(' ');
        i += 1;
      }
      continue;
    }
    if (i + 1 < n && src[i] == '/' && src[i + 1] == '*') {
      out.write('  ');
      i += 2;
      while (i + 1 < n && !(src[i] == '*' && src[i + 1] == '/')) {
        out.write(src[i] == '\n' ? '\n' : ' ');
        i += 1;
      }
      if (i + 1 < n) {
        out.write('  ');
        i += 2;
      }
      continue;
    }
    if (src[i] == "'" || src[i] == '"') {
      final q = src[i];
      out.write(' ');
      i += 1;
      while (i < n) {
        if (src[i] == '\\') {
          out.write(' ');
          i += 1;
          if (i < n) {
            out.write(' ');
            i += 1;
          }
          continue;
        }
        if (src[i] == q) {
          out.write(' ');
          i += 1;
          break;
        }
        out.write(src[i] == '\n' ? '\n' : ' ');
        i += 1;
      }
      continue;
    }
    out.write(src[i]);
    i += 1;
  }
  return out.toString();
}
