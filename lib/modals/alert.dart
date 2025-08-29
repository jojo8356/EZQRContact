// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

enum AlertType { info, error, success, warning }

/// Alert configs and customizations.
class Alert {
  Alert({
    required this.icon,
    required this.message,
    required this.type,
    this.id,
    this.duration = defaultDuration,
    this.callback,
  });

  Alert.info({
    required Widget message,
    String? id,
    Duration? duration = defaultDuration,
    VoidCallback? callback,
  }) : this(
          id: id,
          icon: const Icon(Icons.info),
          type: AlertType.info,
          duration: duration,
          message: message,
          callback: callback,
        );

  Alert.success({
    required Widget message,
    String? id,
    Duration? duration = defaultDuration,
    VoidCallback? callback,
  }) : this(
          id: id,
          icon: const Icon(Icons.check_circle),
          type: AlertType.success,
          duration: duration,
          message: message,
          callback: callback,
        );

  Alert.warning({
    required Widget message,
    String? id,
    Duration? duration = defaultDuration,
    VoidCallback? callback,
  }) : this(
          id: id,
          icon: const Icon(Icons.warning),
          type: AlertType.warning,
          duration: duration,
          message: message,
          callback: callback,
        );

  Alert.error({
    required Widget message,
    String? id,
    Duration? duration = defaultDuration,
    VoidCallback? callback,
  }) : this(
          id: id,
          icon: const Icon(Icons.error),
          duration: duration,
          message: message,
          callback: callback,
          type: AlertType.error,
        );

  static const Duration defaultDuration = Duration(seconds: 5);

  /// The ID of this alert. Can be used to update or remove this alert.
  final String? id;

  /// The icon to display on this alert.
  final Widget icon;

  /// The duration to display this alert. If null, this alert will be displayed
  /// until it is removed.
  final Duration? duration;

  /// The message to display on this alert.
  final Widget message;

  /// The callback to call when this alert is tapped.
  /// If null, this alert will not be tappable.
  final VoidCallback? callback;

  final AlertType type;
}

/// This class is used internally by [AppAlerts] to manage the lifecycle of an
/// [Alert]. It keeps track of the remaining duration of the alert and calls
/// the callback when the duration is up.
class _AlertLifecycle {
  _AlertLifecycle({
    required this.alert,
    required this.callback,
  });

  final Alert alert;
  final VoidCallback callback;
  DateTime? _startTime;
  Duration? _remaining;
  Timer? _timer;

  Duration? get remainingDuration {
    if (alert.duration == null) return null;
    final remaining = _remaining ?? alert.duration!;
    if (_startTime == null) {
      return remaining;
    } else {
      return remaining - DateTime.now().difference(_startTime!);
    }
  }

  void start() {
    if (alert.duration == null) return;
    _timer = Timer(remainingDuration!, callback);
    _startTime = DateTime.now();
  }

  void stop() {
    if (alert.duration == null) return;
    _timer?.cancel();
    _timer = null;
    _remaining = remainingDuration;
    _startTime = null;
  }
}

/// The alert overlay widget.
class AppAlerts extends StatefulWidget {
  const AppAlerts({
    required this.child,
    super.key,
  });

  final Widget child;

  static AppAlertState? of(BuildContext context) {
    assert(debugCheckHasAlertsMessenger(context), '');
    return maybeOf(context);
  }

  static AppAlertState? maybeOf(BuildContext context) =>
      context.findAncestorStateOfType<AppAlertState>();

  @override
  AppAlertState createState() => AppAlertState();
}

class AppAlertState extends State<AppAlerts> {
  final List<Alert> _alerts = [];
  final Map<Alert, _AlertLifecycle> _alertLifecycles = {};
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();

  /// Adds an alert or updates an existing alert.
  ///
  /// If an alert with the same ID already exists, it will be replaced.
  void add(Alert alert) {
    final previous = _alerts
        .where((e) => e == alert || (alert.id != null && e.id == alert.id))
        .firstOrNull;
    var lifecycle = _alertLifecycles.remove(previous);
    lifecycle?.stop();

    lifecycle = _alertLifecycles[alert] = _AlertLifecycle(
      alert: alert,
      callback: () => remove(alert),
    )..start();

    if (previous != null) {
      final index = _alerts.indexOf(previous);
      _alerts[index] = alert;
    } else {
      _alerts.add(alert);
      _listKey.currentState?.insertItem(_alerts.length - 1);
    }
  }

  /// Removes an alert.
  void remove(Alert alert) {
    _listKey.currentState?.setState(() {
      final index = _alerts.indexWhere((a) => identical(a, alert));
      if (index >= 0) {
        _alerts.removeAt(index);
        _alertLifecycles[alert]?.stop();
        _alertLifecycles.remove(alert);
        _listKey.currentState?.removeItem(
          index,
          (context, animation) =>
              AlertTile.withAnimation(context, animation, alert),
        );
      }
    });
  }

  /// Freezes the alert, pausing its automatic removal timer.
  void freeze(Alert alert) => _alertLifecycles[alert]?.stop();

  /// Thaws the alert, resuming its automatic removal timer.
  void thaw(Alert alert) => _alertLifecycles[alert]?.start();

  /// Returns the remaining duration of the alert.
  Duration? getRemainingDuration(Alert alert) =>
      _alertLifecycles[alert]?.remainingDuration;

  @override
  Widget build(BuildContext context) {
    return Overlay(
      initialEntries: [
        OverlayEntry(
          builder: (context) => widget.child,
        ),
        OverlayEntry(
          builder: (context) => _AlertDisplay(
            listKey: _listKey,
            alerts: _alerts,
            itemBuilder: (context, index, animation) => AlertTile.withAnimation(
              context,
              animation,
              _alerts[index],
            ),
          ),
        ),
      ],
    );
  }
}

class _AlertDisplay extends StatefulWidget {
  const _AlertDisplay({
    required this.listKey,
    required this.itemBuilder,
    required this.alerts,
  });

  final GlobalKey<AnimatedListState> listKey;
  final AnimatedItemBuilder itemBuilder;
  final List<Alert> alerts;

  @override
  _AlertDisplayState createState() => _AlertDisplayState();
}

class _AlertDisplayState extends State<_AlertDisplay>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: kToolbarHeight),
        Flexible(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: AnimatedList(
              primary: false,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(8),
              key: widget.listKey,
              initialItemCount: widget.alerts.length,
              itemBuilder: widget.itemBuilder,
            ),
          ),
        ),
      ],
    );
  }
}

/// A tile that displays an [Alert].
class AlertTile extends StatefulWidget {
  const AlertTile({
    required this.alert,
    super.key,
  });

  final Alert alert;

  static Widget withAnimation(
    BuildContext context,
    Animation<double> animation,
    Alert alert,
  ) =>
      SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.fastEaseInToSlowEaseOut,
          ),
        ),
        child: FadeTransition(
          opacity: animation,
          child: AlertTile(alert: alert),
        ),
      );

  @override
  State<AlertTile> createState() => _AlertTileState();
}

class _AlertTileState extends State<AlertTile>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  Duration? _remaining;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick)..start();
  }

  void _tick(Duration elapsed) {
    final state = AppAlerts.of(context);
    final remaining = state?.getRemainingDuration(widget.alert);
    if (_remaining != remaining) {
      setState(() {
        _remaining = remaining;
      });
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  Color _getBkgColor(BuildContext context) {
    return switch (widget.alert.type) {
      AlertType.error => Theme.of(context).colorScheme.error,
      AlertType.info => Colors.blue,
      AlertType.warning => Colors.orange,
      AlertType.success => Colors.green,
    };
  }

  (Color, Color) _getColors(Color color) {
    final hslColor = HSLColor.fromColor(color);
    final lighterHSLColor =
        hslColor.withLightness((hslColor.lightness + 0.2).clamp(0.0, 1.0));
    final darkerHSLColor =
        hslColor.withLightness((hslColor.lightness - 0.2).clamp(0.0, 1.0));
    final lighterColor = lighterHSLColor.toColor();
    final darkerColor = darkerHSLColor.toColor();
    return (darkerColor, lighterColor);
  }

  bool isTouchDevice() {
    final platform = Theme.of(context).platform;
    return platform == TargetPlatform.android ||
        platform == TargetPlatform.iOS ||
        platform == TargetPlatform.fuchsia;
  }

  Widget _gestureWrapper({
    required Widget child,
  }) {
    final isTouch = isTouchDevice();
    final alertsState = AppAlerts.of(context);

    if (!isTouch) {
      return MouseRegion(
        onEnter: (event) => alertsState?.freeze(widget.alert),
        onExit: (event) => alertsState?.thaw(widget.alert),
        child: child,
      );
    }

    return GestureDetector(
      onTapDown: (details) => alertsState?.freeze(widget.alert),
      onTapCancel: () => alertsState?.thaw(widget.alert),
      onTapUp: (details) => alertsState?.thaw(widget.alert),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bkgColor = _getBkgColor(context);
    final (darkerColor, lighterColor) = _getColors(bkgColor);
    final alertsState = AppAlerts.of(context);

    return Theme(
      data: theme.copyWith(
        splashColor: darkerColor,
        hoverColor: lighterColor,
        highlightColor: lighterColor,
        listTileTheme: ListTileThemeData(
          iconColor: theme.colorScheme.onError,
        ),
      ),
      child: _gestureWrapper(
        child: Card(
          clipBehavior: Clip.antiAlias,
          color: bkgColor,
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              ListTile(
                leading: widget.alert.icon,
                title: widget.alert.message,
                titleTextStyle: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onTertiary,
                ),
                trailing: GestureDetector(
                  onTap: () => alertsState?.remove(widget.alert),
                  child: const Icon(Icons.close),
                ),
                onTap: widget.alert.callback,
              ),
              if (widget.alert.duration != null && _remaining != null)
                Positioned(
                  right: 0,
                  left: 0,
                  bottom: 0,
                  child: LinearProgressIndicator(
                    color: darkerColor,
                    backgroundColor: Colors.transparent,
                    value: _remaining!.inMilliseconds /
                        widget.alert.duration!.inMilliseconds,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

bool debugCheckHasAlertsMessenger(BuildContext context) {
  assert(
    () {
      if (context.findAncestorWidgetOfExactType<AppAlerts>() == null) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('No ScaffoldMessenger widget found.'),
          ErrorDescription('${context.widget.runtimeType} widgets require a '
              'ScaffoldMessenger widget ancestor.'),
          ...context.describeMissingAncestor(
            expectedAncestorType: AppAlertState,
          ),
          ErrorHint(
            'Typically, the ScaffoldMessenger widget is introduced '
            'by the MaterialApp at the top of your application widget tree.',
          ),
        ]);
      }
      return true;
    }(),
    '',
  );
  return true;
}