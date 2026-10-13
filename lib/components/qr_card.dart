import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_app/components/paper_card.dart';
import 'package:qr_code_app/components/qr_options.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:qr_code_app/theme/tokens.dart';
import 'package:qr_code_app/tools/contacts.dart';
import 'package:qr_code_app/tools/tools.dart';

/// Hold duration before a card enters collection multi-select.
const Duration collectionSelectHold = Duration(seconds: 2);

/// Stable key for a collection row (`vcard:12` / `simple:3`).
String collectionItemKey({required bool isVCard, required int id}) {
  if (isVCard) {
    return 'vcard:$id';
  }
  return 'simple:$id';
}

/// Tile-style widget representing a single QR or VCard row, expandable to
/// reveal the [OptionsQR] action grid.
class QRCard extends StatefulWidget {
  /// Creates a QR card. [onRefresh] is invoked after destructive actions.
  const new({
    required this.data,
    required this.isVCard,
    required this.onRefresh,
    this.onDelete,
    this.selectMode = false,
    this.selected = false,
    this.onHoldSelect,
    this.onToggleSelect,
    super.key,
  });

  /// Legacy row payload for the QR or VCard.
  final Map<String, dynamic> data;

  /// True when [data] represents a vCard contact.
  final bool isVCard;

  /// Callback invoked after a destructive action mutates the database.
  final Future<void> Function() onRefresh;

  /// Test override for [deleteQR]. Production leaves this null.
  final Future<void> Function(int id)? onDelete;

  /// When true, the card shows a checkbox and tap toggles selection.
  final bool selectMode;

  /// Whether this card is currently selected.
  final bool selected;

  /// Fired after a 2-second hold (enter multi-select).
  final VoidCallback? onHoldSelect;

  /// Fired when the checkbox / card is tapped in select mode.
  final VoidCallback? onToggleSelect;

  @override
  State<QRCard> createState() => _QRCardState();
}

class _QRCardState extends State<QRCard> {
  bool expanded = false;
  Timer? _holdTimer;
  bool _ignoreNextTap = false;

  @override
  void didUpdateWidget(QRCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectMode && expanded) {
      expanded = false;
    }
    if (widget.selectMode) {
      _holdTimer?.cancel();
      _holdTimer = null;
    }
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent event) {
    _holdTimer?.cancel();
    _ignoreNextTap = false;
    if (widget.selectMode) {
      return;
    }
    _holdTimer = Timer(collectionSelectHold, () {
      _ignoreNextTap = true;
      unawaited(HapticFeedback.mediumImpact());
      widget.onHoldSelect?.call();
    });
  }

  void _onPointerEnd(PointerEvent event) {
    _holdTimer?.cancel();
    _holdTimer = null;
  }

  void _onTap() {
    if (_ignoreNextTap) {
      _ignoreNextTap = false;
      return;
    }
    if (widget.selectMode) {
      widget.onToggleSelect?.call();
      return;
    }
    setState(() => expanded = !expanded);
  }

  @override
  Widget build(BuildContext context) {
    var type = 'simple';
    if (widget.isVCard) {
      type = 'vcard';
    }
    final titleText = PhoneContacts.getTitle({
      'type': type,
      'data': widget.data,
    });
    final photo = (widget.data['photo'] as String?) ?? '';
    final c = currentColors;
    final theme = Theme.of(context);
    var expandIcon = Icons.expand_more_rounded;
    if (expanded) {
      expandIcon = Icons.expand_less_rounded;
    }

    Widget trailing = Icon(
      expandIcon,
      color: c['text-muted'],
    );
    if (widget.selectMode) {
      trailing = IgnorePointer(
        child: Checkbox(
          key: const Key('qr-card-checkbox'),
          value: widget.selected,
          onChanged: (_) {},
          activeColor: c['button-color'],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.s5,
        vertical: AppTokens.s2,
      ),
      child: Listener(
        onPointerDown: _onPointerDown,
        onPointerUp: _onPointerEnd,
        onPointerCancel: _onPointerEnd,
        child: PaperCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppTokens.s4,
                  vertical: AppTokens.s1,
                ),
                leading: buildItemAvatar(
                  isVCard: widget.isVCard,
                  photo: photo,
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titleText,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: c['text'],
                      ),
                    ),
                    if (widget.data['date_deleted'] != null)
                      Text(
                        'Supprimé le : ${widget.data['date_deleted']}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: c['danger'],
                        ),
                      ),
                  ],
                ),
                trailing: trailing,
                onTap: _onTap,
              ),
              if (!widget.selectMode)
                OptionsQR(
                  isVCard: widget.isVCard,
                  data: widget.data,
                  expanded: expanded,
                  onRefresh: widget.onRefresh,
                  onDelete: widget.onDelete,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
