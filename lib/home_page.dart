import 'package:flutter/material.dart';
import 'package:qr_code_app/components/menu.dart';
import 'package:qr_code_app/modals/guide.dart';
import 'package:qr_code_app/providers/lang.dart';
import 'package:qr_code_app/qr_card.dart';
import 'tools/db/db.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> allItems = [];
  List<bool> expandedList = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _refreshData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showGuidePopup(context);
    });
  }

  Future<void> _refreshData() async {
    setState(() => loading = true);

    final simpleQRs = await QRDatabase().getAllSimpleQR();
    final vcards = await QRDatabase().getAllVCards();

    final merged = [
      ...simpleQRs.map((e) => {'type': 'simple', 'data': e}),
      ...vcards.map((e) => {'type': 'vcard', 'data': e}),
    ];

    setState(() {
      allItems = merged;
      expandedList = List.generate(allItems.length, (_) => false);
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LangProvider.get('title'))),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 20),
              MenuActions(refreshData: _refreshData),
              const SizedBox(height: 20),
              Expanded(
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : allItems.isEmpty
                    ? Center(child: Text(LangProvider.get('QR Not Found')))
                    : ListView.builder(
                        itemCount: allItems.length,
                        itemBuilder: (context, index) {
                          final item = allItems[index];
                          final data = item['data'] as Map<String, dynamic>;
                          final isVCard = item['type'] == 'vcard';

                          return QRCard(
                            data: data,
                            isVCard: isVCard,
                            onRefresh: _refreshData,
                          );
                        },
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
