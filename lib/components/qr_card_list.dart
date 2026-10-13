import 'package:flutter/material.dart';
import 'package:qr_code_app/components/qr_card.dart';

/// Lazy-loading scrollable list of [QRCard]s. Loads 8 items on first
/// build then 2 more whenever the user nears the bottom; keeps only the
/// last 12 in memory to bound RAM usage on large collections.
class QRCardListView extends StatefulWidget {
  /// Creates the list. [refreshData] is forwarded to each card so they
  /// can ask the parent to re-query the database after destructive ops.
  const new({
    required this.allItems,
    required this.refreshData,
    this.selectMode = false,
    this.selectedKeys = const <String>{},
    this.onHoldSelect,
    this.onToggleSelect,
    super.key,
  });

  /// Full pool of items already fetched from the DB.
  final List<Map<String, dynamic>> allItems;

  /// Callback re-running the DB query that produced [allItems].
  final Future<void> Function() refreshData;

  /// When true, every card shows a checkbox and the window is unbounded.
  final bool selectMode;

  /// Keys of currently checked cards (`vcard:id` / `simple:id`).
  final Set<String> selectedKeys;

  /// Fired after a 2-second hold on a card.
  final void Function(Map<String, dynamic> item)? onHoldSelect;

  /// Fired when a card is tapped in select mode.
  final void Function(Map<String, dynamic> item)? onToggleSelect;

  @override
  State<QRCardListView> createState() => _QRCardListViewState();
}

class _QRCardListViewState extends State<QRCardListView> {
  final ScrollController _controller = ScrollController();
  final List<Map<String, dynamic>> _activeItems = [];
  int _loadedCount = 0;

  @override
  void initState() {
    super.initState();
    _fillWindow(initial: true);
    _controller.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(QRCardListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (identical(oldWidget.allItems, widget.allItems)) return;
    _activeItems.clear();
    _loadedCount = 0;
    _fillWindow(initial: true);
  }

  void _onScroll() {
    if (widget.selectMode) {
      return;
    }
    if (_controller.position.pixels >=
        _controller.position.maxScrollExtent - 100) {
      setState(() {
        _fillWindow();
      });
    }
  }

  void _fillWindow({bool initial = false}) {
    var toLoad = 2;
    if (initial) {
      toLoad = 8;
    }
    final total = widget.allItems.length;
    if (_loadedCount >= total) return;

    var nextLoad = _loadedCount + toLoad;
    if (nextLoad > total) {
      nextLoad = total;
    }

    _activeItems.addAll(widget.allItems.getRange(_loadedCount, nextLoad));
    _loadedCount = nextLoad;

    if (_activeItems.length > 12) {
      _activeItems.removeRange(0, _activeItems.length - 12);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var rows = _activeItems;
    if (widget.selectMode) {
      rows = widget.allItems;
    }
    return ListView.builder(
      controller: _controller,
      itemCount: rows.length,
      itemBuilder: (context, index) {
        final item = rows[index];
        final data = item['data'] as Map<String, dynamic>;
        final isVCard = item['type'] == 'vcard';
        final id = data['id'];
        var cardKey = 'idx:$index';
        var selected = false;
        if (id is int) {
          cardKey = collectionItemKey(isVCard: isVCard, id: id);
          selected = widget.selectedKeys.contains(cardKey);
        }

        return QRCard(
          key: ValueKey(cardKey),
          data: data,
          isVCard: isVCard,
          onRefresh: widget.refreshData,
          selectMode: widget.selectMode,
          selected: selected,
          onHoldSelect: () => widget.onHoldSelect?.call(item),
          onToggleSelect: () => widget.onToggleSelect?.call(item),
        );
      },
    );
  }
}
