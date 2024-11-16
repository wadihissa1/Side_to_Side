import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../style/palette.dart';
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
    final audioController = context.watch<AudioController>();

    return Scaffold(
      backgroundColor: palette.backgroundMain.color,
      body: Row(
        children: [
          // Left Static Content
          Expanded(
            flex: 2,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/banner.png',
                    filterQuality: FilterQuality.none,
                  ),
                  const SizedBox(height: 20),
                  Transform.rotate(
                    angle: -0.1,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: const Text(
                        'Let\'s gooo to PLAY',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Press Start 2P',
                          fontSize: 32,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Right Scrollable Menu
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  WobblyButton(
                    onPressed: () {
                      audioController.playSfx(SfxType.buttonTap);
                      GoRouter.of(context).go('/play');
                    },
                    child: const Text('Play'),
                  ),
                  const SizedBox(height: 10),
                  WobblyButton(
                    onPressed: () {
                      audioController.playSfx(SfxType.buttonTap);
                      GoRouter.of(context).go('/settings');
                    },
                    child: const Text('Settings'),
                  ),
                  const SizedBox(height: 10),
                  WobblyButton(
                    onPressed: () async {
                      audioController.playSfx(SfxType.buttonTap);
                      GoRouter.of(context).go('/profile');
                    },
                    child: const Text('Profile'),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(top: 70),
                    child: const Text('Built by Wadih Issa & Alexander Issa'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
