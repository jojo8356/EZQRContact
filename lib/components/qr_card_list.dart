import 'package:flutter/material.dart';
import 'package:qr_code_app/components/qr_card.dart';

class QRCardListView extends StatefulWidget {
  final List<Map<String, dynamic>> allItems;
  final Future<void> Function() refreshData;

  const QRCardListView({
    super.key,
    required this.allItems,
    required this.refreshData,
  });

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
    int toLoad = initial ? 8 : 2; // 8 éléments au départ, 2 ensuite
    final total = widget.allItems.length;
    if (_loadedCount >= total) return;

    int nextLoad = _loadedCount + toLoad;
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
