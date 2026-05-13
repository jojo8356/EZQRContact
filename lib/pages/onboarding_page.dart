import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_code_app/pages/qr_generator_vcard.dart';
import 'package:qr_code_app/providers/lang_provider.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 3-screen horizontal onboarding shown on the very first app launch.
/// Persists `onboarding_done = true` on completion or skip so it never
/// shows again.
class OnboardingPage extends StatefulWidget {
  /// Creates the onboarding page.
  const OnboardingPage({super.key});

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

    return Scaffold(
      backgroundColor: currentColors['bg'],
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finish,
                child: Text(
                  (lang['skip'] as String?) ?? 'Passer',
                  style: TextStyle(color: currentColors['text']),
                ),
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      3,
                      (i) => _Dot(active: i == _page),
                    ),
                  ),
                  if (isLast)
                    ElevatedButton(
                      onPressed: _goToCreate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: currentColors['button-color'],
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        (lang['create_card'] as String?) ?? 'Créer ma carte',
                      ),
                    )
                  else
                    IconButton(
                      icon: Icon(
                        Icons.arrow_forward_rounded,
                        color: currentColors['text'],
                      ),
                      onPressed: () => _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
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
  const _OnboardingScreen({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 96, color: currentColors['button-color']),
          const SizedBox(height: 32),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: currentColors['text'],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            body,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: currentColors['text-muted'],
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: active ? 12 : 8,
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: active
            ? currentColors['button-color']
            : currentColors['text-muted'],
      ),
    );
  }
}
