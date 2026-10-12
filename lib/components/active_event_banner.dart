import 'package:flutter/material.dart';
import 'package:qr_code_app/pages/events_page.dart';
import 'package:qr_code_app/providers/event_provider.dart';
import 'package:qr_code_app/providers/lang_provider.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:qr_code_app/theme/tokens.dart';

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
        final label = '${lang["banner_prefix"] as String} ${event.name}';
        final c = currentColors;
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => const EventsPage()),
          ),
          child: Container(
            width: double.infinity,
            color: c['navy'],
            padding: const EdgeInsets.symmetric(
              horizontal: AppTokens.s4,
              vertical: AppTokens.s2,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.event,
                  color: c['on-button'],
                  size: 16,
                ),
                const SizedBox(width: AppTokens.s2),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: c['on-button'],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: c['on-button'],
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
