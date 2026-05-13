import 'package:flutter/material.dart';
import 'package:qr_code_app/pages/events_page.dart';
import 'package:qr_code_app/providers/event_provider.dart';
import 'package:qr_code_app/providers/lang_provider.dart';
import 'package:qr_code_app/providers/theme_globals.dart';

/// Sticky banner displayed at the top of the page when an event is active.
/// Tapping it navigates to [EventsPage].
class ActiveEventBanner extends StatelessWidget {
  /// Creates the banner.
  const ActiveEventBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: EventProvider(),
      builder: (context, _) {
        final event = EventProvider().activeEvent;
        if (event == null) return const SizedBox.shrink();
        final lang = LangProvider.getMap('events');
        final label =
            '${lang["banner_prefix"] as String} ${event.name}';
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => const EventsPage()),
          ),
          child: Container(
            width: double.infinity,
            color: currentColors['button-color'],
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.event, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
