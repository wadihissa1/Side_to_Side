import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'my_game.dart';

class MyGameScreen extends StatelessWidget {
  const MyGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget<MyGame>(
        game: MyGame(),
      ),
    );
  }
}
