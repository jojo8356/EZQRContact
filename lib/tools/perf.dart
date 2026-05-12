import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';

/// Micro-utilitaire de profiling. Actif uniquement en debug/profile.
///
/// Usage simple :
///   Perf.start('db.getAllVCards');
///   ...
///   Perf.end('db.getAllVCards');
///
/// Usage inline :
///   final result = await Perf.measure('db.getAllVCards', () => repo.getAll());
class Perf {
  Perf._();

  static final _watches = <String, Stopwatch>{};
  static final _nested = <String, int>{};

  /// Démarre un chrono nommé [tag].
  static void start(String tag) {
    if (!kDebugMode && !kProfileMode) return;
    _watches[tag] = Stopwatch()..start();
    final depth = _nested.update(tag, (v) => v + 1, ifAbsent: () => 0);
    dev.Timeline.startSync(tag, arguments: {'depth': depth});
  }

  /// Arrête le chrono [tag] et loggue le résultat.
  static void end(String tag) {
    if (!kDebugMode && !kProfileMode) return;
    dev.Timeline.finishSync();
    final sw = _watches.remove(tag);
    _nested.remove(tag);
    if (sw == null) return;
    sw.stop();
    final ms = sw.elapsedMicroseconds / 1000;
    debugPrint('[PERF] ${ms.toStringAsFixed(1).padLeft(8)} ms  $tag');
  }

  /// Mesure [fn] et retourne son résultat.
  static Future<T> measure<T>(String tag, Future<T> Function() fn) async {
    start(tag);
    try {
      return await fn();
    } finally {
      end(tag);
    }
  }

  /// Mesure [fn] synchrone.
  static T measureSync<T>(String tag, T Function() fn) {
    start(tag);
    try {
      return fn();
    } finally {
      end(tag);
    }
  }

  /// Loggue un événement ponctuel sans chrono (ex: fin d'un setState).
  static void mark(String tag) {
    if (!kDebugMode && !kProfileMode) return;
    dev.Timeline.instantSync(tag);
    debugPrint('[PERF] ──────────────────── $tag');
  }
}
