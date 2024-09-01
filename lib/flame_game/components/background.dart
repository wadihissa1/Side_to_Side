import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/parallax.dart';

/// The [Background] is a component that is composed of multiple scrolling
/// images which form a parallax, a way to simulate movement and depth in the
/// background.
class Background extends ParallaxComponent {
  Background({required this.speed});

  final double speed;

  @override
  Future<void> onLoad() async {
    final layers = [
      ParallaxImageData('scenery/BG.png'),
      ParallaxImageData('scenery/BG2.png'),
      ParallaxImageData('scenery/BG3.png'),
      ParallaxImageData('scenery/BG4.png'),
    ];

    // The base velocity is now moving upwards (negative Y-axis).
    final baseVelocity = Vector2(0, -speed / pow(2, layers.length));

    // The multiplier delta affects the speed difference between the layers.
    // We only want our layers to move vertically, so we multiply the Y-axis speed.
    final velocityMultiplierDelta = Vector2(0.0, 2.0);

    try {
      parallax = await game.loadParallax(
        layers,
        baseVelocity: baseVelocity,
        velocityMultiplierDelta: velocityMultiplierDelta,
        filterQuality: FilterQuality.none,
      );
      print("Parallax loaded successfully");
    } catch (e) {
      print("Error loading parallax: $e");
    }
  }
}
