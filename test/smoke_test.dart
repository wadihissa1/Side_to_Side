import 'package:flame_test/flame_test.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:side_to_side/app_lifecycle/app_lifecycle.dart';
import 'package:side_to_side/audio/audio_controller.dart';
import 'package:side_to_side/audio/sounds.dart';
import 'package:side_to_side/flame_game/endless_runner.dart';
import 'package:side_to_side/flame_game/game_screen.dart';
import 'package:side_to_side/main.dart';
import 'package:side_to_side/player_progress/persistence/memory_player_progress_persistence.dart';
import 'package:side_to_side/player_progress/player_progress.dart';
import 'package:side_to_side/settings/settings.dart';

void main() {
  // Smoke test for menus
  testWidgets('Smoke test for menus', (tester) async {
    // Build the game app and trigger a frame
    await tester.pumpWidget(MyGame(
      initialToken: '', // Use an empty string for no token
      initialUserId: null, // Use null for no user ID
    ));

    // Verify the presence of main menu buttons
    expect(find.text('Play'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    // Navigate to 'Settings' menu
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Music'), findsOneWidget);

    // Return to the main menu
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();

    // Navigate to the 'Play' menu
    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();
    expect(find.text('Select level'), findsOneWidget);

    // Select Level #1
    await tester.tap(find.text('Level #1'));
    await tester.pump();
  });

  // Smoke test for the Flame game
  testWithGame<EndlessRunner>(
    'Smoke test for Flame game',
        () => EndlessRunner(
      level: (
      number: 1,
      winScore: 3,
      canSpawnTall: false,
      ),
      playerProgress: PlayerProgress(
        store: MemoryOnlyPlayerProgressPersistence(),
      ),
      audioController: _MockAudioController(),
    ),
        (game) async {
      // Add mock overlays for testing
      game.overlays.addEntry(
        GameScreen.backButtonKey,
            (context, game) => Container(),
      );
      game.overlays.addEntry(
        GameScreen.winDialogKey,
            (context, game) => Container(),
      );

      // Load the game
      await game.onLoad();

      // Update the game to simulate progression
      game.update(0);

      // Validate game components
      expect(game.children.length, 3);
      expect(game.world.children.length, 2);
      expect(game.camera.viewport.children.length, 2);
      expect(game.world.player.isLoading, isTrue);
    },
  );
}

// Mock AudioController implementation for the test
class _MockAudioController implements AudioController {
  @override
  void attachDependencies(
      AppLifecycleStateNotifier lifecycleNotifier, SettingsController settingsController) {}

  @override
  void dispose() {}

  @override
  void playSfx(SfxType type) {}
}
