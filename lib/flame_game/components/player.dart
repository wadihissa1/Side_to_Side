import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart'; // Import gesture events
import 'package:flutter/animation.dart';

import '../../audio/sounds.dart';
import '../effects/hurt_effect.dart';
import '../endless_runner.dart';
import '../endless_world.dart';
import 'obstacle.dart';
import 'point.dart';

/// The [Player] is the component that the player controls by dragging.
class Player extends SpriteAnimationGroupComponent<PlayerState>
    with
        CollisionCallbacks,
        HasWorldReference<EndlessWorld>,
        HasGameReference<EndlessRunner>,
        DragCallbacks {
  Player({
    required this.addScore,
    required this.resetScore,
    super.position,
  }) : super(size: Vector2.all(150), anchor: Anchor.center, priority: 1);

  final void Function({int amount}) addScore;
  final VoidCallback resetScore;

  // Store the player's previous position.
  final Vector2 _lastPosition = Vector2.zero();

  @override
  Future<void> onLoad() async {
    // Define animations for different player states.
    animations = {
      PlayerState.running: await game.loadSpriteAnimation(
        'dash/dash_running.png',
        SpriteAnimationData.sequenced(
          amount: 4,
          textureSize: Vector2.all(16),
          stepTime: 0.15,
        ),
      ),
    };

    // Set the initial state to running.
    current = PlayerState.running;
    _lastPosition.setFrom(position);

    // Add a hitbox to the player.
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Keep the player within the screen and ground bounds.
    position.clamp(
      Vector2.zero(),
      Vector2(world.size.x - size.x, world.groundLevel - size.y / 2),
    );

    _lastPosition.setFrom(position); // Update the last position.
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Obstacle) {
      game.audioController.playSfx(SfxType.damage);
      resetScore();
      add(HurtEffect());
    } else if (other is Point) {
      game.audioController.playSfx(SfxType.score);
      other.removeFromParent();
      addScore();
    }
  }

  /// Handle drag updates to move the player.
@override
void onDragUpdate(DragUpdateEvent event) {
  // Update the player’s position based on the drag.
  position.add(event.delta);

  // Ensure the player stays within the screen's visible area.
  position.clamp(
    Vector2(0, 0), // Top-left corner
    Vector2(world.size.x - size.x, world.size.y - size.y), // Bottom-right corner
  );
}
}

enum PlayerState {
  running,
}
