import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../settings/settings.dart';
import '../style/palette.dart';
import '../style/responsive_screen.dart';
import '../style/wobbly_button.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  Future<bool> isLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null && prefs.getInt('userId') != null;
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final settingsController = context.watch<SettingsController>();
    final audioController = context.watch<AudioController>();

    return Scaffold(
      backgroundColor: palette.backgroundMain.color,
      body: ResponsiveScreen(
squarishMainArea: Center(
  child: Padding(
    padding: const EdgeInsets.only(top: 0), // Move the banner closer to the top
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start, // Align content to the top
      children: [
        Image.asset(
          'assets/images/banner.png',
          filterQuality: FilterQuality.none,
          width: 400, // Set desired width
          height: 250, // Set desired height
          fit: BoxFit.contain, // Optional: Adjust scaling
        ),
        const SizedBox(height: 50),
        Transform.rotate(
          angle: -0.1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: const Text(
              'Can you beat the 300 SCORE!!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Press Start 2P',
                fontSize: 24,
                height: 1,
              ),
            ),
          ),
        ),
      ],
    ),
  ),
),
        rectangularMenuArea: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            WobblyButton(
              onPressed: () {
                audioController.playSfx(SfxType.buttonTap);
                GoRouter.of(context).go('/play');
              },
              child: const Text('Play'),
            ),
            _gap,
            WobblyButton(
              onPressed: () {
                audioController.playSfx(SfxType.buttonTap);
                GoRouter.of(context).go('/settings');
              },
              child: const Text('Settings'),
            ),
            _gap,
            WobblyButton(
              onPressed: () async {
                audioController.playSfx(SfxType.buttonTap);
                GoRouter.of(context).go('/profile');
              },
              child: const Text('Profile'),
            ),
            _gap,
            Padding(
              padding: const EdgeInsets.only(top: 32),
              child: ValueListenableBuilder<bool>(
                valueListenable: settingsController.audioOn,
                builder: (context, audioOn, child) {
                  return IconButton(
                    onPressed: () => settingsController.toggleAudioOn(),
                    icon: Icon(audioOn ? Icons.volume_up : Icons.volume_off),
                  );
                },
              ),
            ),
            _gap,
            const Text('Built by Wadih Issa & Alexander Issa'),
          ],
        ),
      ),
    );
  }

  static const _gap = SizedBox(height: 10);
}
