import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_code_app/components/app_button.dart';
import 'package:qr_code_app/components/qr_mark.dart';
import 'package:qr_code_app/pages/qr_generator_vcard.dart';
import 'package:qr_code_app/providers/lang_provider.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:qr_code_app/theme/tokens.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 3-screen horizontal onboarding shown on the very first app launch.
/// Persists `onboarding_done = true` on completion or skip so it never
/// shows again.
class OnboardingPage extends StatefulWidget {
  /// Creates the onboarding page.
  const new({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _page = 0;

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (!mounted) return;
    await Navigator.of(context).pushReplacementNamed('/options');
  }

  Future<void> _goToCreate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (!mounted) return;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const GenerateVCardQRCode()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = LangProvider.getMap('onboarding');
    final isLast = _page == 2;
    final c = currentColors;

    return Scaffold(
      backgroundColor: c['bg'],
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTokens.s5,
                AppTokens.s2,
                AppTokens.s2,
                0,
              ),
              child: Row(
                children: [
                  const QrMark(size: 20),
                  const Spacer(),
                  TextButton(
                    onPressed: _finish,
                    child: Text(
                      (lang['skip'] as String?) ?? 'Passer',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _OnboardingScreen(
                    icon: Icons.swap_horiz_rounded,
                    title: (lang['s1_title'] as String?) ??
                        'Échangez vos contacts pros',
                    body: (lang['s1_body'] as String?) ??
                        'Sans compte, sans cloud. Juste un QR code.',
                  ),
                  _OnboardingScreen(
                    icon: Icons.credit_card_rounded,
                    title: (lang['s2_title'] as String?) ??
                        'Créez votre carte',
                    body: (lang['s2_body'] as String?) ??
                        'Personnalisez couleur, logo et layout.',
                  ),
                  _OnboardingScreen(
                    icon: Icons.qr_code_scanner_rounded,
                    title: (lang['s3_title'] as String?) ??
                        'Scannez. Sauvegardez. Exportez.',
                    body: (lang['s3_body'] as String?) ??
                        'Retrouvez tous vos contacts en un seul endroit.',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTokens.s6,
                AppTokens.s4,
                AppTokens.s6,
                AppTokens.s6,
              ),
              child: Row(
                children: [
                  Row(
                    children: List.generate(
                      3,
                      (i) => _Dot(active: i == _page),
                    ),
                  ),
                  const Spacer(),
                  if (isLast)
                    AppButton.primary(
                      expanded: false,
                      label: (lang['create_card'] as String?) ??
                          'Créer ma carte',
                      onPressed: _goToCreate,
                    )
                  else
                    Material(
                      color: c['button-color'],
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => _controller.nextPage(
                          duration: AppTokens.tPage,
                          curve: Curves.easeInOut,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            color: c['on-button'],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingScreen extends StatelessWidget {
  const new({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final c = currentColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTokens.s8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: c['surface-raised'],
              borderRadius: BorderRadius.circular(AppTokens.rLg),
            ),
            child: Icon(icon, size: 44, color: c['button-color']),
          ),
          const SizedBox(height: AppTokens.s8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: AppTokens.s4),
          Text(
            body,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: c['text-muted'],
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const new({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    var width = 6.0;
    var color = currentColors['surface-raised'];
    if (active) {
      width = 16;
      color = currentColors['button-color'];
    }
    return AnimatedContainer(
      duration: AppTokens.tFast,
      margin: const EdgeInsets.only(right: AppTokens.s1),
      width: width,
      height: 6,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        color: color,
      ),
    );
  }
}
