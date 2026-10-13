import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_code_app/components/app_button.dart';
import 'package:qr_code_app/components/paper_card.dart';
import 'package:qr_code_app/providers/lang_provider.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:qr_code_app/theme/tokens.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences flag: the home spotlight tour already ran.
const String coachTourDoneKey = 'coach_tour_done';

/// Home VCard tile.
final GlobalKey coachVcardKey = GlobalKey(debugLabel: 'coach-vcard');

/// Home scanner tile.
final GlobalKey coachScanKey = GlobalKey(debugLabel: 'coach-scan');

/// Navbar Collection item.
final GlobalKey coachCollectionKey = GlobalKey(
  debugLabel: 'coach-collection',
);

/// One spotlight step. [target] is a [GlobalKey] on the live widget.
class CoachStep {
  /// Creates a step.
  const CoachStep({
    required this.target,
    required this.title,
    required this.body,
  });

  /// Widget to cut a hole around.
  final GlobalKey target;

  /// Short heading (one line).
  final String title;

  /// One sentence of copy.
  final String body;
}

/// Native spotlight tour on live Home widgets. No extra package.
abstract final class CoachTour {
  static bool _replayPending = false;

  /// Settings sets this so Home starts the tour even if it already ran.
  static void requestReplay() {
    _replayPending = true;
  }

  /// Returns and clears the replay flag.
  static bool takeReplayRequest() {
    final pending = _replayPending;
    _replayPending = false;
    return pending;
  }

  /// True when the first-run spotlight already finished or was skipped.
  static Future<bool> isDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(coachTourDoneKey) ?? false;
  }

  /// Persist that the tour should not auto-start again.
  static Future<void> markDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(coachTourDoneKey, true);
  }

  /// Inserts a native spotlight overlay. Completes on skip or last Next.
  static Future<void> show(
    BuildContext context, {
    required List<CoachStep> steps,
  }) {
    if (steps.isEmpty) {
      return Future<void>.value();
    }
    final overlay = Overlay.of(context, rootOverlay: true);
    final done = Completer<void>();
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) {
        return _CoachTourLayer(
          steps: steps,
          onClose: () {
            if (entry.mounted) {
              entry.remove();
            }
            if (!done.isCompleted) {
              done.complete();
            }
          },
        );
      },
    );
    overlay.insert(entry);
    return done.future;
  }
}

/// Home tour: create, scan, collection. Max 3 steps (coach-mark research).
List<CoachStep> homeCoachSteps() {
  final lang = LangProvider.getMap('coach');
  return [
    CoachStep(
      target: coachVcardKey,
      title: (lang['vcard_title'] as String?) ?? 'Your card',
      body: (lang['vcard_body'] as String?) ??
          'Encode your contact. Anyone can scan it with their camera.',
    ),
    CoachStep(
      target: coachScanKey,
      title: (lang['scan_title'] as String?) ?? 'Scan',
      body: (lang['scan_body'] as String?) ??
          'Read a QR in front of you. Nothing is uploaded.',
    ),
    CoachStep(
      target: coachCollectionKey,
      title: (lang['collection_title'] as String?) ?? 'Collection',
      body: (lang['collection_body'] as String?) ??
          'Saved cards live here. Hold one more than 2 seconds '
              'to multi-select.',
    ),
  ];
}

class _CoachTourLayer extends StatefulWidget {
  const _CoachTourLayer({
    required this.steps,
    required this.onClose,
  });

  final List<CoachStep> steps;
  final VoidCallback onClose;

  @override
  State<_CoachTourLayer> createState() => _CoachTourLayerState();
}

class _CoachTourLayerState extends State<_CoachTourLayer> {
  var _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Rect? _holeOf(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) {
      return null;
    }
    final box = ctx.findRenderObject();
    if (box is! RenderBox || !box.hasSize) {
      return null;
    }
    final origin = box.localToGlobal(Offset.zero);
    return origin & box.size;
  }

  void _next() {
    if (_index >= widget.steps.length - 1) {
      widget.onClose();
      return;
    }
    setState(() {
      _index += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.steps[_index];
    final hole = _holeOf(step.target);
    final size = MediaQuery.sizeOf(context);
    final c = currentColors;
    final lang = LangProvider.getMap('coach');
    final progressTemplate = (lang['progress'] as String?) ?? '%s / %s';
    final progress = progressTemplate
        .replaceFirst('%s', '${_index + 1}')
        .replaceFirst('%s', '${widget.steps.length}');

    var tooltipTop = size.height * 0.45;
    if (hole != null) {
      final below = hole.bottom + AppTokens.s4;
      if (below < size.height * 0.58) {
        tooltipTop = below;
      } else {
        var above = hole.top - 180;
        if (above < AppTokens.s8) {
          above = AppTokens.s8;
        }
        tooltipTop = above;
      }
    }

    final isLast = _index >= widget.steps.length - 1;
    var nextLabel = (lang['next'] as String?) ?? 'Next';
    if (isLast) {
      nextLabel = (lang['done'] as String?) ?? 'Got it';
    }

    Rect? inflatedHole;
    if (hole != null) {
      inflatedHole = hole.inflate(AppTokens.s2);
    }

    return Material(
      key: const Key('coach-tour'),
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: AbsorbPointer(
              child: CustomPaint(
                painter: _SpotlightPainter(
                  hole: inflatedHole,
                  scrim: c['text']!.withValues(alpha: 0.55),
                  ring: c['button-color']!,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          Positioned(
            left: AppTokens.s5,
            right: AppTokens.s5,
            top: tooltipTop,
            child: PaperCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    progress,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: c['text-muted'],
                    ),
                  ),
                  const SizedBox(height: AppTokens.s2),
                  Text(
                    step.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: c['text'],
                    ),
                  ),
                  const SizedBox(height: AppTokens.s2),
                  Text(
                    step.body,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: c['text-muted'],
                    ),
                  ),
                  const SizedBox(height: AppTokens.s4),
                  Row(
                    children: [
                      AppButton.ghost(
                        key: const Key('coach-skip'),
                        label: (lang['skip'] as String?) ?? 'Skip',
                        onPressed: widget.onClose,
                      ),
                      const Spacer(),
                      AppButton.primary(
                        key: const Key('coach-next'),
                        expanded: false,
                        label: nextLabel,
                        onPressed: _next,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  _SpotlightPainter({
    required this.hole,
    required this.scrim,
    required this.ring,
  });

  final Rect? hole;
  final Color scrim;
  final Color ring;

  @override
  void paint(Canvas canvas, Size size) {
    final scrimPaint = Paint()..color = scrim;
    final holeRect = hole;
    if (holeRect == null) {
      canvas.drawRect(Offset.zero & size, scrimPaint);
      return;
    }
    final rrect = RRect.fromRectAndRadius(
      holeRect,
      const Radius.circular(AppTokens.rLg),
    );
    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addRRect(rrect);
    canvas.drawPath(path, scrimPaint);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = ring
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) {
    return oldDelegate.hole != hole ||
        oldDelegate.scrim != scrim ||
        oldDelegate.ring != ring;
  }
}
