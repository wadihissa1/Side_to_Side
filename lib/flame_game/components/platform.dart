import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';

/// A simple platform component for the player to jump onto.
class Platform extends PositionComponent {
  Platform({required Vector2 position}) {
    this.position = position;
    size = Vector2(200, 20); // Set platform size
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    // Set the platform color
    final paint = Paint()..color = Colors.brown;
    // Add a rectangle shape to visually represent the platform
    add(RectangleComponent(size: size, paint: paint));

    // Optional: add a hitbox if needed for collision detection
    add(RectangleHitbox());
  }
}
