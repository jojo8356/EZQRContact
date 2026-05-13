import 'dart:async';

import 'package:flutter/material.dart';

/// Toggle M3-like avec squish du thumb et durée d'animation configurable.
class AppSwitch extends StatefulWidget {
  /// Creates an [AppSwitch].
  const AppSwitch({
    required this.value,
    required this.onChanged,
    this.duration = const Duration(milliseconds: 300),
    super.key,
  });

  /// Current toggle state.
  final bool value;

  /// Called when the user taps the switch.
  final ValueChanged<bool>? onChanged;

  /// Duration of the full thumb travel animation.
  final Duration duration;

  @override
  State<AppSwitch> createState() => _AppSwitchState();
}

class _AppSwitchState extends State<AppSwitch>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _position;

  static const double _trackW = 52;
  static const double _trackH = 32;
  static const double _thumbSize = 24;
  static const double _pad = 4;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: widget.value ? 1.0 : 0.0,
    );

    _position = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void didUpdateWidget(AppSwitch old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      unawaited(widget.value ? _ctrl.forward() : _ctrl.reverse());
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final trackColor = ColorTween(
      begin: Colors.grey.shade400,
      end: scheme.primary,
    ).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutCubic),
    );

    return GestureDetector(
      onTap: widget.onChanged != null
          ? () => widget.onChanged!(!widget.value)
          : null,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          const tw = _thumbSize;
          final left = _pad + _position.value * (_trackW - tw - _pad * 2);

          return SizedBox(
            width: _trackW,
            height: _trackH,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(_trackH / 2),
                color: trackColor.value,
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: left,
                    top: (_trackH - _thumbSize) / 2,
                    child: Container(
                      width: tw,
                      height: _thumbSize,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(_thumbSize / 2),
                        color: Colors.white,
                      ),
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: Duration(
                            milliseconds:
                                widget.duration.inMilliseconds ~/ 3,
                          ),
                          child: Icon(
                            widget.value ? Icons.check : Icons.close,
                            key: ValueKey(widget.value),
                            size: 14,
                            color: widget.value
                                ? scheme.primary
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
