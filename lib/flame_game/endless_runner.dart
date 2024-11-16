import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../audio/audio_controller.dart';
import '../level_selection/levels.dart';
import '../player_progress/player_progress.dart';
import 'components/background.dart';
import 'endless_world.dart';
import 'game_screen.dart';

class EndlessRunner extends FlameGame<EndlessWorld> with HasCollisionDetection {
  EndlessRunner({
    required this.level,
    required PlayerProgress playerProgress,
    required this.audioController,
  }) : super(
          world: EndlessWorld(level: level, playerProgress: playerProgress),
          camera: CameraComponent.withFixedResolution(width: 1600, height: 720),
        );

  final GameLevel level;
  final AudioController audioController;

  double currentScore = 0;
  int totalCoins = 0;
  double timerAccumulator = 0; // Accumulator for periodic logic

  late final TextComponent scoreComponent;

  @override
  Future<void> onLoad() async {
    camera.backdrop.add(Background(speed: world.speed));

    final textRenderer = TextPaint(
      style: const TextStyle(
        fontSize: 30,
        color: Colors.white,
        fontFamily: 'Press Start 2P',
      ),
    );

    scoreComponent = TextComponent(
      text: 'Score: 0 | Coins: 0',
      position: Vector2.all(30),
      textRenderer: textRenderer,
    );

    camera.viewport.add(scoreComponent);

    world.coinNotifier.addListener(() {
      totalCoins = world.coinNotifier.value;
      updateScoreUI();
    });
  }

  @override
  void update(double dt) {
    super.update(dt);

    timerAccumulator += dt;

    if (timerAccumulator >= 0.5) { // Faster increment (every 0.5 seconds)
      currentScore += 2; // Increase score faster
      timerAccumulator = 0; // Reset accumulator
      updateScoreUI();
    }
  }

  @override
void onMount() {
  super.onMount();
  // Add the back button overlay
 overlays.add(GameScreen.backButtonKey);
 }

  void updateScoreUI() {
    scoreComponent.text = 'Score: ${currentScore.toInt()} | Coins: $totalCoins';
  }
}
