import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import '../level_selection/levels.dart';
import '../player_progress/player_progress.dart';
import 'components/obstacle.dart';
import 'components/player.dart';
import 'components/point.dart';
import 'game_screen.dart';

class EndlessWorld extends World with TapCallbacks, HasGameReference {
  EndlessWorld({
    required this.level,
    required this.playerProgress,
    Random? random,
  }) : _random = random ?? Random();

  final GameLevel level;
  final PlayerProgress playerProgress;
  late double speed = _calculateSpeed(level.number);

  double elapsedTime = 0;
  double timerAccumulator = 0;
  final ValueNotifier<int> coinNotifier = ValueNotifier(0);
  final Random _random;

  final double gravity = 30;
  late final double groundLevel = (size.y / 2) - (size.y / 5);
  late final Player player;
  late final DateTime timeStarted;

  int? levelCompletedIn; // Nullable property to track level completion time

  Vector2 get size => (parent as FlameGame).size;

  void addScore({int amount = 1}) {
    print('Score increased by $amount');
  }

  void addCoins({int amount = 1}) {
    coinNotifier.value += amount;
    print('Coins increased by $amount');
  }

  void resetScore() {
    print('Score reset');
  }

  @override
  Future<void> onLoad() async {
    timeStarted = DateTime.now();

    player = Player(
      position: Vector2(-size.x / 3, groundLevel - 900),
      addScore: addScore,
      addCoins: addCoins,
      resetScore: resetScore,
    );
    add(player);

    add(
      SpawnComponent(
        factory: (_) => Obstacle.random(
          random: _random,
          canSpawnTall: level.canSpawnTall,
        ),
        period: 5,
        area: Rectangle.fromPoints(
          Vector2(size.x / 2, groundLevel),
          Vector2(size.x / 2, groundLevel),
        ),
        random: _random,
      ),
    );

    add(
      SpawnComponent.periodRange(
        factory: (_) => Point(),
        minPeriod: 3.0,
        maxPeriod: 5.0 + level.number,
        area: Rectangle.fromPoints(
          Vector2(size.x / 2, -size.y / 2 + Point.spriteSize.y),
          Vector2(size.x / 2, groundLevel),
        ),
        random: _random,
      ),
    );
  }

  void completeLevel() {
    levelCompletedIn = DateTime.now().difference(timeStarted).inSeconds;
    print('Level completed in $levelCompletedIn seconds.');
  }

  @override
  void update(double dt) {
    super.update(dt);

    timerAccumulator += dt;

    if (timerAccumulator >= 1) {
      elapsedTime += 1;
      timerAccumulator = 0;
      print('Elapsed Time: $elapsedTime');
    }
  }

  @override
void onTapDown(TapDownEvent event) {
  final towards = (event.localPosition - player.position)..normalize();
  if (towards.y.isNegative) {
    player.jump(towards);
  }
}

  static double _calculateSpeed(int level) => 200 + (level * 200);
}
