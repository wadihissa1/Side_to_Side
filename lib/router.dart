import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'flame_game/game_screen.dart';
import 'level_selection/level_selection_screen.dart';
import 'level_selection/levels.dart';
import 'main_menu/main_menu_screen.dart';
import 'settings/settings_screen.dart';
import 'profile/profile_screen.dart';
import 'profile/signin_screen.dart';
import 'profile/signup_screen.dart';
import 'profile/skins_screen.dart';
import 'style/page_transition.dart';
import 'style/palette.dart';

GoRouter router(String? initialToken, int? initialUserId) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const MainMenuScreen(key: Key('main menu')),
        routes: [
          GoRoute(
            path: 'play',
            pageBuilder: (context, state) => buildPageTransition<void>(
              key: const ValueKey('play'),
              color: context.watch<Palette>().backgroundLevelSelection.color,
              child: const LevelSelectionScreen(
                key: Key('level selection'),
              ),
            ),
            routes: [
              GoRoute(
                path: 'session/:level',
                pageBuilder: (context, state) {
                  final levelNumber = int.parse(state.pathParameters['level']!);
                  final level = gameLevels[levelNumber - 1];
                  return buildPageTransition<void>(
                    key: const ValueKey('level'),
                    color: context.watch<Palette>().backgroundPlaySession.color,
                    child: GameScreen(level: level),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsScreen(
              key: Key('settings'),
            ),
          ),
          GoRoute(
            path: 'profile',
            builder: (context, state) => ProfileScreen(
              userId: initialUserId,
              token: initialToken ?? '',
            ),
            routes: [
              GoRoute(
                path: 'signin',
                builder: (context, state) => const SignInScreen(),
              ),
              GoRoute(
                path: 'signup',
                builder: (context, state) => const SignUpScreen(),
              ),
              GoRoute(
                path: 'skins',
                builder: (context, state) => const SkinsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
