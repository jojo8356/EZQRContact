import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_code_app/components/action_tile.dart';
import 'package:qr_code_app/components/active_event_banner.dart';
import 'package:qr_code_app/components/app_bar_custom.dart';
import 'package:qr_code_app/components/coach_tour.dart';
import 'package:qr_code_app/components/navbar.dart';
import 'package:qr_code_app/components/qr_mark.dart';
import 'package:qr_code_app/components/section_label.dart';
import 'package:qr_code_app/pages/events_page.dart';
import 'package:qr_code_app/pages/import_qr_page.dart';
import 'package:qr_code_app/pages/qr_generator_simple.dart';
import 'package:qr_code_app/pages/qr_generator_vcard.dart';
import 'package:qr_code_app/pages/qr_scanner.dart';
import 'package:qr_code_app/providers/lang_provider.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:qr_code_app/theme/tokens.dart';
import 'package:qr_code_app/tools/import_contact.dart';

/// Home page of the app. Featured VCard + Scanner tiles, then a 2×2 grid
/// of secondary actions.
class OptionsListPage extends StatefulWidget {
  /// Creates the home page.
  const new({super.key});

  @override
  State<OptionsListPage> createState() => _OptionsListPageState();
}

class _OptionsListPageState extends State<OptionsListPage> {
  var _tourKickoffScheduled = false;
  var _tourActive = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_maybeStartCoachTour());
    });
  }

  Future<void> _maybeStartCoachTour() async {
    if (!mounted || _tourKickoffScheduled) return;
    final replay = CoachTour.takeReplayRequest();
    if (!replay) {
      if (await CoachTour.isDone()) return;
    }
    if (!mounted) return;
    setState(() {
      _tourKickoffScheduled = true;
      _tourActive = true;
    });
    await CoachTour.show(context, steps: homeCoachSteps());
    await CoachTour.markDone();
    if (!mounted) return;
    setState(() {
      _tourActive = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = LangProvider.getMap('menu');
    final home = LangProvider.getMap('home');
    final theme = Theme.of(context);

    return PopScope(
      canPop: !_tourActive,
      child: Scaffold(
        backgroundColor: currentColors['bg'],
        appBar: const AppBarCustom('', titleWidget: EzqrWordmark()),
        body: Column(
          children: [
            const ActiveEventBanner(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppTokens.s5,
                  AppTokens.s6,
                  AppTokens.s5,
                  AppTokens.s10,
                ),
                children: [
                  Text(
                    home['tagline'] as String? ?? 'Échangez. Sans cloud.',
                    style: theme.textTheme.displayLarge,
                  ),
                  const SizedBox(height: AppTokens.s2),
                  Text(
                    home['tagline_sub'] as String? ??
                        'Vos cartes restent sur ce téléphone.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: currentColors['text-muted'],
                    ),
                  ),
                  const SizedBox(height: AppTokens.s8),
                  ActionTile(
                    key: coachVcardKey,
                    featured: true,
                    icon: Icons.contact_page_outlined,
                    title: lang['vcard'] as String,
                    subtitle: home['vcard_sub'] as String?,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => const GenerateVCardQRCode(),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTokens.s3),
                  ActionTile(
                    key: coachScanKey,
                    featured: true,
                    icon: Icons.qr_code_scanner_rounded,
                    title: lang['scanner'] as String,
                    subtitle: home['scanner_sub'] as String?,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => const QRScannerPage(),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTokens.s6),
                  SectionLabel(
                    home['section_more'] as String? ?? 'Outils',
                  ),
                  const SizedBox(height: AppTokens.s2),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: AppTokens.s3,
                    crossAxisSpacing: AppTokens.s3,
                    childAspectRatio: 1.05,
                    children: [
                      ActionTile(
                        icon: Icons.qr_code_2_rounded,
                        title: lang['simple'] as String,
                        subtitle: home['simple_sub'] as String?,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (context) => const GenerateSimpleQRCode(),
                          ),
                        ),
                      ),
                      ActionTile(
                        icon: Icons.photo_outlined,
                        title: lang['import'] as String,
                        subtitle: home['import_sub'] as String?,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (context) => const QrFromImagePage(),
                          ),
                        ),
                      ),
                      ActionTile(
                        icon: Icons.person_add_alt_1_outlined,
                        title: lang['import_contact'] as String,
                        subtitle: home['import_contact_sub'] as String?,
                        onTap: () async {
                          await importContacts(context);
                        },
                      ),
                      ActionTile(
                        icon: Icons.event_outlined,
                        title: lang['events'] as String? ?? 'Événements',
                        subtitle: home['events_sub'] as String?,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => const EventsPage(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: const Navbar(currentRoute: '/options'),
      ),
    );
  }
}
