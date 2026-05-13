import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_code_app/components/app_bar_custom.dart';
import 'package:qr_code_app/data/db/database.dart';
import 'package:qr_code_app/providers/event_provider.dart';
import 'package:qr_code_app/providers/lang_provider.dart';
import 'package:qr_code_app/providers/theme_globals.dart';

/// Displays all events and lets the user create, activate, and deactivate them.
class EventsPage extends StatefulWidget {
  /// Creates the events page.
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  late Stream<List<Event>> _stream;

  @override
  void initState() {
    super.initState();
    _stream = QRDatabase().eventRepo.watchAll();
  }

  Future<void> _showCreateDialog() async {
    final lang = LangProvider.getMap('events');
    final nameCtrl = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: currentColors['surface'],
        title: Text(
          lang['new_event'] as String,
          style: TextStyle(color: currentColors['text']),
        ),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          style: TextStyle(color: currentColors['text']),
          decoration: InputDecoration(
            hintText: lang['name_hint'] as String,
            hintStyle: TextStyle(color: currentColors['text-muted']),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(lang['cancel'] as String),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: currentColors['button-color'],
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(lang['create'] as String),
          ),
        ],
      ),
    );

    if (result != true || nameCtrl.text.trim().isEmpty) return;
    final id = await QRDatabase().eventRepo.create(
          name: nameCtrl.text.trim(),
        );
    if (!mounted) return;
    final event = (await QRDatabase().eventRepo.getAll())
        .firstWhere((e) => e.id == id);
    await EventProvider().activate(event);
  }

  Future<void> _toggleActivation(Event event) async {
    if (event.isActive) {
      await EventProvider().deactivate();
    } else {
      await EventProvider().activate(event);
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final lang = LangProvider.getMap('events');

    return Scaffold(
      backgroundColor: currentColors['bg'],
      appBar: AppBarCustom(lang['title'] as String),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        backgroundColor: currentColors['button-color'],
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(lang['new_event'] as String),
      ),
      body: StreamBuilder<List<Event>>(
        stream: _stream,
        builder: (context, snapshot) {
          final events = snapshot.data ?? [];
          if (events.isEmpty) {
            return Center(
              child: Text(
                lang['no_events'] as String,
                style: TextStyle(color: currentColors['text']),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
            itemCount: events.length,
            itemBuilder: (ctx, i) {
              final e = events[i];
              return _EventTile(
                event: e,
                onToggle: () => unawaited(_toggleActivation(e)),
              );
            },
          );
        },
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event, required this.onToggle});

  final Event event;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final lang = LangProvider.getMap('events');
    return Card(
      color: currentColors['surface'],
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          event.name,
          style: TextStyle(
            color: currentColors['text'],
            fontWeight:
                event.isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: event.startDate != null
            ? Text(
                event.startDate!,
                style: TextStyle(color: currentColors['text-muted']),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (event.isActive)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: currentColors['button-color'],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  lang['active_badge'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: onToggle,
              child: Text(
                event.isActive
                    ? lang['deactivate'] as String
                    : lang['activate'] as String,
                style: TextStyle(
                  color: event.isActive
                      ? Colors.red
                      : currentColors['button-color'],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
