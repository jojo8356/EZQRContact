import 'package:flutter/material.dart';
import 'package:qr_code_app/components/qr_card.dart';

/// Lazy-loading scrollable list of [QRCard]s. Loads 8 items on first
/// build then 2 more whenever the user nears the bottom; keeps only the
/// last 12 in memory to bound RAM usage on large collections.
class QRCardListView extends StatefulWidget {
  /// Creates the list. [refreshData] is forwarded to each card so they
  /// can ask the parent to re-query the database after destructive ops.
  const QRCardListView({
    required this.allItems,
    required this.refreshData,
    super.key,
  });

  /// Full pool of items already fetched from the DB.
  final List<Map<String, dynamic>> allItems;

  /// Callback re-running the DB query that produced [allItems].
  final Future<void> Function() refreshData;

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
    _loadMore(initial: true);
    _controller.addListener(_onScroll);
  }

  void _onScroll() {
    if (_controller.position.pixels >=
        _controller.position.maxScrollExtent - 100) {
      _loadMore();
    }
  }

  void _loadMore({bool initial = false}) {
    final toLoad = initial ? 8 : 2; // 8 éléments au départ, 2 ensuite
    final total = widget.allItems.length;
    if (_loadedCount >= total) return;

    var nextLoad = _loadedCount + toLoad;
    if (nextLoad > total) nextLoad = total;

    setState(() {
      _activeItems.addAll(widget.allItems.getRange(_loadedCount, nextLoad));
      _loadedCount = nextLoad;

      // Garder seulement 12 éléments en RAM
      if (_activeItems.length > 12) {
        _activeItems.removeRange(0, _activeItems.length - 12);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _controller,
      itemCount: _activeItems.length,
      itemBuilder: (context, index) {
        final item = _activeItems[index];
        final data = item['data'] as Map<String, dynamic>;
        final isVCard = item['type'] == 'vcard';

        return QRCard(
          data: data,
          isVCard: isVCard,
          onRefresh: widget.refreshData,
        );
      },
    );
  }
}
