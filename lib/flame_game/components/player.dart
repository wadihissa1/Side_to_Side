import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/animation.dart';

import '../../audio/sounds.dart';
import '../effects/hurt_effect.dart';
import '../effects/jump_effect.dart';
import '../endless_runner.dart';
import '../endless_world.dart';
import 'obstacle.dart';
import 'point.dart';
import '../game_screen.dart';


/// Enum representing the states the player can be in.
enum PlayerState {
  running,
  jumping,
  falling,
}

/// The [Player] is the component that the physical player of the game is
/// controlling.
class Player extends SpriteAnimationGroupComponent<PlayerState>
    with
        CollisionCallbacks,
        HasWorldReference<EndlessWorld>,
        HasGameReference<EndlessRunner> {
  Player({
    required this.addScore,
    required this.addCoins,
    required this.resetScore,
    super.position,
  }) : super(size: Vector2.all(150), anchor: Anchor.center, priority: 1);

  final void Function({int amount}) addScore;
  final void Function({int amount}) addCoins;
  final VoidCallback resetScore;

  double _gravityVelocity = 0;
  final double _jumpLength = 600;

  bool get inAir => (position.y + size.y / 2) < world.groundLevel;
  final Vector2 _lastPosition = Vector2.zero();
  bool get isFalling => _lastPosition.y < position.y;

  @override
  Future<void> onLoad() async {
    animations = {
      PlayerState.running: await game.loadSpriteAnimation(
        'dash/dash_running.png',
        SpriteAnimationData.sequenced(
          amount: 4,
          textureSize: Vector2.all(16),
          stepTime: 0.15,
        ),
      ),
      PlayerState.jumping: SpriteAnimation.spriteList(
        [await game.loadSprite('dash/dash_jumping.png')],
        stepTime: double.infinity,
      ),
      PlayerState.falling: SpriteAnimation.spriteList(
        [await game.loadSprite('dash/dash_falling.png')],
        stepTime: double.infinity,
      ),
    };

    current = PlayerState.running;
    _lastPosition.setFrom(position);

    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (inAir) {
      _gravityVelocity += world.gravity * dt;
      position.y += _gravityVelocity;
      if (isFalling) {
        current = PlayerState.falling;
      }
    }

    final belowGround = position.y + size.y / 2 > world.groundLevel;
    if (belowGround) {
      position.y = world.groundLevel - size.y / 2;
      _gravityVelocity = 0;
      current = PlayerState.running;
    }

    _lastPosition.setFrom(position);
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

if (other is Obstacle) {
  game.audioController.playSfx(SfxType.damage);
  game.pauseEngine();
  game.overlays.add(GameScreen.winDialogKey);
    } else if (other is Point) {
      game.audioController.playSfx(SfxType.score);
      other.removeFromParent();
      addCoins(amount: 1); // Add 1 coin
      addScore(amount: 5); // Increment score faster (e.g., by 5)
    }
  }

  void jump(Vector2 towards) {
    if (!inAir) {
      current = PlayerState.jumping;
      final jumpEffect = JumpEffect(towards..scaleTo(_jumpLength));
      game.audioController.playSfx(SfxType.jump);
      add(jumpEffect);
    }
  }
}
