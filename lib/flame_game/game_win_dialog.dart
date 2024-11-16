import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nes_ui/nes_ui.dart';
import 'package:provider/provider.dart';

import '../level_selection/levels.dart';
import '../style/palette.dart';

/// This dialog is shown when the game ends (e.g., after collision with an obstacle).
class GameWinDialog extends StatelessWidget {
  const GameWinDialog({
    super.key,
    required this.level,
    required this.highScore,
    required this.coinsCollected,
  });

  /// The properties of the current level.
  final GameLevel level;

  /// The high score achieved during the game.
  final int highScore;

  /// The total number of coins collected during the game.
  final int coinsCollected;

  @override
  Widget build(BuildContext context) {
    final palette = context.read<Palette>();
    return Center(
      child: NesContainer(
        width: 420,
        height: 300,
        backgroundColor: palette.backgroundPlaySession.color,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Game Over!',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Level ${level.number} completed.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'High Score: $highScore',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Coins Collected: $coinsCollected',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            NesButton(
              onPressed: () {
                context.go('/play'); // Go back to level selection
              },
              type: NesButtonType.normal,
              child: const Text('Level selection'),
            ),
          ],
        ),
      ),
    );
  }
}
